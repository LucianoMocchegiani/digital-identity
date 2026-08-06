#!/usr/bin/env node
/**
 * Fase 2 E2E: mensajes/índices producidos por Dart → blsCreateProof MATTR → verify.
 * stdin: {
 *   publicKeyB64, signatureB64, nonceB64, messagesB64[], revealIndices[],
 *   revealedDocument, proofMeta: { verificationMethod, created, proofPurpose }
 * }
 */
import { createRequire } from 'node:module'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { readFileSync } from 'node:fs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const coreRoot = join(__dirname, '..', '..', 'identity-core')
const require = createRequire(join(coreRoot, 'package.json'))
const { blsCreateProof, blsVerifyProof } = require('@mattrglobal/bbs-signatures')
const jsigs = require('jsonld-signatures')
const { BbsBlsSignatureProof2020 } = require('@mattrglobal/jsonld-signatures-bbs')
const jsonld = require('jsonld')

const input = JSON.parse(readFileSync(0, 'utf8'))
const b64 = (s) => Uint8Array.from(Buffer.from(s, 'base64'))

const publicKey = b64(input.publicKeyB64)
const signature = b64(input.signatureB64)
const nonce = b64(input.nonceB64)
const messages = input.messagesB64.map(b64)
const revealed = input.revealIndices

const proof = await blsCreateProof({
  publicKey,
  signature,
  messages,
  nonce,
  revealed,
})

const revealedMessages = revealed.map((i) => messages[i])
const verifyRaw = await blsVerifyProof({
  publicKey,
  proof,
  messages: revealedMessages,
  nonce,
  revealed,
})

const derived = {
  ...input.revealedDocument,
  proof: {
    type: 'BbsBlsSignatureProof2020',
    created: input.proofMeta.created,
    verificationMethod: input.proofMeta.verificationMethod,
    proofPurpose: input.proofMeta.proofPurpose ?? 'assertionMethod',
    nonce: Buffer.from(nonce).toString('base64'),
    proofValue: Buffer.from(proof).toString('base64'),
  },
}

const issuerDidDocument = input.issuerDidDocument
const documentLoader = async (url) => {
  if (issuerDidDocument && String(url).startsWith(issuerDidDocument.id)) {
    if (String(url).includes('#')) {
      const vm = (issuerDidDocument.verificationMethod || []).find(
        (v) => v.id === url || String(url).endsWith(v.id),
      )
      if (vm) return { contextUrl: null, documentUrl: url, document: vm }
    }
    return { contextUrl: null, documentUrl: url, document: issuerDidDocument }
  }
  return jsonld.documentLoaders.node()(url)
}

const suiteVerify = await jsigs.verify(derived, {
  suite: new BbsBlsSignatureProof2020(),
  purpose: new jsigs.purposes.AssertionProofPurpose(),
  documentLoader,
})

process.stdout.write(
  JSON.stringify({
    ok: true,
    blsVerifyProof: !!verifyRaw.verified,
    jsigsVerified: !!suiteVerify.verified,
    jsigsError: suiteVerify.error?.message,
    derivedProofValueB64: Buffer.from(proof).toString('base64'),
  }) + '\n',
)
