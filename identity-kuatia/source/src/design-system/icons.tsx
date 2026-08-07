import type { SVGProps } from 'react'

/** Íconos outline reutilizables (landing + consola). */
type IconProps = SVGProps<SVGSVGElement> & { size?: number }

function base({ size = 20, className, ...rest }: IconProps) {
  return { width: size, height: size, className, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: 1.75, strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const, ...rest }
}

export function IconProducts(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M12 3 4 7v10l8 4 8-4V7l-8-4Z" />
      <path d="M12 12 4 8M12 12v10M12 12l8-4" />
    </svg>
  )
}

export function IconUsage(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M4 19V5M4 19h16" />
      <path d="M8 15v-4M12 15V9M16 15v-7" />
    </svg>
  )
}

export function IconPlan(p: IconProps) {
  return (
    <svg {...base(p)}>
      <rect x="3" y="6" width="18" height="12" rx="2" />
      <path d="M3 10h18" />
    </svg>
  )
}

export function IconAccount(p: IconProps) {
  return (
    <svg {...base(p)}>
      <circle cx="12" cy="8" r="3.5" />
      <path d="M5 20c1.5-3.5 4-5 7-5s5.5 1.5 7 5" />
    </svg>
  )
}

export function IconCredentials(p: IconProps) {
  return (
    <svg {...base(p)}>
      <rect x="4" y="5" width="16" height="14" rx="2" />
      <path d="M8 10h8M8 14h5" />
    </svg>
  )
}

export function IconShield(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M12 3 5 6v6c0 4.5 3 7.5 7 9 4-1.5 7-4.5 7-9V6l-7-3Z" />
      <path d="m9.5 12 1.8 1.8L15 10" />
    </svg>
  )
}

export function IconTicket(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M4 8a2 2 0 0 0 2-2h12a2 2 0 0 0 2 2v2a2 2 0 0 1 0 4v2a2 2 0 0 0-2 2H6a2 2 0 0 0-2-2v-2a2 2 0 0 1 0-4V8Z" />
      <path d="M12 7v10" />
    </svg>
  )
}

export function IconUsers(p: IconProps) {
  return (
    <svg {...base(p)}>
      <circle cx="9" cy="8" r="3" />
      <circle cx="17" cy="9" r="2.5" />
      <path d="M3.5 19c1-3 3-4.5 5.5-4.5S13 16 14 19M14.5 19c.4-1.8 1.6-3 3.5-3 1.4 0 2.5.7 3.2 2" />
    </svg>
  )
}

export function IconDoc(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M7 3h7l4 4v14H7V3Z" />
      <path d="M14 3v4h4M9 12h6M9 16h4" />
    </svg>
  )
}

export function IconPlus(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M12 5v14M5 12h14" />
    </svg>
  )
}

export function IconArrowRight(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M5 12h14M13 6l6 6-6 6" />
    </svg>
  )
}

export function IconCalendar(p: IconProps) {
  return (
    <svg {...base(p)}>
      <rect x="3" y="5" width="18" height="16" rx="2" />
      <path d="M8 3v4M16 3v4M3 10h18" />
    </svg>
  )
}

export function IconEye(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6-10-6-10-6Z" />
      <circle cx="12" cy="12" r="2.5" />
    </svg>
  )
}

export function IconEyeOff(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M3 3l18 18M10.5 10.6A2.5 2.5 0 0 0 13.4 13.5M7 7.4C4.5 8.8 2.8 11 2 12c1.2 1.8 4.5 6 10 6 1.7 0 3.2-.4 4.5-1M14.5 9.4C16.8 10.5 18.5 12.2 20 12c-.5.8-1.3 1.8-2.4 2.8" />
    </svg>
  )
}

export function IconCopy(p: IconProps) {
  return (
    <svg {...base(p)}>
      <rect x="8" y="8" width="12" height="12" rx="2" />
      <path d="M4 16V6a2 2 0 0 1 2-2h10" />
    </svg>
  )
}

export function IconMore(p: IconProps) {
  return (
    <svg {...base(p)}>
      <circle cx="12" cy="5" r="1.2" fill="currentColor" stroke="none" />
      <circle cx="12" cy="12" r="1.2" fill="currentColor" stroke="none" />
      <circle cx="12" cy="19" r="1.2" fill="currentColor" stroke="none" />
    </svg>
  )
}

export function IconBolt(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M13 3 5 14h6l-1 7 9-12h-6l0-6Z" />
    </svg>
  )
}

export function IconCheck(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="m5 12 5 5L20 7" />
    </svg>
  )
}

export function IconClose(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M6 6l12 12M18 6 6 18" />
    </svg>
  )
}

export function IconCode(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="m8 8-4 4 4 4M16 8l4 4-4 4M14 5l-4 14" />
    </svg>
  )
}

export function IconMail(p: IconProps) {
  return (
    <svg {...base(p)}>
      <rect x="3" y="5" width="18" height="14" rx="2" />
      <path d="m4 7 8 6 8-6" />
    </svg>
  )
}

export function IconLock(p: IconProps) {
  return (
    <svg {...base(p)}>
      <rect x="5" y="10" width="14" height="11" rx="2" />
      <path d="M8 10V7a4 4 0 0 1 8 0v3" />
    </svg>
  )
}

export function IconRocket(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M5 15c2 0 4 2 4 4M9 19 5 15" />
      <path d="M14 4c4 2 6 6 6 10l-4 1-3-3-1-4c4-4 2-4 2-4Z" />
      <path d="m10 14-4 1 1-4" />
    </svg>
  )
}

export function IconBuilding(p: IconProps) {
  return (
    <svg {...base(p)}>
      <path d="M4 20h16M6 20V6l6-2 6 2v14" />
      <path d="M10 10h1M13 10h1M10 14h1M13 14h1M10 18h4" />
    </svg>
  )
}

export function IconHelp(p: IconProps) {
  return (
    <svg {...base(p)}>
      <circle cx="12" cy="12" r="9" />
      <path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.8.4-1.5 1.1-1.5 2.2V15M12 17.5h.01" />
    </svg>
  )
}
