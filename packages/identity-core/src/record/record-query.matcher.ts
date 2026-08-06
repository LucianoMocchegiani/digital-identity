import type { RecordTagQuery } from './record-storage.types'

type TagsBase = Record<string, string | string[] | boolean | undefined | null>

export type StoredRecordForQuery = {
  id: string
  createdAt?: string
  tags: TagsBase
}

/**
 * Evalúa si un record persistido satisface una query de tags Credo.
 * Misma semántica que el filtro SQL en {@link buildTagQuerySql}.
 */
export function matchesRecordTagQuery(
  stored: StoredRecordForQuery,
  query: RecordTagQuery,
): boolean {
  const { tags, id } = stored

  if (query.id != null && id !== query.id) return false

  for (const [key, value] of Object.entries(query)) {
    if (key === '$or' || key === 'id' || value == null) continue

    if (!matchesTagEntry(tags, key, value, 'every')) return false
  }

  if (Array.isArray(query.$or)) {
    const orMatch = query.$or.some((sub) =>
      Object.entries(sub).every(([key, value]) => {
        if (value == null) return true
        return matchesTagEntry(tags, key, value, 'some')
      }),
    )
    if (!orMatch) return false
  }

  return true
}

function matchesTagEntry(
  tags: TagsBase,
  key: string,
  value: unknown,
  arrayMode: 'every' | 'some',
): boolean {
  const tagVal = tags[key]
  if (tagVal == null) return false

  if (Array.isArray(value)) {
    if (!Array.isArray(tagVal)) return false
    if (arrayMode === 'every') {
      return value.every((v) => (tagVal as string[]).includes(v as string))
    }
    return value.some((v) => (tagVal as string[]).includes(v as string))
  }

  if (Array.isArray(tagVal)) {
    return (tagVal as string[]).includes(value as string)
  }

  return tagVal === value
}
