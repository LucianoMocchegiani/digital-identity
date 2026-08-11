/**
 * CLI de onboarding vía self-serve:
 *   POST /auth/register
 *   POST /products issuer + POST /products verifier
 *     (billing provisiona tenant + activa resource automáticamente)
 *
 * Uso:
 *   cd identity-billing-service/source
 *   npm run onboard -- --name "ACME" --email billing@acme.com --password secret123 \
 *     --issuer acme --verifier acme
 */
import 'reflect-metadata'

/** Args CLI parseados (`--key value` o flags booleanos). */
type Args = Record<string, string | boolean>

/** Parsea `process.argv` estilo `--name ACME --no-issuer`. */
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

/**
 * Helper HTTP contra `/v1` del billing local.
 * @param path - Ruta relativa (p. ej. `/auth/register`)
 * @param init.admin - Envía `x-admin-key`
 * @param init.token - Envía Bearer JWT
 */
async function billingFetch(
  path: string,
  init?: RequestInit & { admin?: boolean; token?: string },
) {
  const base = process.env.BILLING_URL ?? 'http://localhost:9000'
  const headers: Record<string, string> = {
    'content-type': 'application/json',
    ...(init?.headers as Record<string, string> | undefined),
  }
  if (init?.admin) {
    headers['x-admin-key'] = process.env.ADMIN_API_KEY ?? 'dev-admin-change-me'
  }
  if (init?.token) {
    headers.authorization = `Bearer ${init.token}`
  }
  const { admin: _a, token: _t, ...fetchInit } = init ?? {}
  const res = await fetch(`${base}/v1${path}`, { ...fetchInit, headers })
  const text = await res.text()
  const body = text ? JSON.parse(text) : null
  if (!res.ok) {
    throw new Error(`${fetchInit.method ?? 'GET'} ${path} → ${res.status}: ${text}`)
  }
  return body
}

/**
 * Registra cuenta, opcionalmente sube plan (admin) y crea productos issuer/verifier.
 * Imprime las API keys en stdout (única oportunidad de verlas).
 */
async function main() {
  const args = parseArgs(process.argv.slice(2))
  const name = String(args.name ?? '')
  const email = String(args.email ?? '')
  const password = String(args.password ?? '')
  const planRaw = String(args.plan ?? 'free')
  const plan =
    planRaw === 'pro' ||
    planRaw === 'pro_double' ||
    planRaw === 'business' ||
    planRaw === 'paid'
      ? planRaw
      : 'free'
  const issuerId = String(args.issuer ?? 'demo-issuer')
  const verifierId = String(args.verifier ?? 'demo-verifier')
  const createIssuer = args['no-issuer'] !== true
  const createVerifier = args['no-verifier'] !== true

  if (!name || !email || !password) {
    console.error('Faltan --name, --email y --password')
    process.exit(1)
  }
  if (password.length < 8) {
    console.error('--password debe tener al menos 8 caracteres')
    process.exit(1)
  }

  const registered = await billingFetch('/auth/register', {
    method: 'POST',
    body: JSON.stringify({ name, email, password }),
  })
  const accountId = registered.account.id as string
  const token = registered.accessToken as string
  console.log('cuenta', accountId, registered.account.plan)

  if (plan === 'paid' || plan === 'pro') {
    await billingFetch(`/admin/accounts/${accountId}/activate-paid`, {
      method: 'POST',
      body: '{}',
      admin: true,
    })
    console.log('cuenta activada como pro')
  } else if (plan === 'pro_double' || plan === 'business') {
    await billingFetch(`/admin/accounts/${accountId}/plan`, {
      method: 'POST',
      body: JSON.stringify({ plan }),
      admin: true,
    })
    console.log(`cuenta en plan ${plan}`)
  }

  if (createIssuer) {
    const issuer = await billingFetch('/products', {
      method: 'POST',
      token,
      body: JSON.stringify({
        name: `${name} Issuer`,
        service: 'issuer',
        walletId: issuerId,
      }),
    })
    console.log('producto issuer', issuer.product.id, issuer.product.resourceStatus)
    console.log('ISSUER_API_KEY=', issuer.product.apiKey)
  }

  if (createVerifier) {
    const verifier = await billingFetch('/products', {
      method: 'POST',
      token,
      body: JSON.stringify({
        name: `${name} Verifier`,
        service: 'verifier',
        walletId: verifierId,
      }),
    })
    console.log('producto verifier', verifier.product.id, verifier.product.resourceStatus)
    console.log('VERIFIER_API_KEY=', verifier.product.apiKey)
  }

  const products = await billingFetch('/products', { token })
  console.log('productos', JSON.stringify(products, null, 2))
  console.log('\nListo. Guardá las API keys; no se volverán a mostrar.')
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
