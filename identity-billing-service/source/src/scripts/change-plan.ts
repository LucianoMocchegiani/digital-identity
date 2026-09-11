/**
 * CLI para cambiar el plan de una cuenta existente.
 *
 * Uso:
 *   cd identity-billing-service/source
 *   npm run change-plan -- --email usuario@ejemplo.com
 *   npm run change-plan -- --email usuario@ejemplo.com --plan pro_double
 */

// cd identity-billing-service/source
// npm install
// BILLING_URL=http://localhost:9000 ADMIN_API_KEY=dev-admin-change-me npm run change-plan -- --email usuario@ejemplo.com
// Para cambiar a un plan específico (no business por defecto):
// BILLING_URL=http://localhost:9000 ADMIN_API_KEY=dev-admin-change-me npm run change-plan -- --email usuario@ejemplo.com --plan pro_double
// Los valores de ADMIN_API_KEY y BILLING_URL deben coincidir con los que tiene tu docker-compose.yml (por defecto dev-admin-change-me y http://localhost:9000).
// ▣  Build · MiMo V2.5 Free · 13m 2s

import 'reflect-metadata'

type Args = Record<string, string | boolean>

function parseArgs(argv: string[]): Args {
  const out: Args = {}
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i]
    if (!a.startsWith('--')) continue
    const key = a.slice(2)
    const next = argv[i + 1]
    if (!next || next.startsWith('--')) {
      out[key] = true
    } else {
      out[key] = next
      i++
    }
  }
  return out
}

async function billingFetch(
  path: string,
  init?: RequestInit & { admin?: boolean },
) {
  const base = process.env.BILLING_URL ?? 'http://localhost:9000'
  const headers: Record<string, string> = {
    'content-type': 'application/json',
    ...(init?.headers as Record<string, string> | undefined),
  }
  if (init?.admin) {
    headers['x-admin-key'] = process.env.ADMIN_API_KEY ?? 'dev-admin-change-me'
  }
  const { admin: _a, ...fetchInit } = init ?? {}
  const res = await fetch(`${base}/v1${path}`, { ...fetchInit, headers })
  const text = await res.text()
  const body = text ? JSON.parse(text) : null
  if (!res.ok) {
    throw new Error(`${fetchInit.method ?? 'GET'} ${path} → ${res.status}: ${text}`)
  }
  return body
}

const VALID_PLANS = ['free', 'pro', 'pro_double', 'business'] as const

async function main() {
  const args = parseArgs(process.argv.slice(2))
  const email = String(args.email ?? '')
  const plan = String(args.plan ?? 'business')

  if (!email) {
    console.error('Falta --email')
    process.exit(1)
  }

  if (!(VALID_PLANS as readonly string[]).includes(plan)) {
    console.error(`--plan inválido. Valores: ${VALID_PLANS.join(', ')}`)
    process.exit(1)
  }

  console.log(`Buscando cuenta con email: ${email}`)
  const accounts = (await billingFetch('/admin/accounts', { admin: true })) as any[]
  const account = accounts.find((a: any) => a.email === email)

  if (!account) {
    console.error(`No se encontró cuenta con email: ${email}`)
    process.exit(1)
  }

  console.log(`Cuenta encontrada: ${account.id} (${account.name}) — plan actual: ${account.plan}`)

  if (account.plan === plan) {
    console.log(`La cuenta ya está en el plan "${plan}". No se requiere cambios.`)
    process.exit(0)
  }

  console.log(`Cambiando plan: ${account.plan} → ${plan}`)
  const updated = await billingFetch(`/admin/accounts/${account.id}/plan`, {
    method: 'POST',
    body: JSON.stringify({ plan }),
    admin: true,
  })

  console.log('\n✅ Plan actualizado:')
  console.log(`   Cuenta:    ${updated.id} (${updated.name})`)
  console.log(`   Plan:      ${updated.plan}`)
  console.log(`   Productos: ${updated.maxProducts} max`)
  console.log(`   RPM:       ${updated.rateLimitRpm}`)
  console.log(`   TX/mes:    ${updated.monthlyTxQuota}`)
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
