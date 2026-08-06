#!/usr/bin/env node
/**
 * Round-trip: native createProof (Docker/linux .so via a tiny helper) is heavy;
 * this script verifies that a proof produced by the Rust unit-test path
 * can be checked with MATTR when provided on stdin.
 *
 * stdin JSON: { publicKey, proof, messages, nonce } (base64 fields; messages = revealed only)
 * stdout: { ok, verified }
 *
 * Prefer native/bbs Docker golden for the primary gate; use this for explicit MATTR check
 * of a proof file exported from Rust.
 */
import { createRequire } from 'node:module'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { readFileSync } from 'node:fs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const coreRoot = join(__dirname, '..', '..', 'identity-core')
const require = createRequire(join(coreRoot, 'package.json'))
const { blsVerifyProof } = require('@mattrglobal/bbs-signatures')

const input = JSON.parse(readFileSync(0, 'utf8'))
const b64 = (s) => Uint8Array.from(Buffer.from(s, 'base64'))

const result = await blsVerifyProof({
  publicKey: b64(input.publicKey),
  proof: b64(input.proof),
  messages: input.messages.map(b64),
  nonce: b64(input.nonce),
})

process.stdout.write(
  JSON.stringify({ ok: true, verified: !!result.verified, error: result.error }) + '\n',
)
