import { cn } from '@/shared/lib/cn'

/**
 * Fondo atmosférico (landing, auth, docs).
 * Colores vía CSS vars — responde a data-theme light/dark.
 */
export function Atmosphere({ className, soft }: { className?: string; soft?: boolean }) {
  return (
    <div aria-hidden className={cn('pointer-events-none absolute inset-0 overflow-hidden', className)}>
      <div
        className={cn('absolute inset-0', soft ? 'opacity-50' : 'opacity-70')}
        style={{
          backgroundImage: `
            radial-gradient(ellipse 70% 45% at 15% 10%, var(--kuatia-glow), transparent 55%),
            radial-gradient(ellipse 50% 40% at 90% 20%, color-mix(in srgb, var(--kuatia-accent) 14%, transparent), transparent),
            linear-gradient(180deg, var(--kuatia-bg) 0%, var(--kuatia-atmosphere-mid) 45%, var(--kuatia-bg) 100%)
          `,
        }}
      />
      <div
        className="absolute inset-0 opacity-[0.14]"
        style={{
          backgroundImage:
            'radial-gradient(color-mix(in srgb, var(--kuatia-accent) 35%, transparent) 0.7px, transparent 0.7px)',
          backgroundSize: '22px 22px',
        }}
      />
      <svg className="absolute inset-0 h-full w-full opacity-25" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="kuatia-line" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="var(--kuatia-accent)" stopOpacity="0" />
            <stop offset="45%" stopColor="var(--kuatia-accent)" stopOpacity="0.7" />
            <stop offset="100%" stopColor="var(--kuatia-accent)" stopOpacity="0" />
          </linearGradient>
        </defs>
        <g stroke="url(#kuatia-line)" strokeWidth="1.2" fill="none">
          <path d="M-40 120 L280 40 L520 180 L900 -20" />
          <path d="M100 700 L420 420 L780 560 L1200 300" />
          <path d="M-20 400 L300 280 L640 480 L1100 200" />
        </g>
      </svg>
    </div>
  )
}
