import { ImageResponse } from 'next/og'

export const size = { width: 32, height: 32 }
export const contentType = 'image/png'

/**
 * Favicon 32×32: K simple (legible en pestaña).
 * Marca completa: `public/kuatia-mark.png` (BrandMark / apple-icon).
 * OG: `opengraph-image.tsx` + `kuatia-mark-og.png`.
 */
export default function Icon() {
  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: '#050a10',
          color: '#00a89d',
          fontSize: 22,
          fontWeight: 800,
          letterSpacing: '-0.06em',
          fontFamily: 'system-ui, sans-serif',
          borderRadius: 8,
        }}
      >
        K
      </div>
    ),
    { ...size },
  )
}
