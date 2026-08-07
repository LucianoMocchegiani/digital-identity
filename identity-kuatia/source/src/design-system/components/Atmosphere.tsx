import { cn } from '@/shared/lib/cn'

/**
 * Fondo dark-tech reutilizable (landing, auth, acentos de consola).
 * Líneas geométricas + glow teal del mockup long-1.
 */
export function Atmosphere({ className, soft }: { className?: string; soft?: boolean }) {
  return (
    <div aria-hidden className={cn('pointer-events-none absolute inset-0 overflow-hidden', className)}>
      <div
        className={cn('absolute inset-0', soft ? 'opacity-40' : 'opacity-60')}
        style={{
          backgroundImage:
            'radial-gradient(ellipse 70% 45% at 15% 10%, rgba(0,168,157,0.28), transparent 55%), radial-gradient(ellipse 50% 40% at 90% 20%, rgba(0,140,160,0.14), transparent), linear-gradient(180deg, #050a10 0%, #071018 45%, #050a10 100%)',
        }}
      />
      <div
        className="absolute inset-0 opacity-[0.18]"
        style={{
          backgroundImage: 'radial-gradient(rgba(0,168,157,0.35) 0.7px, transparent 0.7px)',
          backgroundSize: '22px 22px',
        }}
      />
      <svg className="absolute inset-0 h-full w-full opacity-30" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="kuatia-line" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#00a89d" stopOpacity="0" />
            <stop offset="45%" stopColor="#00a89d" stopOpacity="0.7" />
            <stop offset="100%" stopColor="#00a89d" stopOpacity="0" />
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
