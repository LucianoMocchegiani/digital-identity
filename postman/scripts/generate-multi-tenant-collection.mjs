import { writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const outPath = join(__dirname, '..', 'Quark-Demo-Multi-tenant.postman_collection.json');

const IMG = {
  gcbaLogo:
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRXbjs3IhZt2tEJagspHtTDiyGgRWSNUAH-chZHHkrNl9y3otWnhMT4z4g&s=10',
  gcbaCitizenBg:
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Flag_of_Argentina.svg/1280px-Flag_of_Argentina.svg.png',
  gcbaEmpleadoBg:
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Casa_rosada_2005.jpg/1280px-Casa_rosada_2005.jpg',
  uadeLogo:
    'https://studentstreet.club/assets/cdn/pp/argentine-university-of-enterprise-logo.jpg',
  uadeBg:
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/UADE_desde_9_de_julio_e_independencia.jpg/1280px-UADE_desde_9_de_julio_e_independencia.jpg',
  iomaLogo:
    'https://pbs.twimg.com/profile_images/1917591951513116673/b4ygbg9M.jpg',
  iomaBg:
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Flag_of_Argentina.svg/1280px-Flag_of_Argentina.svg.png',
  renaperLogo:
    'https://upload.wikimedia.org/wikipedia/commons/5/51/Renaper_%28logotipo%29.png',
  renaperBg:
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Escarapela_wiki.svg/1280px-Escarapela_wiki.svg.png',
};

function displayBlock({ name, bgColor, textColor, logoUrl, logoAlt, bgImageUrl }) {
  return {
    name,
    locale: 'es',
    background_color: bgColor,
    text_color: textColor,
    logo: { uri: logoUrl, alt_text: logoAlt },
    background_image: { uri: bgImageUrl },
  };
}

function credConfig(id, vct, display) {
  return {
    [id]: {
      format: 'dc+sd-jwt',
      vct,
      cryptographic_binding_methods_supported: ['did:jwk', 'jwk'],
      credential_signing_alg_values_supported: ['ES256'],
      proof_types_supported: {
        jwt: { proof_signing_alg_values_supported: ['ES256'] },
      },
      display: [display],
    },
  };
}

function issuerBody(issuerId, issuerName, issuerDisplay, credentialConfigs) {
  return {
    issuerId,
    oid4vc: {
      display: [issuerDisplay],
      dpopSigningAlgValuesSupported: ['ES256'],
      credentialConfigurationsSupported: credentialConfigs,
    },
  };
}

const ORGS = {
  gcba: {
    issuerId: 'gcba-issuer',
    verifierId: 'gcba-verifier',
    issuerName: 'GCBA',
    issuerBody: issuerBody(
      'gcba-issuer',
      'GCBA',
      displayBlock({
        name: 'Gobierno de la Ciudad de Buenos Aires',
        bgColor: '#153244',
        textColor: '#FFFFFF',
        logoUrl: IMG.gcbaLogo,
        logoAlt: 'GCBA',
        bgImageUrl: IMG.gcbaCitizenBg,
      }),
      {
        ...credConfig(
          'citizen_card_gcba',
          'CitizenCardGCBA',
          displayBlock({
            name: 'Ciudadano GCBA',
            bgColor: '#153244',
            textColor: '#000000',
            logoUrl: IMG.gcbaLogo,
            logoAlt: 'GCBA',
            bgImageUrl: IMG.gcbaCitizenBg,
          }),
        ),
        ...credConfig(
          'empleado_card_gcba',
          'EmpleadoCardGCBA',
          displayBlock({
            name: 'Empleado GCBA',
            bgColor: '#1A3A52',
            textColor: '#FFFFFF',
            logoUrl: IMG.gcbaLogo,
            logoAlt: 'GCBA',
            bgImageUrl: IMG.gcbaEmpleadoBg,
          }),
        ),
      },
    ),
    verifierClientName: 'GCBA Verifier',
    credentials: [
      {
        key: 'gcbaCitizen',
        label: 'CitizenCardGCBA',
        configId: 'citizen_card_gcba',
        vct: 'CitizenCardGCBA',
        claims: {
          nombre: 'María',
          apellido: 'González',
          dni: '30123456',
          cuil: '27301234568',
          domicilio: 'CABA',
        },
        sd: ['dni', 'cuil', 'domicilio'],
        dcqlClaims: ['nombre', 'apellido', 'dni', 'cuil'],
      },
      {
        key: 'gcbaEmpleado',
        label: 'EmpleadoCardGCBA',
        configId: 'empleado_card_gcba',
        vct: 'EmpleadoCardGCBA',
        claims: {
          nombre: 'Carlos',
          legajo: 'GCBA-8842',
          area: 'Modernización',
          cargo: 'Analista',
          email: 'carlos@buenosaires.gob.ar',
        },
        sd: ['legajo', 'email'],
        dcqlClaims: ['nombre', 'legajo', 'area', 'cargo'],
      },
    ],
  },
  uade: {
    issuerId: 'uade-issuer',
    verifierId: 'uade-verifier',
    issuerBody: issuerBody(
      'uade-issuer',
      'UADE',
      displayBlock({
        name: 'Universidad Argentina de la Empresa',
        bgColor: '#1B2A4A',
        textColor: '#FFFFFF',
        logoUrl: IMG.uadeLogo,
        logoAlt: 'UADE',
        bgImageUrl: IMG.uadeBg,
      }),
      credConfig(
        'estudiante_card_uade',
        'EstudianteCardUADE',
        displayBlock({
          name: 'Estudiante UADE',
          bgColor: '#1B2A4A',
          textColor: '#FFFFFF',
          logoUrl: IMG.uadeLogo,
          logoAlt: 'UADE',
          bgImageUrl: IMG.uadeBg,
        }),
      ),
    ),
    verifierClientName: 'UADE Verifier',
    credentials: [
      {
        key: 'uadeEstudiante',
        label: 'EstudianteCardUADE',
        configId: 'estudiante_card_uade',
        vct: 'EstudianteCardUADE',
        claims: {
          nombre: 'Lucía',
          legajo: 'UADE-2026042',
          carrera: 'Ingeniería en Informática',
          facultad: 'Ingeniería',
          anio: '3',
        },
        sd: ['legajo', 'carrera'],
        dcqlClaims: ['nombre', 'legajo', 'carrera', 'facultad'],
      },
    ],
  },
  ioma: {
    issuerId: 'ioma-issuer',
    verifierId: 'ioma-verifier',
    issuerBody: issuerBody(
      'ioma-issuer',
      'IOMA',
      displayBlock({
        name: 'IOMA — Obra Social Provincia de Buenos Aires',
        bgColor: '#006837',
        textColor: '#FFFFFF',
        logoUrl: IMG.iomaLogo,
        logoAlt: 'IOMA',
        bgImageUrl: IMG.iomaBg,
      }),
      credConfig(
        'afiliado_card_ioma',
        'AfiliadoCardIOMA',
        displayBlock({
          name: 'Afiliado IOMA',
          bgColor: '#006837',
          textColor: '#FFFFFF',
          logoUrl: IMG.iomaLogo,
          logoAlt: 'IOMA',
          bgImageUrl: IMG.iomaBg,
        }),
      ),
    ),
    verifierClientName: 'IOMA Verifier',
    credentials: [
      {
        key: 'iomaAfiliado',
        label: 'AfiliadoCardIOMA',
        configId: 'afiliado_card_ioma',
        vct: 'AfiliadoCardIOMA',
        claims: {
          nombre: 'Roberto',
          dni: '28456789',
          numeroAfiliado: 'IOMA-982341',
          plan: 'Plan Integral',
          vigencia: '2026-12-31',
        },
        sd: ['dni', 'numeroAfiliado'],
        dcqlClaims: ['nombre', 'dni', 'numeroAfiliado', 'plan'],
      },
    ],
  },
  renaper: {
    issuerId: 'renaper-issuer',
    verifierId: 'renaper-verifier',
    /** EUDI Wallet: verificación con x5c (ver docs/soporte-eu-wallet/quark-verifier-x5c.md). */
    requestSignerMethod: 'x5c',
    issuerBody: issuerBody(
      'renaper-issuer',
      'RENAPER',
      displayBlock({
        name: 'Registro Nacional de las Personas',
        bgColor: '#003366',
        textColor: '#FFFFFF',
        logoUrl: IMG.renaperLogo,
        logoAlt: 'RENAPER',
        bgImageUrl: IMG.renaperBg,
      }),
      credConfig(
        'pasaporte_ciudadano_renaper',
        'PasaporteCiudadanoCardRENAPER',
        displayBlock({
          name: 'Pasaporte Ciudadano',
          bgColor: '#003366',
          textColor: '#FFFFFF',
          logoUrl: IMG.renaperLogo,
          logoAlt: 'RENAPER',
          bgImageUrl: IMG.renaperBg,
        }),
      ),
    ),
    verifierClientName: 'RENAPER Verifier',
    credentials: [
      {
        key: 'renaperPasaporte',
        label: 'PasaporteCiudadanoCardRENAPER',
        configId: 'pasaporte_ciudadano_renaper',
        vct: 'PasaporteCiudadanoCardRENAPER',
        claims: {
          nombre: 'Ana',
          apellido: 'Martínez',
          dni: '35123456',
          nacionalidad: 'ARG',
          numeroPasaporte: 'AAA123456',
          fechaEmision: '2026-01-10',
          fechaVencimiento: '2031-01-10',
        },
        sd: ['dni', 'numeroPasaporte', 'fechaEmision', 'fechaVencimiento'],
        dcqlClaims: ['nombre', 'apellido', 'dni', 'numeroPasaporte', 'nacionalidad'],
      },
    ],
  },
};

/** Scripts Test + Visualize QR (mismo patrón que Quark-Flujos-DIDComm-OID4VC). */
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

function authHeader() {
  return [{ key: 'Authorization', value: 'Bearer {{accessToken}}' }];
}

function jsonHeader() {
  return [
    { key: 'Content-Type', value: 'application/json' },
    { key: 'Authorization', value: 'Bearer {{accessToken}}' },
  ];
}

function getRequest(name, url, description, execLines) {
  return {
    name,
    request: { method: 'GET', header: authHeader(), url, description },
    event: execLines
      ? [{ listen: 'test', script: { type: 'text/javascript', exec: execLines } }]
      : undefined,
  };
}

function postRequest(name, url, body, description, execLines) {
  return {
    name,
    request: {
      method: 'POST',
      header: jsonHeader(),
      body: { mode: 'raw', raw: JSON.stringify(body, null, 2) },
      url,
      description,
    },
    event: execLines
      ? [{ listen: 'test', script: { type: 'text/javascript', exec: execLines } }]
      : undefined,
  };
}

function walletPause(name, uriVar) {
  return {
    name,
    request: {
      method: 'GET',
      url: '{{gatewayBaseUrl}}/v1/health',
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
            `console.log('URI:', pm.variables.get('${uriVar}'));`,
          ],
        },
      },
    ],
  };
}

function offerRequest(org, cred) {
  return postRequest(
    `Emisión — POST offer ${cred.label} + QR`,
    `{{gatewayBaseUrl}}/v1/issuers/${org.issuerId}/openid4vc/offer`,
    {
      credentialConfigurationId: cred.configId,
      vct: cred.vct,
      claims: cred.claims,
      disclosureFrame: { _sd: cred.sd },
    },
    'Tras **Send** → pestaña **Visualize** (Postman Desktop) para ver el QR.',
    qrOfferExec(cred),
  );
}

function requestDcql(org, cred) {
  const signer = org.requestSignerMethod ?? 'did';
  const signerNote =
    signer === 'x5c'
      ? 'Usa `requestSignerMethod: x5c` (EUDI Wallet + `local/certs` / `OID4VP_X5C_*` en verifier). '
      : '';
  return postRequest(
    `Verificación — POST request DCQL ${cred.label} + QR`,
    `{{gatewayBaseUrl}}/v1/verifiers/${org.verifierId}/openid4vc/request`,
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
      requestSignerMethod: signer,
    },
    `${signerNote}Tras **Send** → pestaña **Visualize** (Postman Desktop) para ver el QR.`,
    qrRequestExec(cred),
  );
}

function sessionDone(org, cred) {
  return getRequest(
    `Resultado — GET session ${cred.label}`,
    `{{gatewayBaseUrl}}/v1/verifiers/${org.verifierId}/openid4vc/session/{{${cred.key}VerificationSessionId}}`,
    'Tras presentar en wallet. Decode SD-JWT en consola.',
    VP_DECODE.split('\n'),
  );
}

function buildOrgFolder(orgKey, folderNum, folderTitle) {
  const org = ORGS[orgKey];
  const credFlows = org.credentials.flatMap((cred, idx) => {
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
    name: `${folderNum} - ${folderTitle}`,
    description: `Emisor \`${org.issuerId}\` · Verificador \`${org.verifierId}\`.`,
    item: credFlows,
  };
}

const provisionItems = [
  {
    name: '01.0 [INFO] Auth SCI — tenant admin (seed)',
    request: {
      method: 'GET',
      url: '{{gatewayBaseUrl}}/v1/health',
      description:
        'No hace falta crear tenant SCI: usar `admin` / `admin-dev-secret` en carpeta 00. Opcional: POST /v1/auth/tenants con Bearer admin.',
    },
  },
  {
    name: '01.0b POST /v1/domain-key (x5c EUDI — verifier directo)',
    request: {
      method: 'POST',
      header: [{ key: 'Content-Type', value: 'application/json' }],
      body: {
        mode: 'raw',
        raw: JSON.stringify(
          {
            keyId: '{{x5cLeafCertificateKeyId}}',
            privateJwk: {
              kty: 'EC',
              crv: 'P-256',
              x: '{{x5cPrivateJwkX}}',
              y: '{{x5cPrivateJwkY}}',
              d: '{{x5cPrivateJwkD}}',
            },
          },
          null,
          2,
        ),
      },
      url: '{{verifierBaseUrl}}/v1/domain-key',
      description:
        '**Una vez por deploy/DB limpia.** Importa la clave de `local/certs/quark-verifier.key` al KMS (`domain-key`). Directo al verifier (`verifierBaseUrl`), sin gateway ni JWT.\n\nCompletar en environment: `x5cPrivateJwkX`, `x5cPrivateJwkY`, `x5cPrivateJwkD` (secret). Ver `docs/soporte-eu-wallet/quark-verifier-x5c.md`.',
    },
    event: [
      {
        listen: 'test',
        script: {
          type: 'text/javascript',
          exec: [
            "pm.test('Status 200/201', () => pm.expect(pm.response.code).to.be.oneOf([200, 201]));",
            'const res = pm.response.json();',
            "pm.test('keyId', () => pm.expect(res.keyId).to.be.a('string'));",
            "console.log('domain-key:', res.keyId);",
          ],
        },
      },
    ],
  },
  ...Object.entries(ORGS).flatMap(([key, org], i) => {
    const letter = String.fromCharCode(65 + i);
    const title = key.toUpperCase();
    return [
      postRequest(
        `01.${letter}1 POST issuer ${title} (display PNG/JPG)`,
        '{{gatewayBaseUrl}}/v1/issuers',
        org.issuerBody,
        `Alta emisor con logo y background_image en cada credentialConfiguration (solo .png/.jpg).`,
        [
          'if (pm.response.code === 200 || pm.response.code === 201) {',
          '  const res = pm.response.json();',
          `  if (res.did) console.log('${org.issuerId} did:', res.did);`,
          '}',
          "pm.test('Issuer provisionado o ya existe', () => pm.expect(pm.response.code).to.be.oneOf([200, 201, 409]));",
        ],
      ),
      postRequest(
        `01.${letter}2 POST verifier ${title}`,
        '{{gatewayBaseUrl}}/v1/verifiers',
        {
          verifierId: org.verifierId,
          oid4vp: { clientMetadata: { client_name: org.verifierClientName } },
        },
        `Alta verificador ${org.verifierId}.`,
        [
          "pm.test('Verifier provisionado o ya existe', () => pm.expect(pm.response.code).to.be.oneOf([200, 201, 409]));",
        ],
      ),
    ];
  }),
];

const collection = {
  info: {
    name: 'QuarkID 2.0 - Demo Multi-tenant GCBA · UADE · IOMA · RENAPER',
    _postman_id: 'e5f8a1b4-3c6d-7e9f-b5a2-0d6e9f8c4b73',
    description: `Demo multi-organización vía **API Gateway** + **identity-wallet** (sin holder en Postman).

**5 credenciales · 4 emisores:** GCBA (Ciudadano + Empleado), UADE, IOMA, RENAPER.

**Environment:** \`Quark-Demo-Gateway.postman_environment.json\`

**Imágenes:** logo y \`background_image\` en PNG/JPG en los bodies de \`POST /v1/issuers\`. Ver \`postman/assets/demo-credentials/README.md\`.

**QR:** pestaña **Visualize** tras offer y request DCQL.

Orden: \`00\` setup → \`01\` provision (incl. \`01.0b domain-key\` para x5c EUDI) → carpetas \`02-05\` por org → \`06\` auditoría.`,
    schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
  },
  variable: [
    { key: 'gatewayBaseUrl', value: 'http://localhost:3000' },
    { key: 'verifierBaseUrl', value: 'http://localhost:9002' },
    { key: 'clientId', value: 'admin' },
    { key: 'clientSecret', value: 'admin-dev-secret' },
    { key: 'accessToken', value: '' },
    { key: 'tenantId', value: 'admin' },
    { key: 'x5cLeafCertificateKeyId', value: 'quark-verifier-key-1' },
    { key: 'x5cPrivateJwkX', value: '' },
    { key: 'x5cPrivateJwkY', value: '' },
    { key: 'x5cPrivateJwkD', value: '' },
  ],
  event: [
    {
      listen: 'prerequest',
      script: {
        type: 'text/javascript',
        exec: [
          "let cid = pm.environment.get('correlationId') || pm.collectionVariables.get('correlationId');",
          'if (!cid) {',
          "  cid = pm.variables.replaceIn('{{$guid}}');",
          "  try { pm.environment.set('correlationId', cid); } catch (e) {}",
          "  pm.collectionVariables.set('correlationId', cid);",
          '}',
          "pm.request.headers.upsert({ key: 'x-correlation-id', value: cid });",
        ],
      },
    },
  ],
  item: [
    {
      name: '00 - Setup Gateway',
      item: [
        {
          name: '00.1 Reiniciar correlationId',
          request: { method: 'GET', url: '{{gatewayBaseUrl}}/v1/health' },
          event: [
            {
              listen: 'test',
              script: {
                type: 'text/javascript',
                exec: [
                  "const cid = pm.variables.replaceIn('{{$guid}}');",
                  "try { pm.environment.set('correlationId', cid); } catch (e) {}",
                  "pm.collectionVariables.set('correlationId', cid);",
                ],
              },
            },
          ],
        },
        {
          name: '00.2 GET /v1/health/ready',
          request: { method: 'GET', url: '{{gatewayBaseUrl}}/v1/health/ready' },
        },
        {
          name: '00.3 POST /v1/auth/token (admin)',
          request: {
            method: 'POST',
            header: [{ key: 'Content-Type', value: 'application/json' }],
            body: {
              mode: 'raw',
              raw: JSON.stringify(
                {
                  clientId: '{{clientId}}',
                  clientSecret: '{{clientSecret}}',
                  scopes: ['dids:read', 'dids:write', 'tenants:read'],
                },
                null,
                2,
              ),
            },
            url: '{{gatewayBaseUrl}}/v1/auth/token',
          },
          event: [
            {
              listen: 'test',
              script: {
                type: 'text/javascript',
                exec: [
                  'const body = pm.response.json();',
                  'if (body.access_token) {',
                  "  try { pm.environment.set('accessToken', body.access_token); } catch (e) {}",
                  "  pm.collectionVariables.set('accessToken', body.access_token);",
                  '}',
                ],
              },
            },
          ],
        },
      ],
    },
    {
      name: '01 - Provisionamiento identidades',
      description: 'Alta de issuers (con display visual) y verifiers por organización.',
      item: provisionItems,
    },
    buildOrgFolder('gcba', '02', 'GCBA'),
    buildOrgFolder('uade', '03', 'UADE'),
    buildOrgFolder('ioma', '04', 'IOMA'),
    buildOrgFolder('renaper', '05', 'RENAPER'),
    {
      name: '06 - Auditoría global',
      item: [
        getRequest(
          '06.1 GET events por correlationId',
          '{{gatewayBaseUrl}}/v1/operations/events?correlationId={{correlationId}}',
          null,
          ["pm.test('Status 200', () => pm.response.to.have.status(200));"],
        ),
        getRequest('06.2 GET events', '{{gatewayBaseUrl}}/v1/operations/events'),
        getRequest(
          '06.3 GET usage/summary',
          '{{gatewayBaseUrl}}/v1/operations/usage/summary?tenantId={{tenantId}}&limit=100&windowMs=300000',
        ),
        getRequest('06.4 GET /v1/metrics/json', '{{gatewayBaseUrl}}/v1/metrics/json'),
        getRequest(
          '06.5 GET resolve gcba-issuer did',
          '{{gatewayBaseUrl}}/v1/dids/resolve/did:web:localhost%3A9001:gcba-issuer',
          'Ajustar DID si usás tunnel.',
        ),
      ],
    },
  ],
};

writeFileSync(outPath, JSON.stringify(collection, null, 2));
console.log('Written:', outPath);
