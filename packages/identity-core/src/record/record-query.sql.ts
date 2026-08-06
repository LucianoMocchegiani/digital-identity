import type { RecordTagQuery } from './record-storage.types'

export type TagQuerySql = {
  /** Fragmento AND-safe (sin `WHERE`). `TRUE` si la query no impone filtros. */
  clause: string
  params: unknown[]
}

type SqlBuildContext = {
  params: unknown[]
  nextParam: number
}

/**
 * Traduce una query de tags Credo a condiciones SQL sobre la columna `data` (JSON).
 * Los parámetros empiezan en `startParamIndex` ($1, $2, …).
 */
export function buildTagQuerySql(
  query: RecordTagQuery,
  startParamIndex = 1,
): TagQuerySql {
  const ctx: SqlBuildContext = { params: [], nextParam: startParamIndex }
  const conditions: string[] = []

  if (query.id != null) {
    const idIdx = pushParam(ctx, query.id)
    conditions.push(`id = $${idIdx}`)
  }

  for (const [key, value] of Object.entries(query)) {
    if (key === '$or' || key === 'id' || value == null) continue
    conditions.push(buildTagCondition(key, value, ctx, 'every'))
  }

  if (Array.isArray(query.$or) && query.$or.length > 0) {
    conditions.push(buildOrClause(query.$or, ctx))
  }

  return {
    clause: conditions.length > 0 ? conditions.join(' AND ') : 'TRUE',
    params: ctx.params,
  }
}

function buildOrClause(
  branches: Array<Record<string, unknown>>,
  ctx: SqlBuildContext,
): string {
  const sqlBranches = branches.map((sub) => {
    const parts = Object.entries(sub)
      .filter(([, value]) => value != null)
      .map(([key, value]) => buildTagCondition(key, value, ctx, 'some'))

    if (parts.length === 0) return 'TRUE'
    return parts.join(' AND ')
  })

  return `(${sqlBranches.join(' OR ')})`
}

function buildTagCondition(
  key: string,
  value: unknown,
  ctx: SqlBuildContext,
  arrayMode: 'every' | 'some',
): string {
  const keyIdx = pushParam(ctx, key)
  const path = `jsonb_extract_path(data::jsonb, 'tags', $${keyIdx})`
  const exists = `${path} IS NOT NULL`

  if (Array.isArray(value)) {
    if (arrayMode === 'some') {
      const valsIdx = pushParam(ctx, value.map((v) => String(v)))
      return `(${exists} AND jsonb_typeof(${path}) = 'array' AND ${path} ?| $${valsIdx}::text[])`
    }

    const jsonIdx = pushParam(ctx, JSON.stringify(value))
    return `(${exists} AND jsonb_typeof(${path}) = 'array' AND ${path} @> $${jsonIdx}::jsonb)`
  }

  const scalarTextIdx = pushParam(ctx, String(value))
  const scalarJsonIdx = pushParam(ctx, JSON.stringify(value))

  return `(${exists} AND (
    CASE WHEN jsonb_typeof(${path}) = 'array'
      THEN ${path} ? $${scalarTextIdx}::text
      ELSE ${path} = $${scalarJsonIdx}::jsonb
    END
  ))`
}

function pushParam(ctx: SqlBuildContext, value: unknown): number {
  const idx = ctx.nextParam
  ctx.params.push(value)
  ctx.nextParam += 1
  return idx
}
