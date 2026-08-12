import { writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const outPath = join(__dirname, '..', 'Kuatia-Demo-Club-Recital.postman_collection.json');

/**
 * Solo PNG/JPG/JPEG/WEBP con extensión en el path (la wallet ignora query strings
 * y no acepta SVG ni URLs tipo Unsplash sin `.jpg` en el path).
 *
 * Logos inventados en `postman/assets/demo-credentials/` (raw GitHub).
 * Fondos: Pexels (estadio / recital / sede corporativa).
 */
const ASSET_BASE =
  'https://raw.githubusercontent.com/LucianoMocchegiani/digital-identity/main/postman/assets/demo-credentials';

const IMG = {
  clubLogo: `${ASSET_BASE}/club-norte-crest.png`,
  clubBg:
    'https://images.pexels.com/photos/1884574/pexels-photo-1884574.jpeg',
  recitalLogo: `${ASSET_BASE}/recital-live-mark.png`,
  recitalBg:
    'https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg',
  // Sede / edificio corporativo (sin maquinaria).
  andesLogo: `${ASSET_BASE}/constructora-andes-mark.png`,
  andesBg:
    'https://images.pexels.com/photos/323705/pexels-photo-323705.jpeg',
};

function displayBlock({ name, bgColor, textColor, logoUrl, logoAlt, bgImageUrl }) {
  const block = {
    name,
    locale: 'es',
    background_color: bgColor,
    text_color: textColor,
    logo: { uri: logoUrl, alt_text: logoAlt },
  };
  if (bgImageUrl) block.background_image = { uri: bgImageUrl };
  return block;
}

function claimDisplays(map) {
  const out = {};
  for (const [key, label] of Object.entries(map)) {
    out[key] = { display: [{ name: label, locale: 'es' }] };
  }
  return out;
}

function credConfig(id, vct, display, claimLabels) {
  return {
    [id]: {
      format: 'dc+sd-jwt',
      vct,
      cryptographic_binding_methods_supported: ['did:jwk', 'jwk'],
      credential_signing_alg_values_supported: ['ES256'],
      proof_types_supported: {
        jwt: { proof_signing_alg_values_supported: ['ES256'] },
      },
      claims: claimDisplays(claimLabels),
      display: [display],
    },
  };
}

function metadataBody(issuerDisplay, credentialConfigs) {
  return {
    display: [issuerDisplay],
    dpopSigningAlgValuesSupported: ['ES256'],
    credentialConfigurationsSupported: credentialConfigs,
  };
}

const ORGS = {
  club: {
    key: 'club',
    title: 'Club Norte',
    issuerIdVar: 'clubIssuerId',
    verifierIdVar: 'clubVerifierId',
    issuerApiKeyVar: 'clubIssuerApiKey',
    verifierApiKeyVar: 'clubVerifierApiKey',
    issuerIdDefault: 'club-norte',
    verifierIdDefault: 'club-norte',
    productIssuerName: 'Club Norte Issuer',
    productVerifierName: 'Club Norte Verifier',
    issuerDisplay: displayBlock({
      name: 'Club Norte',
      bgColor: '#0f766e',
      textColor: '#FFFFFF',
      logoUrl: IMG.clubLogo,
      logoAlt: 'Club Norte',
      bgImageUrl: IMG.clubBg,
    }),
    credentialConfigs: credConfig(
      'membership_card',
      'MembershipCredential',
      displayBlock({
        name: 'Membresía Club Norte',
        bgColor: '#0f766e',
        textColor: '#FFFFFF',
        logoUrl: IMG.clubLogo,
        logoAlt: 'Club Norte',
        bgImageUrl: IMG.clubBg,
      }),
      {
        given_name: 'Nombre',
        family_name: 'Apellido',
        member_id: 'Nº de socio',
        membership_tier: 'Categoría',
        organization: 'Organización',
        valid_from: 'Válida desde',
        valid_until: 'Válida hasta',
      },
    ),
    verifierClientName: 'Club Norte Accesos',
    credentials: [
      {
        key: 'clubMembership',
        label: 'Membresía Club Norte',
        configId: 'membership_card',
        vct: 'MembershipCredential',
        claims: {
          given_name: 'María',
          family_name: 'López',
          member_id: 'CN-10482',
          membership_tier: 'Socio pleno',
          organization: 'Club Norte',
          valid_from: '2026-01-01',
          valid_until: '2026-12-31',
        },
        claimsDisplay: {
          given_name: { name: 'Nombre', locale: 'es' },
          family_name: { name: 'Apellido', locale: 'es' },
          member_id: { name: 'Nº de socio', locale: 'es' },
          membership_tier: { name: 'Categoría', locale: 'es' },
          organization: { name: 'Organización', locale: 'es' },
          valid_from: { name: 'Válida desde', locale: 'es' },
          valid_until: { name: 'Válida hasta', locale: 'es' },
        },
        sd: ['member_id', 'membership_tier', 'valid_until'],
        dcqlClaims: ['given_name', 'family_name', 'member_id', 'membership_tier', 'organization'],
      },
    ],
  },
  recital: {
    key: 'recital',
    title: 'Recital Live',
    issuerIdVar: 'recitalIssuerId',
    verifierIdVar: 'recitalVerifierId',
    issuerApiKeyVar: 'recitalIssuerApiKey',
    verifierApiKeyVar: 'recitalVerifierApiKey',
    issuerIdDefault: 'recital-live',
    verifierIdDefault: 'recital-live',
    productIssuerName: 'Recital Live Issuer',
    productVerifierName: 'Recital Live Verifier',
    issuerDisplay: displayBlock({
      name: 'Recital Live',
      bgColor: '#7c3aed',
      textColor: '#FFFFFF',
      logoUrl: IMG.recitalLogo,
      logoAlt: 'Recital Live',
      bgImageUrl: IMG.recitalBg,
    }),
    credentialConfigs: credConfig(
      'recital_ticket',
      'RecitalTicketCredential',
      displayBlock({
        name: 'Entrada Recital',
        bgColor: '#7c3aed',
        textColor: '#FFFFFF',
        logoUrl: IMG.recitalLogo,
        logoAlt: 'Recital Live',
        bgImageUrl: IMG.recitalBg,
      }),
      {
        holder_name: 'Titular',
        event_name: 'Evento',
        venue: 'Venue',
        seat: 'Asiento',
        ticket_code: 'Código',
        event_date: 'Fecha',
        gate: 'Puerta',
      },
    ),
    verifierClientName: 'Recital Live Accesos',
    credentials: [
      {
        key: 'recitalTicket',
        label: 'Entrada Recital',
        configId: 'recital_ticket',
        vct: 'RecitalTicketCredential',
        claims: {
          holder_name: 'Diego Fernández',
          event_name: 'Noche de Rock — Estadio Norte',
          venue: 'Estadio Norte',
          seat: 'Platea B · Fila 12 · Asiento 8',
          ticket_code: 'RL-2026-88421',
          event_date: '2026-09-20T21:00:00-03:00',
          gate: 'Puerta 4',
        },
        claimsDisplay: {
          holder_name: { name: 'Titular', locale: 'es' },
          event_name: { name: 'Evento', locale: 'es' },
          venue: { name: 'Venue', locale: 'es' },
          seat: { name: 'Asiento', locale: 'es' },
          ticket_code: { name: 'Código', locale: 'es' },
          event_date: { name: 'Fecha', locale: 'es' },
          gate: { name: 'Puerta', locale: 'es' },
        },
        sd: ['ticket_code', 'seat', 'gate'],
        dcqlClaims: ['holder_name', 'event_name', 'venue', 'seat', 'ticket_code', 'gate'],
      },
    ],
  },
  andes: {
    key: 'andes',
    title: 'Constructora Andes',
    issuerIdVar: 'andesIssuerId',
    verifierIdVar: 'andesVerifierId',
    issuerApiKeyVar: 'andesIssuerApiKey',
    verifierApiKeyVar: 'andesVerifierApiKey',
    issuerIdDefault: 'constructora-andes',
    verifierIdDefault: 'constructora-andes',
    productIssuerName: 'Constructora Andes Issuer',
    productVerifierName: 'Constructora Andes Verifier',
    issuerDisplay: displayBlock({
      name: 'Constructora Andes',
      bgColor: '#1c1917',
      textColor: '#FFFFFF',
      logoUrl: IMG.andesLogo,
      logoAlt: 'Constructora Andes',
      bgImageUrl: IMG.andesBg,
    }),
    credentialConfigs: credConfig(
      'machinery_operator_cert',
      'HeavyMachineryOperatorCredential',
      displayBlock({
        name: 'Operador de Maquinaria Pesada',
        bgColor: '#1c1917',
        textColor: '#FFFFFF',
        logoUrl: IMG.andesLogo,
        logoAlt: 'Constructora Andes',
        bgImageUrl: IMG.andesBg,
      }),
      {
        given_name: 'Nombre',
        family_name: 'Apellido',
        employee_id: 'Legajo',
        equipment_type: 'Equipo habilitado',
        work_site: 'Obra / frente',
        certificate_id: 'Nº de certificado',
        organization: 'Empresa',
        validity_scope: 'Ámbito de validez',
        valid_from: 'Válido desde',
        valid_until: 'Válido hasta',
      },
    ),
    verifierClientName: 'Constructora Andes — Control de obra',
    credentials: [
      {
        key: 'andesOperator',
        label: 'Operador de Maquinaria Pesada',
        configId: 'machinery_operator_cert',
        vct: 'HeavyMachineryOperatorCredential',
        claims: {
          given_name: 'Luis',
          family_name: 'Benítez',
          employee_id: 'CA-7841',
          equipment_type: 'Excavadora hidráulica · Pala cargadora',
          work_site: 'Obra Ruta 40 — Tramo Sur',
          certificate_id: 'CA-OMP-2026-0312',
          organization: 'Constructora Andes S.A.',
          validity_scope:
            'Solo válido en obras y frentes de Constructora Andes. Sin validez ante terceros.',
          valid_from: '2026-03-01',
          valid_until: '2027-02-28',
        },
        claimsDisplay: {
          given_name: { name: 'Nombre', locale: 'es' },
          family_name: { name: 'Apellido', locale: 'es' },
          employee_id: { name: 'Legajo', locale: 'es' },
          equipment_type: { name: 'Equipo habilitado', locale: 'es' },
          work_site: { name: 'Obra / frente', locale: 'es' },
          certificate_id: { name: 'Nº de certificado', locale: 'es' },
          organization: { name: 'Empresa', locale: 'es' },
          validity_scope: { name: 'Ámbito de validez', locale: 'es' },
          valid_from: { name: 'Válido desde', locale: 'es' },
          valid_until: { name: 'Válido hasta', locale: 'es' },
        },
        sd: ['employee_id', 'certificate_id', 'work_site', 'valid_until'],
        dcqlClaims: [
          'given_name',
          'family_name',
          'employee_id',
          'equipment_type',
          'organization',
          'validity_scope',
          'certificate_id',
        ],
      },
    ],
  },
};

function qrOfferExec(cred) {
  const offerVar = `${cred.key}OfferUri`;
  const sessionVar = `${cred.key}IssuanceSessionId`;
  return [
    "pm.test('Status 200/201', () => pm.expect(pm.response.code).to.be.oneOf([200, 201]));",
    'const res = pm.response.json();',
    'if (res.offerUri) {',
    `  try { pm.environment.set('${offerVar}', res.offerUri); } catch (e) {}`,
    `  pm.collectionVariables.set('${offerVar}', res.offerUri);`,
    `  console.log('${offerVar}:', res.offerUri);`,
    '}',
    'if (res.issuanceSessionId) {',
    `  try { pm.environment.set('${sessionVar}', res.issuanceSessionId); } catch (e) {}`,
    `  pm.collectionVariables.set('${sessionVar}', res.issuanceSessionId);`,
    '}',
    `pm.test('Offer ${cred.label}', () => pm.expect(res.offerUri).to.be.a('string').and.include('openid-credential-offer'));`,
    'if (res.offerUri) {',
    '  const uri = res.offerUri;',
    '  pm.visualizer.set(`',
    "    <script src='https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js'><\\/script>",
    "    <div style='display:flex;flex-direction:column;align-items:center;padding:20px;font-family:sans-serif'>",
    `      <h3 style='margin-bottom:16px'>${cred.label} — Offer QR</h3>`,
    "      <p style='font-size:12px;color:#555;margin-bottom:16px'>Escanear con identity-wallet</p>",
    "      <div id='qr'></div>",
    "      <p style='margin-top:12px;font-size:11px;word-break:break-all;max-width:360px;text-align:center'>${uri}</p>",
    '    </div>',
    "    <script>new QRCode(document.getElementById('qr'),{text:'${uri}',width:280,height:280,correctLevel:QRCode.CorrectLevel.L})<\\/script>",
    '  `, { uri });',
    '}',
  ];
}

function qrRequestExec(cred) {
  const requestVar = `${cred.key}RequestUri`;
  const sessionVar = `${cred.key}VerificationSessionId`;
  return [
    "pm.test('Status 200/201', () => pm.expect(pm.response.code).to.be.oneOf([200, 201]));",
    'const res = pm.response.json();',
    'if (res.requestUri) {',
    `  try { pm.environment.set('${requestVar}', res.requestUri); } catch (e) {}`,
    `  pm.collectionVariables.set('${requestVar}', res.requestUri);`,
    `  console.log('${requestVar}:', res.requestUri);`,
    '}',
    'if (res.verificationSessionId) {',
    `  try { pm.environment.set('${sessionVar}', res.verificationSessionId); } catch (e) {}`,
    `  pm.collectionVariables.set('${sessionVar}', res.verificationSessionId);`,
    `  console.log('${sessionVar}:', res.verificationSessionId);`,
    '}',
    `pm.test('Request ${cred.label}', () => pm.expect(res.requestUri).to.be.a('string'));`,
    'if (res.requestUri) {',
    '  const uri = res.requestUri;',
    '  pm.visualizer.set(`',
    "    <script src='https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js'><\\/script>",
    "    <div style='display:flex;flex-direction:column;align-items:center;padding:20px;font-family:sans-serif'>",
    `      <h3 style='margin-bottom:16px'>${cred.label} — Request QR</h3>`,
    "      <p style='font-size:12px;color:#555;margin-bottom:16px'>Escanear con identity-wallet</p>",
    "      <div id='qr'></div>",
    "      <p style='margin-top:12px;font-size:11px;word-break:break-all;max-width:360px;text-align:center'>${uri}</p>",
    '    </div>',
    "    <script>new QRCode(document.getElementById('qr'),{text:'${uri}',width:280,height:280,correctLevel:QRCode.CorrectLevel.L})<\\/script>",
    '  `, { uri });',
    '}',
  ];
}

const VP_DECODE = `function b64urlDecode(str) {
    str = str.replace(/-/g, '+').replace(/_/g, '/');
    while (str.length % 4) str += '=';
    return CryptoJS.enc.Base64.parse(str).toString(CryptoJS.enc.Utf8);
}
function decodeSdJwt(compact) {
    var chunks = compact.split('~');
    var payload = JSON.parse(b64urlDecode(chunks[0].split('.')[1]));
    var skip = ['_sd','_sd_alg','cnf','iss','iat','vct'];
    var claims = {};
    Object.keys(payload).forEach(function(k) { if (skip.indexOf(k) === -1) claims[k] = payload[k]; });
    chunks.slice(1).filter(function(p) {
        try { var a = JSON.parse(b64urlDecode(p)); return Array.isArray(a) && a.length === 3; } catch(e) { return false; }
    }).forEach(function(p) {
        var arr = JSON.parse(b64urlDecode(p)); claims[arr[1]] = arr[2];
    });
    return { vct: payload.vct, issuer: payload.iss, issuedAt: payload.iat ? new Date(payload.iat*1000).toISOString() : null, claims: claims };
}
try {
    var body = pm.response.json();
    pm.test('Estado sesion: ' + (body.state || '?'), function() { pm.expect(body.state).to.be.a('string'); });
    var vpToken = body.authorizationResponsePayload && body.authorizationResponsePayload.vp_token;
    if (!vpToken) { console.log('Sin vp_token — escanear QR en wallet y reintentar'); return; }
    var decoded = [];
    var parsed; try { parsed = JSON.parse(vpToken); } catch(e) { parsed = vpToken; }
    if (typeof parsed === 'string') {
        decoded.push({ descriptor: 'vp_token', decoded: decodeSdJwt(parsed) });
    } else {
        Object.keys(parsed).forEach(function(key) {
            var list = Array.isArray(parsed[key]) ? parsed[key] : [parsed[key]];
            list.forEach(function(compact) {
                if (typeof compact === 'string' && compact.indexOf('.') > 0) {
                    decoded.push({ descriptor: key, decoded: decodeSdJwt(compact) });
                }
            });
        });
    }
    pm.test('Credencial(es) presentada(s) (' + decoded.length + ')', function() {
        console.log(JSON.stringify(decoded, null, 2));
        pm.expect(decoded.length).to.be.above(0);
    });
} catch(e) {
    pm.test('Error decodificando vp_token', function() { pm.expect.fail(e.message); });
}`;

function issuerHeaders(apiKeyVar) {
  return [
    { key: 'Content-Type', value: 'application/json' },
    { key: 'X-API-Key', value: `{{${apiKeyVar}}}` },
  ];
}

function verifierHeaders(apiKeyVar) {
  return [
    { key: 'Content-Type', value: 'application/json' },
    { key: 'X-API-Key', value: `{{${apiKeyVar}}}` },
  ];
}

function billingHeaders() {
  return [
    { key: 'Content-Type', value: 'application/json' },
    { key: 'Authorization', value: 'Bearer {{accessToken}}' },
  ];
}

function walletPause(name, uriVar) {
  return {
    name,
    request: {
      method: 'GET',
      url: '{{issuerBaseUrl}}/health',
      description:
        '**Paso manual.** Abrir pestaña **Visualize** del request de offer/request anterior y escanear con identity-wallet.',
    },
    event: [
      {
        listen: 'test',
        script: {
          type: 'text/javascript',
          exec: [
            "pm.test('Paso manual wallet', () => pm.expect(true).to.be.true);",
            `console.log('URI:', pm.collectionVariables.get('${uriVar}') || pm.environment.get('${uriVar}'));`,
          ],
        },
      },
    ],
  };
}

function productCreate(org, service) {
  const isIssuer = service === 'issuer';
  const walletVar = isIssuer ? org.issuerIdVar : org.verifierIdVar;
  const apiKeyVar = isIssuer ? org.issuerApiKeyVar : org.verifierApiKeyVar;
  const name = isIssuer ? org.productIssuerName : org.productVerifierName;
  const defaultWallet = isIssuer ? org.issuerIdDefault : org.verifierIdDefault;
  return {
    name: `01.${org.key} — POST product ${service} (${org.title})`,
    request: {
      method: 'POST',
      header: billingHeaders(),
      body: {
        mode: 'raw',
        raw: JSON.stringify(
          {
            name,
            service,
            walletId: `{{${walletVar}}}`,
          },
          null,
          2,
        ),
      },
      url: '{{billingBaseUrl}}/v1/products',
      description: `Crea producto ${service} \`${defaultWallet}\` y guarda API key en \`${apiKeyVar}\`. Requiere plan con cupo (free=2; este demo usa 6 → plan pro_double).`,
    },
    event: [
      {
        listen: 'test',
        script: {
          type: 'text/javascript',
          exec: [
            'const res = pm.response.json();',
            "pm.test('Producto creado', () => pm.expect(pm.response.code).to.be.oneOf([200, 201]));",
            'if (!res.product) return;',
            `pm.collectionVariables.set('${walletVar}', res.product.walletId);`,
            `pm.collectionVariables.set('${apiKeyVar}', res.product.apiKey);`,
            `try { pm.environment.set('${walletVar}', res.product.walletId); } catch (e) {}`,
            `try { pm.environment.set('${apiKeyVar}', res.product.apiKey); } catch (e) {}`,
            ...(isIssuer
              ? [
                  "pm.collectionVariables.set('issuerId', res.product.walletId);",
                  "pm.collectionVariables.set('issuerApiKey', res.product.apiKey);",
                  "try { pm.environment.set('issuerId', res.product.walletId); } catch (e) {}",
                  "try { pm.environment.set('issuerApiKey', res.product.apiKey); } catch (e) {}",
                ]
              : [
                  "pm.collectionVariables.set('verifierId', res.product.walletId);",
                  "pm.collectionVariables.set('verifierApiKey', res.product.apiKey);",
                  "try { pm.environment.set('verifierId', res.product.walletId); } catch (e) {}",
                  "try { pm.environment.set('verifierApiKey', res.product.apiKey); } catch (e) {}",
                ]),
            `console.log('${apiKeyVar}=', res.product.apiKey);`,
          ],
        },
      },
    ],
  };
}

function patchMetadata(org) {
  const body = metadataBody(org.issuerDisplay, org.credentialConfigs);
  const configId = Object.keys(org.credentialConfigs)[0];
  return {
    name: `02.${org.key} — PATCH metadata display completa (${org.title})`,
    request: {
      method: 'PATCH',
      header: issuerHeaders(org.issuerApiKeyVar),
      body: { mode: 'raw', raw: JSON.stringify(body, null, 2) },
      url: `{{issuerBaseUrl}}/v1/issuers/{{${org.issuerIdVar}}}/records/metadata`,
      description:
        'Publica display del emisor y de la credencial. Crea el OpenId4VcIssuerRecord si faltaba (upsert).',
    },
    event: [
      {
        listen: 'test',
        script: {
          type: 'text/javascript',
          exec: [
            "pm.test('Metadata 2xx', () => pm.response.to.be.success);",
            `console.log('Patched ${org.title} / ${configId}');`,
          ],
        },
      },
    ],
  };
}

function getWellKnown(org) {
  const configId = Object.keys(org.credentialConfigs)[0];
  return {
    name: `02.${org.key}b — GET well-known (verificar display)`,
    request: {
      method: 'GET',
      url: `{{issuerBaseUrl}}/openid4vc-flow/{{${org.issuerIdVar}}}/.well-known/openid-credential-issuer`,
      description: 'Sin API key. Debe traer logo del issuer + background_image de la credencial.',
      auth: { type: 'noauth' },
    },
    event: [
      {
        listen: 'test',
        script: {
          type: 'text/javascript',
          exec: [
            'const res = pm.response.json();',
            `const configId = '${configId}';`,
            'const issuerDisplay = res.display?.[0];',
            'const credDisplay = res.credential_configurations_supported?.[configId]?.display?.[0];',
            "pm.test('Issuer display.name', () => pm.expect(issuerDisplay?.name).to.be.a('string').and.not.empty);",
            "pm.test('Issuer display.logo.uri (.png/.jpg)', () => {",
            "  const uri = issuerDisplay?.logo?.uri || '';",
            "  pm.expect(uri).to.match(/\\.(png|jpe?g|webp)(\\?|$)/i);",
            '});',
            "pm.test('Credential display.background_image.uri', () => {",
            "  pm.expect(credDisplay?.background_image?.uri).to.be.a('string').and.not.empty;",
            '});',
            "pm.test('Credential display colors', () => {",
            "  pm.expect(credDisplay?.background_color).to.be.a('string');",
            "  pm.expect(credDisplay?.text_color).to.be.a('string');",
            '});',
            "pm.test('Claims metadata', () => {",
            "  const claims = res.credential_configurations_supported?.[configId]?.claims;",
            "  pm.expect(claims).to.be.an('object');",
            '});',
          ],
        },
      },
    ],
  };
}

function patchVerifier(org) {
  return {
    name: `02.${org.key}c — PATCH verifier client_name`,
    request: {
      method: 'PATCH',
      header: verifierHeaders(org.verifierApiKeyVar),
      body: {
        mode: 'raw',
        raw: JSON.stringify({ clientMetadata: { client_name: org.verifierClientName } }, null, 2),
      },
      url: `{{verifierBaseUrl}}/v1/verifiers/{{${org.verifierIdVar}}}/records/metadata`,
      description: 'Nombre amigable del verificador en OID4VP.',
    },
    event: [
      {
        listen: 'test',
        script: {
          type: 'text/javascript',
          exec: [
            "pm.test('Verifier metadata 2xx o 404 skip', () => pm.expect(pm.response.code).to.be.oneOf([200, 201, 204, 404]));",
          ],
        },
      },
    ],
  };
}

function offerRequest(org, cred) {
  return {
    name: `Emisión — POST offer ${cred.label} + QR`,
    request: {
      method: 'POST',
      header: issuerHeaders(org.issuerApiKeyVar),
      body: {
        mode: 'raw',
        raw: JSON.stringify(
          {
            credentialConfigurationId: cred.configId,
            vct: cred.vct,
            claims: cred.claims,
            claimsDisplay: cred.claimsDisplay,
            disclosureFrame: { _sd: cred.sd },
          },
          null,
          2,
        ),
      },
      url: `{{issuerBaseUrl}}/v1/issuers/{{${org.issuerIdVar}}}/openid4vc/offer`,
      description: 'Tras **Send** → pestaña **Visualize** (Postman Desktop) para ver el QR.',
    },
    event: [{ listen: 'test', script: { type: 'text/javascript', exec: qrOfferExec(cred) } }],
  };
}

function requestDcql(org, cred) {
  return {
    name: `Verificación — POST request DCQL ${cred.label} + QR`,
    request: {
      method: 'POST',
      header: verifierHeaders(org.verifierApiKeyVar),
      body: {
        mode: 'raw',
        raw: JSON.stringify(
          {
            dcqlQuery: {
              credentials: [
                {
                  id: cred.configId,
                  format: 'dc+sd-jwt',
                  meta: { vct_values: [cred.vct] },
                  claims: cred.dcqlClaims.map((path) => ({ path: [path] })),
                },
              ],
            },
            responseMode: 'direct_post',
            requestSignerMethod: 'did',
          },
          null,
          2,
        ),
      },
      url: `{{verifierBaseUrl}}/v1/verifiers/{{${org.verifierIdVar}}}/openid4vc/request`,
      description: 'Tras **Send** → pestaña **Visualize** para presentar en wallet.',
    },
    event: [{ listen: 'test', script: { type: 'text/javascript', exec: qrRequestExec(cred) } }],
  };
}

function sessionDone(org, cred) {
  return {
    name: `Resultado — GET session ${cred.label}`,
    request: {
      method: 'GET',
      header: [{ key: 'X-API-Key', value: `{{${org.verifierApiKeyVar}}}` }],
      url: `{{verifierBaseUrl}}/v1/verifiers/{{${org.verifierIdVar}}}/openid4vc/session/{{${cred.key}VerificationSessionId}}`,
      description: 'Tras presentar en wallet. Decode SD-JWT en consola.',
    },
    event: [{ listen: 'test', script: { type: 'text/javascript', exec: VP_DECODE.split('\n') } }],
  };
}

function buildOrgFolder(orgKey, folderNum) {
  const org = ORGS[orgKey];
  const credFlows = org.credentials.map((cred, idx) => {
    const letter = String.fromCharCode(65 + idx);
    return {
      name: `${folderNum}.${letter} ${cred.label}`,
      description: `Emisión y verificación de ${cred.label}.`,
      item: [
        offerRequest(org, cred),
        walletPause(`[WALLET] Escanear offer ${cred.label}`, `${cred.key}OfferUri`),
        requestDcql(org, cred),
        walletPause(`[WALLET] Presentar ${cred.label}`, `${cred.key}RequestUri`),
        sessionDone(org, cred),
      ],
    };
  });

  return {
    name: `${folderNum} - ${org.title}`,
    description: `Emisor \`{{${org.issuerIdVar}}}\` · Verificador \`{{${org.verifierIdVar}}}\`.`,
    item: credFlows,
  };
}

const collection = {
  info: {
    name: 'Kuatia — Demo Club · Recital · Constructora Andes',
    _postman_id: 'a7c3e9d1-5b2f-4e8a-9c1d-6f4b0a2e8d55',
    description: `Demo Kuatia con **3 emisores** y metadata visual completa:

1. **Club Norte** — \`membership_card\` / \`MembershipCredential\`
2. **Recital Live** — \`recital_ticket\` / \`RecitalTicketCredential\`
3. **Constructora Andes** — \`machinery_operator_cert\` / \`HeavyMachineryOperatorCredential\` (habilitación **interna** de empresa; sin validez ante terceros)

**Environment:** \`Kuatia-Local-Docker.postman_environment.json\` (o Prod).

**Auth:** Billing JWT + \`X-API-Key\` en issuer/verifier (no usa API Gateway).

**Imágenes:** logo de marca + fondo corporativo/sede (ver \`postman/assets/demo-credentials/README.md\`). Sin fotos de maquinaria en display.

**QR:** pestaña **Visualize** tras offer y request DCQL.

Orden: \`00\` auth → \`01\` productos (6: plan pro_double) → \`02\` PATCH metadata + well-known → \`03\` Club → \`04\` Recital → \`05\` Andes.`,
    schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
  },
  variable: [
    { key: 'billingBaseUrl', value: 'http://localhost:9000' },
    { key: 'issuerBaseUrl', value: 'http://localhost:9001' },
    { key: 'verifierBaseUrl', value: 'http://localhost:9002' },
    { key: 'adminApiKey', value: 'dev-admin-change-me' },
    { key: 'email', value: 'demo-club-recital-andes@kuatia.local' },
    { key: 'password', value: 'password123' },
    { key: 'accessToken', value: '' },
    { key: 'accountId', value: '' },
    { key: 'clubIssuerId', value: 'club-norte' },
    { key: 'clubVerifierId', value: 'club-norte' },
    { key: 'clubIssuerApiKey', value: '' },
    { key: 'clubVerifierApiKey', value: '' },
    { key: 'recitalIssuerId', value: 'recital-live' },
    { key: 'recitalVerifierId', value: 'recital-live' },
    { key: 'recitalIssuerApiKey', value: '' },
    { key: 'recitalVerifierApiKey', value: '' },
    { key: 'andesIssuerId', value: 'constructora-andes' },
    { key: 'andesVerifierId', value: 'constructora-andes' },
    { key: 'andesIssuerApiKey', value: '' },
    { key: 'andesVerifierApiKey', value: '' },
    { key: 'issuerId', value: 'club-norte' },
    { key: 'verifierId', value: 'club-norte' },
    { key: 'issuerApiKey', value: '' },
    { key: 'verifierApiKey', value: '' },
  ],
  item: [
    {
      name: '00 - Auth Billing',
      description: 'Register (opcional) + login. Guarda JWT y accountId.',
      item: [
        {
          name: '00.1 GET /health',
          request: { method: 'GET', url: '{{billingBaseUrl}}/health' },
        },
        {
          name: '00.2 POST /v1/auth/register',
          request: {
            method: 'POST',
            header: [{ key: 'Content-Type', value: 'application/json' }],
            body: {
              mode: 'raw',
              raw: JSON.stringify(
                {
                  email: '{{email}}',
                  password: '{{password}}',
                  name: 'Demo Club Recital Andes',
                },
                null,
                2,
              ),
            },
            url: '{{billingBaseUrl}}/v1/auth/register',
            description: 'Si el email ya existe, seguir con login (409 ok).',
          },
          event: [
            {
              listen: 'test',
              script: {
                type: 'text/javascript',
                exec: [
                  "pm.test('Register ok o ya existe', () => pm.expect(pm.response.code).to.be.oneOf([200, 201, 409]));",
                  'if (pm.response.code === 200 || pm.response.code === 201) {',
                  '  const res = pm.response.json();',
                  '  if (res.accessToken) {',
                  "    pm.collectionVariables.set('accessToken', res.accessToken);",
                  "    try { pm.environment.set('accessToken', res.accessToken); } catch (e) {}",
                  '  }',
                  '  if (res.account?.id) {',
                  "    pm.collectionVariables.set('accountId', res.account.id);",
                  "    try { pm.environment.set('accountId', res.account.id); } catch (e) {}",
                  '  }',
                  '}',
                ],
              },
            },
          ],
        },
        {
          name: '00.3 POST /v1/auth/login',
          request: {
            method: 'POST',
            header: [{ key: 'Content-Type', value: 'application/json' }],
            body: {
              mode: 'raw',
              raw: JSON.stringify(
                { email: '{{email}}', password: '{{password}}' },
                null,
                2,
              ),
            },
            url: '{{billingBaseUrl}}/v1/auth/login',
          },
          event: [
            {
              listen: 'test',
              script: {
                type: 'text/javascript',
                exec: [
                  'const res = pm.response.json();',
                  "pm.test('Login 200', () => pm.response.to.have.status(200));",
                  'if (res.accessToken) {',
                  "  pm.collectionVariables.set('accessToken', res.accessToken);",
                  "  try { pm.environment.set('accessToken', res.accessToken); } catch (e) {}",
                  '}',
                  'if (res.account?.id) {',
                  "  pm.collectionVariables.set('accountId', res.account.id);",
                  "  try { pm.environment.set('accountId', res.account.id); } catch (e) {}",
                  '}',
                ],
              },
            },
          ],
        },
        {
          name: '00.4 POST admin set plan → pro_double',
          request: {
            method: 'POST',
            header: [
              { key: 'Content-Type', value: 'application/json' },
              { key: 'X-Admin-Key', value: '{{adminApiKey}}' },
            ],
            body: { mode: 'raw', raw: JSON.stringify({ plan: 'pro_double' }, null, 2) },
            url: '{{billingBaseUrl}}/v1/admin/accounts/{{accountId}}/plan',
            description:
              'Free=2, Pro=5; este demo crea 6 productos (3 issuers + 3 verifiers) → plan pro_double (10).',
          },
          event: [
            {
              listen: 'test',
              script: {
                type: 'text/javascript',
                exec: [
                  "pm.test('Plan pro_double', () => pm.expect(pm.response.code).to.be.oneOf([200, 201]));",
                ],
              },
            },
          ],
        },
      ],
    },
    {
      name: '01 - Productos (billing)',
      description:
        'Crea issuer+verifier para Club Norte, Recital Live y Constructora Andes. Guarda API keys.',
      item: [
        productCreate(ORGS.club, 'issuer'),
        productCreate(ORGS.club, 'verifier'),
        productCreate(ORGS.recital, 'issuer'),
        productCreate(ORGS.recital, 'verifier'),
        productCreate(ORGS.andes, 'issuer'),
        productCreate(ORGS.andes, 'verifier'),
      ],
    },
    {
      name: '02 - Metadata visual (issuer + verifier)',
      description:
        'PATCH display completo (issuer + credential + claims) y verificación del well-known.',
      item: [
        patchMetadata(ORGS.club),
        getWellKnown(ORGS.club),
        patchVerifier(ORGS.club),
        patchMetadata(ORGS.recital),
        getWellKnown(ORGS.recital),
        patchVerifier(ORGS.recital),
        patchMetadata(ORGS.andes),
        getWellKnown(ORGS.andes),
        patchVerifier(ORGS.andes),
      ],
    },
    buildOrgFolder('club', '03'),
    buildOrgFolder('recital', '04'),
    buildOrgFolder('andes', '05'),
  ],
};

writeFileSync(outPath, JSON.stringify(collection, null, 2));
console.log('Written:', outPath);
