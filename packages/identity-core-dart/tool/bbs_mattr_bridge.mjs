#!/usr/bin/env node
/**
 * Bridge MATTR para identity-core-dart — derive/verify BbsBlsSignatureProof2020.
 *
 * stdin:  { op, credential, revealDocument?, nonce?, issuerDidDocument? }
 * stdout: { ok, credential? | verified?, error? }
 *
 * Usa node_modules de packages/identity-core (mismo stack QUARK-990).
 */
import { createRequire } from 'node:module'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { readFileSync } from 'node:fs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const coreRoot = join(__dirname, '..', '..', 'identity-core')
const require = createRequire(join(coreRoot, 'package.json'))

const {
  BbsBlsSignatureProof2020,
  BbsBlsSignature2020,
  deriveProof,
} = require('@mattrglobal/jsonld-signatures-bbs')
const jsigs = require('jsonld-signatures')
const jsonld = require('jsonld')

/** Contextos mínimos embebidos (offline). */
const EMBEDDED = {
  'https://www.w3.org/2018/credentials/v1': {
    '@context': {
      '@version': 1.1,
      id: '@id',
      type: '@type',
      VerifiableCredential: {
        '@id': 'https://www.w3.org/2018/credentials#VerifiableCredential',
        '@context': {
          '@version': 1.1,
          id: '@id',
          type: '@type',
          credentialSubject: {
            '@id': 'https://www.w3.org/2018/credentials#credentialSubject',
            '@type': '@id',
          },
          issuer: {
            '@id': 'https://www.w3.org/2018/credentials#issuer',
            '@type': '@id',
          },
          issuanceDate: {
            '@id': 'https://www.w3.org/2018/credentials#issuanceDate',
            '@type': 'http://www.w3.org/2001/XMLSchema#dateTime',
          },
          proof: {
            '@id': 'https://w3id.org/security#proof',
            '@type': '@id',
            '@container': '@graph',
          },
        },
      },
      EcdsaSecp256k1Signature2019: 'https://w3id.org/security#EcdsaSecp256k1Signature2019',
      EcdsaSecp256r1Signature2018: 'https://w3id.org/security#EcdsaSecp256r1Signature2018',
      Ed25519Signature2018: 'https://w3id.org/security#Ed25519Signature2018',
      RsaSignature2018: 'https://w3id.org/security#RsaSignature2018',
      proof: {
        '@id': 'https://w3id.org/security#proof',
        '@type': '@id',
        '@container': '@graph',
      },
    },
  },
}

function findVm(didDocument, vmUrl) {
  if (!didDocument) return null
  const fragment = vmUrl.includes('#') ? `#${vmUrl.split('#')[1]}` : vmUrl
  const bag = []
  for (const key of [
    'verificationMethod',
    'assertionMethod',
    'authentication',
    'capabilityInvocation',
    'capabilityDelegation',
  ]) {
    const arr = didDocument[key]
    if (!Array.isArray(arr)) continue
    for (const item of arr) {
      if (item && typeof item === 'object') bag.push(item)
    }
  }
  for (const item of bag) {
    const id = String(item.id ?? '')
    if (id === vmUrl || id === fragment || vmUrl.endsWith(id) || id.endsWith(fragment)) {
      return {
        ...item,
        id: vmUrl,
        controller: item.controller?.startsWith?.('did:')
          ? item.controller
          : didDocument.id,
      }
    }
  }
  return null
}

function makeDocumentLoader({ issuerDidDocument, extra = {} } = {}) {
  const nodeDocumentLoader = jsonld.documentLoaders.node()
  return async (url) => {
    if (EMBEDDED[url]) {
      return { contextUrl: null, documentUrl: url, document: EMBEDDED[url] }
    }
    if (extra[url]) {
      return { contextUrl: null, documentUrl: url, document: extra[url] }
    }
    if (issuerDidDocument && url.startsWith('did:')) {
      const did = url.split('#')[0]
      if (did === issuerDidDocument.id || url.startsWith(issuerDidDocument.id)) {
        if (url.includes('#')) {
          const vm = findVm(issuerDidDocument, url)
          if (vm) return { contextUrl: null, documentUrl: url, document: vm }
        }
        return {
          contextUrl: null,
          documentUrl: url,
          document: issuerDidDocument,
        }
      }
    }
    // Contextos BBS / security: fetch HTTP (dev/E2E).
    return nodeDocumentLoader(url)
  }
}

async function runDerive(input) {
  const documentLoader = makeDocumentLoader({
    issuerDidDocument: input.issuerDidDocument,
    extra: input.extraDocuments ?? {},
  })
  return deriveProof(input.credential, input.revealDocument, {
    suite: new BbsBlsSignatureProof2020(),
    nonce: input.nonce ? Buffer.from(String(input.nonce), 'utf8') : undefined,
    documentLoader,
  })
}

async function runVerify(input) {
  const proofType = input.credential?.proof?.type
  const Suite =
    proofType === 'BbsBlsSignatureProof2020'
      ? BbsBlsSignatureProof2020
      : BbsBlsSignature2020
  const documentLoader = makeDocumentLoader({
    issuerDidDocument: input.issuerDidDocument,
    extra: input.extraDocuments ?? {},
  })
  const result = await jsigs.verify(input.credential, {
    suite: new Suite(),
    purpose: new jsigs.purposes.AssertionProofPurpose(),
    documentLoader,
  })
  return { verified: !!result.verified, error: result.error?.message }
}

const raw = readFileSync(0, 'utf8')
let input
try {
  input = JSON.parse(raw)
} catch (e) {
  process.stdout.write(JSON.stringify({ ok: false, error: `JSON inválido: ${e.message}` }))
  process.exit(1)
}

try {
  if (input.op === 'derive') {
    const credential = await runDerive(input)
    process.stdout.write(JSON.stringify({ ok: true, credential }))
  } else if (input.op === 'verify') {
    const out = await runVerify(input)
    process.stdout.write(JSON.stringify({ ok: true, ...out }))
  } else {
    process.stdout.write(JSON.stringify({ ok: false, error: `op desconocida: ${input.op}` }))
    process.exit(1)
  }
} catch (e) {
  process.stdout.write(
    JSON.stringify({ ok: false, error: e instanceof Error ? e.message : String(e) }),
  )
  process.exit(1)
}
