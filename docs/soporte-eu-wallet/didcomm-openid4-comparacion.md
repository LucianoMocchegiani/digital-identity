"""
# DID en OpenID4VC vs DIDComm  
## Funcionamiento en flujos de emisión, verificación y autenticación

---

#  Introducción

En sistemas de identidad descentralizada (SSI), los DID (Decentralized Identifiers) cumplen distintos roles dependiendo del protocolo utilizado.

- OpenID4VC (VCI + VP) → modelo web basado en OAuth2  
- DIDComm → modelo peer-to-peer basado en mensajería cifrada  

---

# DID en OpenID4VC (VCI + VP)

## Rol del DID

En OpenID4VC, el DID cumple funciones criptográficas, pero no de transporte.

### Funciones principales

1. Identidad del holder
{
  "sub": "did:key:z6Mk..."
}

2. Firma (Proof of Possession)
{
  "proof": {
    "verificationMethod": "did:key:...#key-1",
    "proofPurpose": "authentication"
  }
}

3. Binding de credenciales
{
  "credentialSubject": {
    "id": "did:key:..."
  }
}

---

## Qué NO hace el DID

- No establece conexiones  
- No cifra el canal  
- No define transporte  

Todo eso lo maneja:
- HTTPS  
- OAuth2  

---

# Flujo de EMISIÓN (OpenID4VCI)

1. Issuer genera credential_offer (URL / QR)  
2. Wallet recibe el offer  
3. Wallet obtiene metadata del issuer  
4. OAuth2 → obtiene access_token  
5. Wallet envía request con proof (DID)  
6. Issuer emite VC  

DID = identidad + firma  

---

# Flujo de VERIFICACIÓN (OpenID4VP)

1. Verifier genera request  
2. Wallet procesa request  
3. Usuario selecciona credenciales  
4. Wallet crea VP firmada con DID  
5. Verifier valida  

---

# OAuth2 en OpenID4VC

OAuth2 se usa para:

- autorización  
- emisión de tokens  
- control de acceso  

Flujo:

1. Wallet pide token  
2. Issuer responde con access_token  
3. Wallet usa token para pedir credencial  

OAuth2 = acceso  
DID = identidad  

---

# DID en DIDComm

## Rol del DID

En DIDComm, el DID es el núcleo del sistema.

Funciones:

- Identidad  
- Canal de comunicación  
- Cifrado  
- Descubrimiento de endpoints  
- Relación persistente  

---

## DID Document

{
  "service": [
    {
      "type": "DIDCommMessaging",
      "serviceEndpoint": "https://example.com"
    }
  ]
}

---

## Uso de claves

- Encriptación end-to-end  
- Firma de mensajes  
- Autenticación  

---

# Flujo de EMISIÓN (DIDComm)

1. Se establece conexión DID  
2. Issuer → offer-credential  
3. Holder → request-credential  
4. Issuer → issue-credential  
5. Holder → ack  

Flujo conversacional  

---

# Flujo de VERIFICACIÓN (DIDComm)

1. Verifier → request-presentation  
2. Holder → presentation  
3. Verifier valida  
4. Verifier → ack  

---

# Autenticación en DIDComm

No usa OAuth2  

Se basa en:

- criptografía  
- control de claves  
- mensajes firmados  

Proceso:

1. Intercambio de DIDs  
2. Resolución de DID Document  
3. Uso de claves públicas  
4. Mensajes cifrados  

---

# Comparación OAuth2 vs DIDComm

- OAuth2:
  - Cliente-servidor  
  - Tokens  
  - HTTPS  
  - Stateless  

- DIDComm:
  - Peer-to-peer  
  - Criptografía  
  - Mensajes cifrados  
  - Stateful  

---

# Diferencia clave

OpenID4VC:
- DID = identidad + firma  
- OAuth2 = autorización  
- HTTP = transporte  

DIDComm:
- DID = identidad + transporte + cifrado  
- Sin OAuth2  

---

# TL;DR

OpenID4VC:
- Simple  
- Web-friendly  
- Stateless  

DIDComm:
- Complejo  
- Descentralizado  
- Conversacional  

"""