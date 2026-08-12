import { readFile } from 'node:fs/promises'
import { join } from 'node:path'
import { ImageResponse } from 'next/og'

export const alt = 'Kuatia'
/** 1200×630: estándar OG (Facebook, LinkedIn, X). WhatsApp usa el mismo `og:image`. */
export const size = { width: 1200, height: 630 }
export const contentType = 'image/png'

/**
 * Preview social: mark a full-bleed sobre navy de marca.
 * En UI (BrandMark / wallet) el PNG va sin fondo; acá sí hay canvas.
 *
 * @see https://developers.facebook.com/docs/whatsapp/link-previews/
 */
export default async function OpenGraphImage() {
  // Versión precompuesta 1200×630 (navy + mark) para peso/caché estables.
  const og = await readFile(join(process.cwd(), 'public/kuatia-mark-og.png'))
  const ogSrc = `data:image/png;base64,${og.toString('base64')}`

  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          background: '#0B1520',
        }}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={ogSrc} width={1200} height={630} alt="" />
      </div>
    ),
    { ...size },
  )
}
