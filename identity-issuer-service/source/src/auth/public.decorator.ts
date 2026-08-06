import { SetMetadata } from '@nestjs/common'

export const IS_PUBLIC_KEY = 'isPublic'
/** Marca una ruta Nest como pública (sin API key). */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true)
