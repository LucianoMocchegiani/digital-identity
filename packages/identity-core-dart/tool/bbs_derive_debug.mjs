#!/usr/bin/env node
/**
 * Dump intermedios del derive MATTR (fase 2 LD).
 * stdin: { credential, revealDocument, nonce?, issuerDidDocument? }
 * stdout: { ok, proofStatements, documentStatements, transformedDocumentStatements,
 *           revealDocumentStatements, revealIndices, messagesB64, publicKeyB64,
 *           signatureB64, nonceB64, revealDocumentResult, derivedCredential }
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
const jsonld = require('jsonld')
const { SECURITY_CONTEXT_URL } = require('jsonld-signatures')

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
    return nodeDocumentLoader(url)
  }
}

const input = JSON.parse(readFileSync(0, 'utf8'))
const documentLoader = makeDocumentLoader({
  issuerDidDocument: input.issuerDidDocument,
  extra: input.extraDocuments ?? {},
})

const credential = structuredClone(input.credential)
const proof = { ...credential.proof }
delete credential.proof

const suite2020 = new BbsBlsSignature2020()
const suiteProof = new BbsBlsSignatureProof2020()

const documentStatements = await suite2020.createVerifyDocumentData(credential, {
  documentLoader,
})
const proofStatements = await suite2020.createVerifyProofData(proof, {
  documentLoader,
})

const transformedInputDocumentStatements = documentStatements.map((element) =>
  element.replace(/(_:c14n[0-9]+)/g, '<urn:bnid:$1>'),
)
const compactInputProofDocument = await jsonld.fromRDF(
  transformedInputDocumentStatements.join('\n'),
)
const revealDocumentResult = await jsonld.frame(
  compactInputProofDocument,
  input.revealDocument,
  { documentLoader },
)
const revealDocumentStatements = await suite2020.createVerifyDocumentData(
  revealDocumentResult,
  { documentLoader },
)

const numberOfProofStatements = proofStatements.length
const proofRevealIndicies = Array.from(Array(numberOfProofStatements).keys())
const documentRevealIndicies = revealDocumentStatements.map(
  (key) => transformedInputDocumentStatements.indexOf(key) + numberOfProofStatements,
)
const revealIndices = proofRevealIndicies.concat(documentRevealIndicies)

const nonce = input.nonce
  ? Buffer.from(String(input.nonce), 'utf8')
  : Buffer.from('phase2-fixed-nonce-for-golden-tests!!!!!!')

const derived = await deriveProof(input.credential, input.revealDocument, {
  suite: suiteProof,
  nonce,
  documentLoader,
})

const b64 = (u) => Buffer.from(u).toString('base64')
const messages = proofStatements.concat(documentStatements)

process.stdout.write(
  JSON.stringify({
    ok: true,
    proofStatements,
    documentStatements,
    transformedDocumentStatements: transformedInputDocumentStatements,
    revealDocumentStatements,
    revealIndices,
    messagesB64: messages.map((s) => b64(Buffer.from(s, 'utf8'))),
    signatureB64: proof.proofValue,
    nonceB64: b64(nonce),
    nonceUtf8: nonce.toString('utf8'),
    revealDocumentResult,
    derivedCredential: derived,
    securityContextUrl: SECURITY_CONTEXT_URL,
  }),
)
