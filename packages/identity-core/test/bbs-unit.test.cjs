/**
 * Unit tests BBS (QUARK-990) — correr tras `tsc` vía `npm run test:unit`.
 * CommonJS para alinear con el build de identity-core.
 */
const assert = require('node:assert/strict')
const { describe, it } = require('node:test')
const {
  buildRevealFrame,
  extractRevealPathsFromPresentationDefinition,
} = require('../dist/credential/bbs/reveal-frame')
const { getProofOptions } = require('../dist/credential/credential.builder')
const { BBS_PROOF_TYPE } = require('../dist/credential/bbs/constants')

describe('getProofOptions (QUARK-990)', () => {
  it('defaults to BbsBlsSignature2020', () => {
    assert.equal(getProofOptions({}).proofType, BBS_PROOF_TYPE)
  })

  it('request proofType wins', () => {
    assert.equal(
      getProofOptions({ proofType: 'Ed25519Signature2018' }).proofType,
      'Ed25519Signature2018'
    )
  })
})

describe('reveal-frame / PEX paths', () => {
  it('extracts unique credentialSubject paths from PD', () => {
    const paths = extractRevealPathsFromPresentationDefinition({
      input_descriptors: [
        {
          id: 'd1',
          constraints: {
            fields: [
              { path: ['$.credentialSubject.givenName'] },
              { path: '$.credentialSubject.familyName' },
              { path: ['$.credentialSubject.givenName'] },
            ],
          },
        },
      ],
    })
    assert.deepEqual(
      [...paths].sort(),
      ['$.credentialSubject.familyName', '$.credentialSubject.givenName'].sort()
    )
  })

  it('buildRevealFrame only reveals requested subject claims', () => {
    const frame = buildRevealFrame(
      {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        type: ['VerifiableCredential'],
        credentialSubject: {
          id: 'did:example:holder',
          givenName: 'Ada',
          familyName: 'Lovelace',
          secret: 'no',
        },
      },
      ['$.credentialSubject.givenName']
    )
    const subject = frame.credentialSubject
    assert.ok('id' in subject)
    assert.ok('givenName' in subject)
    assert.equal('familyName' in subject, false)
    assert.equal('secret' in subject, false)
    assert.equal('type' in subject, false)
  })

  it('buildRevealFrame omits invalid subject type (undefined)', () => {
    const frame = buildRevealFrame(
      {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        type: ['VerifiableCredential', 'GenericCredential'],
        credentialSubject: { name: 'Juan', documentNumber: '1' },
      },
      ['$.credentialSubject.name']
    )
    const subject = frame.credentialSubject
    assert.deepEqual(Object.keys(subject).sort(), ['@explicit', 'name'].sort())
  })

  it('buildRevealFrame always reveals credentialSubject.id when present', () => {
    const frame = buildRevealFrame(
      {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        type: ['VerifiableCredential'],
        credentialSubject: { id: 'did:example:holder', name: 'Ada', secret: 'no' },
      },
      ['$.credentialSubject.name']
    )
    const subject = frame.credentialSubject
    assert.ok('id' in subject)
    assert.ok('name' in subject)
    assert.equal('secret' in subject, false)
  })
})

describe('absolutizeVerificationMethodForDid', () => {
  const {
    absolutizeVerificationMethodForDid,
  } = require('../dist/credential/bbs/absolutize-verification-method')

  it('expands relative fragment ids', () => {
    const out = absolutizeVerificationMethodForDid(
      { id: '#key-1', controller: '#controller' },
      'did:peer:example'
    )
    assert.equal(out.id, 'did:peer:example#key-1')
    assert.equal(out.controller, 'did:peer:example')
  })

  it('leaves absolute did urls unchanged', () => {
    const vm = { id: 'did:peer:example#key-1', controller: 'did:peer:example' }
    assert.equal(absolutizeVerificationMethodForDid(vm, 'did:peer:example'), vm)
  })
})

describe('presentationDefinitionForHolderVpSigning', () => {
  const {
    presentationDefinitionForHolderVpSigning,
  } = require('../dist/credential/bbs/pex-bbs-derive')
  const { BBS_PROOF_TYPE_DERIVED } = require('../dist/credential/bbs/constants')

  it('adds Ed25519 proof types when credentials are BBS derived', () => {
    const pd = {
      id: 'pd-generic-bbs',
      input_descriptors: [
        {
          id: 'generic-credential-bbs',
          format: {
            ldp_vc: { proof_type: ['BbsBlsSignature2020', 'BbsBlsSignatureProof2020'] },
          },
        },
      ],
    }
    const out = presentationDefinitionForHolderVpSigning(pd, {
      'generic-credential-bbs': [
        {
          claimFormat: 'ldp_vc',
          encoded: { proof: { type: BBS_PROOF_TYPE_DERIVED } },
        },
      ],
    })
    assert.deepEqual(out.input_descriptors[0].format.ldp_vc.proof_type, [
      'BbsBlsSignature2020',
      'BbsBlsSignatureProof2020',
      'Ed25519Signature2018',
      'Ed25519Signature2020',
    ])
    // Original PD sin mutar
    assert.deepEqual(pd.input_descriptors[0].format.ldp_vc.proof_type, [
      'BbsBlsSignature2020',
      'BbsBlsSignatureProof2020',
    ])
  })

  it('leaves PD unchanged when credentials are not BBS', () => {
    const pd = {
      input_descriptors: [
        { id: 'd1', format: { ldp_vc: { proof_type: ['Ed25519Signature2018'] } } },
      ],
    }
    const out = presentationDefinitionForHolderVpSigning(pd, {
      d1: [{ encoded: { proof: { type: 'Ed25519Signature2018' } } }],
    })
    assert.equal(out, pd)
  })
})
