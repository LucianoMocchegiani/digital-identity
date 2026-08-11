import { siteHost } from '@/shared/config/site'
import { ImageResponse } from 'next/og'

export const runtime = 'edge'
export const alt = 'Kuatia — Credenciales digitales'
export const size = { width: 1200, height: 630 }
export const contentType = 'image/png'

/**
 * OG 1200×630 pensado para preview social.
 * WhatsApp recorta un cuadrado a la izquierda: marca grande + nombre ahí.
 */
export default function OpenGraphImage() {
  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          background: '#050a10',
          color: '#f3f7f8',
          fontFamily: 'system-ui, sans-serif',
          position: 'relative',
        }}
      >
        {/* Glow teal (atmósfera marca) */}
        <div
          style={{
            position: 'absolute',
            left: -80,
            top: -120,
            width: 520,
            height: 520,
            borderRadius: 999,
            background: 'rgba(0,168,157,0.22)',
            filter: 'blur(4px)',
            display: 'flex',
          }}
        />

        {/* Zona izquierda (~cuadrado WA): logo + wordmark */}
        <div
          style={{
            width: 630,
            height: '100%',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 28,
            padding: 48,
            position: 'relative',
          }}
        >
          <div
            style={{
              width: 140,
              height: 140,
              borderRadius: 32,
              background: 'rgba(0,168,157,0.16)',
              border: '3px solid rgba(0,168,157,0.55)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <svg width="84" height="84" viewBox="0 0 24 24" fill="#00a89d">
              <path d="M7.2 4.2 12 9l4.8-4.8 2 2L14 11l4.8 4.8-2 2L12 13l-4.8 4.8-2-2L10 11 5.2 6.2l2-2Z" />
            </svg>
          </div>
          <div
            style={{
              fontSize: 72,
              fontWeight: 700,
              letterSpacing: '-0.04em',
              lineHeight: 1,
            }}
          >
            Kuatia
          </div>
          <div
            style={{
              fontSize: 28,
              color: '#00a89d',
              fontWeight: 600,
              letterSpacing: '0.02em',
            }}
          >
            Credenciales digitales
          </div>
        </div>

        {/* Derecha: claim corto (LinkedIn / Discord / full OG) */}
        <div
          style={{
            flex: 1,
            height: '100%',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            gap: 20,
            paddingRight: 64,
            paddingLeft: 16,
            position: 'relative',
            borderLeft: '1px solid rgba(255,255,255,0.08)',
          }}
        >
          <div
            style={{
              fontSize: 40,
              fontWeight: 600,
              letterSpacing: '-0.03em',
              lineHeight: 1.2,
              maxWidth: 480,
            }}
          >
            Emití y verificá con OpenID4VC
          </div>
          <div style={{ fontSize: 24, color: '#8b9aab', lineHeight: 1.35, maxWidth: 460 }}>
            Documentos · Entradas · Membresías
          </div>
          <div style={{ fontSize: 22, color: '#00a89d', marginTop: 12 }}>{siteHost}</div>
        </div>
      </div>
    ),
    { ...size },
  )
}
