import { ImageResponse } from 'next/og'

export const size = { width: 32, height: 32 }
export const contentType = 'image/png'

/** Favicon generado (marca teal). */
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
          fontWeight: 700,
        }}
      >
        ✕
      </div>
    ),
    { ...size },
  )
}
