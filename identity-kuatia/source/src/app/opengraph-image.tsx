import { readFile } from 'node:fs/promises'
import { join } from 'node:path'
import { ImageResponse } from 'next/og'

export const alt = 'Kuatia'
/** 1200×630: estándar OG (Facebook, LinkedIn, X). WhatsApp usa el mismo `og:image`. */
export const size = { width: 1200, height: 630 }
export const contentType = 'image/png'

/**
 * Preview social: solo el ícono de marca, centrado y grande.
 * Título/descripción van en metadata (`og:title`, `og:description`).
 *
 * @see https://developers.facebook.com/docs/whatsapp/link-previews/
 */
export default async function OpenGraphImage() {
  const mark = await readFile(join(process.cwd(), 'public/kuatia-mark-og.png'))
  const markSrc = `data:image/png;base64,${mark.toString('base64')}`

  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: '#0B1520',
        }}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={markSrc}
          width={630}
          height={630}
          alt=""
          style={{ borderRadius: 0 }}
        />
      </div>
    ),
    { ...size },
  )
}
