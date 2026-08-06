# Requisitos del Holder — eIDAS 2.0

## ¿De qué trata esto?

**eIDAS 2.0** es la regulación europea de identidad digital. Define qué debe cumplir cualquier wallet que quiera ser reconocida legalmente en Europa. Si estamos construyendo una wallet para QuarkID, esto es el estándar de referencia.

---

## Lo que la wallet DEBE hacer (obligatorio)

### 1. El usuario controla todo
Las claves privadas nunca pueden salir del dispositivo del usuario. El backend no puede custodiar nada. Si la wallet guarda claves en un servidor, no es eIDAS-compliant.

### 2. Seguridad de hardware
Debe usar el chip de seguridad del teléfono para guardar claves:
- Android → StrongBox o TEE
- iOS → Secure Enclave

No alcanza con guardar en memoria o base de datos.

### 3. Certificación formal
No es solo "implementarlo bien". La wallet necesita pasar por una auditoría y certificación europea. Esto no es opcional ni técnico — es legal.

### 4. Soportar los formatos de credencial correctos
| Formato | Uso |
|---|---|
| SD-JWT VC | El más común (ya lo tenemos) |
| mdoc (ISO 18013-5) | Para uso en proximidad (NFC, QR físico) |
| W3C VC | En algunos casos específicos |

### 5. Hablar los protocolos correctos
- **OID4VCI** — para recibir credenciales
- **OID4VP** — para presentar credenciales
- **ISO 18013-5** — para interacciones físicas (mostrar DNI en persona)

> DIDComm (lo que usa Aries/Credo hoy) **no es requerido** en eIDAS 2.0.

### 6. Pedir permiso al usuario siempre
Cada vez que la wallet comparte datos, el usuario tiene que aprobar explícitamente y ver exactamente qué se va a compartir. No hay sharing automático.

### 7. Privacidad real
La wallet debe poder revelar **solo lo necesario**. Ejemplo: en vez de mostrar la fecha de nacimiento, mostrar solo "es mayor de 18". Esto es selective disclosure y es un requisito, no un plus.

### 8. Funcionar con cualquier issuer o verifier europeo
No puede ser una solución cerrada. Si un municipio de Alemania emite una credencial, la wallet tiene que poder recibirla. Si un banco de España la pide, la wallet tiene que poder presentarla.

---

## Lo que diferencia eIDAS de lo que venimos haciendo (SSI clásico)

| | eIDAS 2.0 | SSI clásico (Credo/Aries) |
|---|---|---|
| Quién confía en qué | El estado define el trust | Descentralizado, cada uno decide |
| Wallet | Debe estar certificada | Libre, cualquiera puede hacer una |
| Protocolos | OID4VC + mdoc | DIDComm |
| Seguridad mínima | Nivel alto (hardware) | Variable |
| Claves | Siempre del usuario | Puede variar |
| Interoperabilidad | Obligatoria con toda Europa | Depende de la implementación |

---

## Conclusión práctica

Credo solo no alcanza para cumplir eIDAS 2.0. Hay que agregar encima:
1. La capa de protocolos OID4VC (emisión + presentación) — **ya estamos trabajando en esto**
2. Almacenamiento seguro real en hardware del dispositivo
3. Un proceso de certificación formal (esto no es desarrollo, es proceso legal/auditoría)
