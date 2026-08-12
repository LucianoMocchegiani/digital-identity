import { ImageResponse } from 'next/og'

export const size = { width: 32, height: 32 }
export const contentType = 'image/png'

/**
 * Favicon 32×32: K simple sin caja de fondo (legible en pestaña).
 * Preview social: `opengraph-image.tsx` (navy + mark).
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
          background: 'transparent',
          color: '#00a89d',
          fontSize: 26,
          fontWeight: 800,
          letterSpacing: '-0.06em',
          fontFamily: 'system-ui, sans-serif',
        }}
      >
        K
      </div>
    ),
    { ...size },
  )
}
