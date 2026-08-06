# Assets visuales — credenciales demo

Imágenes **PNG/JPG** referenciadas en `Quark-Demo-Multi-tenant.postman_collection.json`.

La wallet (`CredentialDisplayStyle.isRasterImageUrl`) solo renderiza URLs que terminan en `.png`, `.jpg`, `.jpeg` o `.webp`. No usar `.svg` directo.

## URLs usadas (Wikimedia Commons / CC)

| Clave | Uso | URL |
|-------|-----|-----|
| GCBA logo | Ciudadano + Empleado | `https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Escudo_de_la_Ciudad_de_Buenos_Aires.svg/250px-Escudo_de_la_Ciudad_de_Buenos_Aires.svg.png` |
| GCBA fondo ciudadano | CitizenCardGCBA | `https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Flag_of_Argentina.svg/1280px-Flag_of_Argentina.svg.png` |
| GCBA fondo empleado | EmpleadoCardGCBA | `https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Casa_rosada_2005.jpg/1280px-Casa_rosada_2005.jpg` |
| UADE logo | EstudianteCardUADE | `https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Looo_UADE.svg/500px-Looo_UADE.svg.png` |
| UADE fondo | EstudianteCardUADE | `https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/UADE_desde_9_de_julio_e_independencia.jpg/1280px-UADE_desde_9_de_julio_e_independencia.jpg` |
| IOMA logo | AfiliadoCardIOMA | `https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Coat_of_arms_of_Buenos_Aires_Province.svg/250px-Coat_of_arms_of_Buenos_Aires_Province.svg.png` |
| IOMA fondo | AfiliadoCardIOMA | `https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Flag_of_Argentina.svg/1280px-Flag_of_Argentina.svg.png` |
| RENAPER logo | PasaporteCiudadanoCardRENAPER | `https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Coat_of_arms_of_Argentina.svg/250px-Coat_of_arms_of_Argentina.svg.png` |
| RENAPER fondo | PasaporteCiudadanoCardRENAPER | `https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Escarapela_wiki.svg/1280px-Escarapela_wiki.svg.png` |

Para IOMA en producción, reemplazar el logo por el JPG oficial de [ioma.gba.gob.ar](https://www.ioma.gba.gob.ar/index.php/piezas-graficas-y-formularios/) hosteado en URL propia.

## Colores por credencial

| Credencial | background_color | text_color |
|------------|------------------|------------|
| CitizenCardGCBA | `#153244` | `#FFFFFF` |
| EmpleadoCardGCBA | `#1A3A52` | `#FFFFFF` |
| EstudianteCardUADE | `#1B2A4A` | `#FFFFFF` |
| AfiliadoCardIOMA | `#006837` | `#FFFFFF` |
| PasaporteCiudadanoCardRENAPER | `#003366` | `#FFFFFF` |
