# Assets visuales — credenciales demo

Logos inventados (PNG en este folder) + fondos Pexels. La wallet solo renderiza URLs que terminan en `.png`, `.jpg`, `.jpeg` o `.webp`.

Base raw: `https://raw.githubusercontent.com/LucianoMocchegiani/digital-identity/main/postman/assets/demo-credentials/`

## Kuatia — Club Norte · Recital Live · Constructora Andes

| Clave | Uso | URL |
|-------|-----|-----|
| Club logo | Issuer + Membresía | `…/club-norte-crest.png` (escudo inventado teal) |
| Club fondo | MembershipCredential | `https://images.pexels.com/photos/1884574/pexels-photo-1884574.jpeg` |
| Recital logo | Issuer + Entrada | `…/recital-live-mark.png` (marca inventada violeta) |
| Recital fondo | RecitalTicketCredential | `https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg` |
| Andes logo | Issuer + Operador | `…/constructora-andes-mark.png` (marca inventada naranja/carbón) |
| Andes fondo | HeavyMachineryOperatorCredential | `https://images.pexels.com/photos/323705/pexels-photo-323705.jpeg` (sede / edificio) |

Colores: Club `#0f766e` · Recital `#7c3aed` · Andes `#1c1917` / texto `#FFFFFF`.

**Constructora Andes:** habilitación **interna** de empresa (claim `validity_scope`). Display = marca corporativa + foto de sede, no maquinaria.
