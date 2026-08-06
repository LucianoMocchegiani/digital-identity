import { RequestMethod } from '@nestjs/common'

/** Rutas sin prefijo `/v1` (métricas Prometheus). */
export const GLOBAL_PREFIX_EXCLUDE = [
  { path: 'metrics', method: RequestMethod.ALL },
]
