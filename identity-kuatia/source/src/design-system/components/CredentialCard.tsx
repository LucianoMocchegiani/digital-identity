import { cn } from '@/shared/lib/cn'

export type CredentialCardPreset = 'membership' | 'ticket' | 'operator'

type Preset = {
  title: string
  issuer: string
  logoSrc: string
  logoAlt: string
  imageSrc: string
  /** text_color del emisor (como en la wallet). */
  textClass: string
  /** Scrim alineado al contraste del text_color (claro → velo oscuro). */
  scrimClass: string
}

const presets: Record<CredentialCardPreset, Preset> = {
  membership: {
    title: 'Membresía Club Norte',
    issuer: 'Club Norte',
    logoSrc: '/marketing/club-norte-crest.png',
    logoAlt: 'Club Norte',
    imageSrc:
      'https://images.pexels.com/photos/1884574/pexels-photo-1884574.jpeg?auto=compress&cs=tinysrgb&w=800',
    textClass: 'text-white',
    scrimClass: 'from-black/55 via-black/25 to-transparent',
  },
  ticket: {
    title: 'Entrada Recital',
    issuer: 'Recital Live',
    logoSrc: '/marketing/recital-live-mark.png',
    logoAlt: 'Recital Live',
    imageSrc:
      'https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=800',
    textClass: 'text-white',
    scrimClass: 'from-black/55 via-black/25 to-transparent',
  },
  operator: {
    title: 'Operador de Maquinaria Pesada',
    issuer: 'Constructora Andes',
    logoSrc: '/marketing/constructora-andes-mark.png',
    logoAlt: 'Constructora Andes',
    imageSrc:
      'https://images.pexels.com/photos/323705/pexels-photo-323705.jpeg?auto=compress&cs=tinysrgb&w=800',
    textClass: 'text-white',
    scrimClass: 'from-black/60 via-black/30 to-transparent',
  },
}

/**
 * Mini credencial al estilo de la wallet Kuatia (foto + logo + scrim).
 * Presets alineados al demo Club Norte · Recital Live · Constructora Andes.
 */
export function CredentialCard({
  preset,
  className,
  compact = false,
}: {
  preset: CredentialCardPreset
  className?: string
  /** Versión más chica para columnas de casos. */
  compact?: boolean
}) {
  const c = presets[preset]
  return (
    <div
      className={cn(
        'relative overflow-hidden rounded-2xl border border-white/10 shadow-lg shadow-black/40',
        compact ? 'min-h-[88px]' : 'min-h-[104px]',
        className,
      )}
    >
      {/* eslint-disable-next-line @next/next/no-img-element -- URLs remotas de demo + logos locales */}
      <img
        src={c.imageSrc}
        alt=""
        className="absolute inset-0 h-full w-full object-cover"
      />
      <div
        aria-hidden
        className={cn(
          'absolute inset-0 bg-gradient-to-r',
          c.scrimClass,
        )}
      />
      <div
        className={cn(
          'relative flex items-center gap-3',
          compact ? 'p-3' : 'p-3.5',
          c.textClass,
        )}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={c.logoSrc}
          alt={c.logoAlt}
          className={cn(
            'shrink-0 rounded-lg border border-black/20 bg-white object-cover',
            compact ? 'h-8 w-8' : 'h-9 w-9',
          )}
        />
        <div className="min-w-0 flex-1">
          <p
            className={cn(
              'truncate font-semibold leading-tight drop-shadow',
              compact ? 'text-sm' : 'text-[15px]',
            )}
          >
            {c.title}
          </p>
          <p
            className={cn(
              'mt-0.5 truncate opacity-90 drop-shadow',
              compact ? 'text-[11px]' : 'text-xs',
            )}
          >
            {c.issuer}
          </p>
        </div>
      </div>
    </div>
  )
}
