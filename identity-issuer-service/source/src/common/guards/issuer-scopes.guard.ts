import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  SetMetadata,
} from '@nestjs/common'

/**
 * Key de metadata que el decorador {@link RequireScopes} setea y que el
 * {@link IssuerScopesGuard} lee. Mismo string que el resto del monorepo
 * (`quark-auth/source/src/common/decorators/require-scopes.decorator.ts`).
 */
export const REQUIRED_SCOPES_KEY = 'requiredScopes'

/**
 * Decorador de método/clase que declara los scopes requeridos por un endpoint.
 *
 * Los scopes se acumulan: si se setea a nivel de clase y de handler, el guard
 * exige la unión de ambos.
 *
 * @example
 * ```ts
 * @UseGuards(JwtAuthGuard, IssuerScopesGuard)
 * @RequireScopes('vcs:revoke')
 * @Post('revoke')
 * revoke() { ... }
 * ```
 */
export const RequireScopes = (...scopes: string[]) =>
  SetMetadata(REQUIRED_SCOPES_KEY, scopes)

/**
 * Guard de autorización por scopes para endpoints del issuer.
 *
 * Lee la metadata `REQUIRED_SCOPES_KEY` (seteada con `@RequireScopes(...)`) a
 * nivel de clase y de handler, las acumula y exige que el usuario autenticado
 * (`req.user.scopes`, poblado por `JwtAuthGuard`) contenga **todos** los scopes
 * requeridos. Si no se setea ningún scope, el guard deja pasar
 * (allow-by-default).
 *
 * Se ejecuta **después** de `JwtAuthGuard`, que es quien puebla `req.user`
 * con el payload del token.
 */
@Injectable()
export class IssuerScopesGuard implements CanActivate {
  /**
   * Decide si la request puede continuar.
   *
   * @param context - Contexto de ejecución NestJS.
   * @returns `true` si el usuario tiene todos los scopes requeridos.
   * @throws {ForbiddenException} Si falta algún scope requerido.
   */
  canActivate(context: ExecutionContext): boolean {
    const requiredScopes = this.getRequiredScopes(context)
    if (!requiredScopes?.length) return true

    const user = context.switchToHttp().getRequest().user as
      | { scopes?: string[] }
      | undefined
    if (!user?.scopes?.length) {
      throw new ForbiddenException('Scopes insuficientes')
    }

    const hasAllScopes = requiredScopes.every((scope) =>
      user.scopes?.includes(scope),
    )
    if (!hasAllScopes) {
      throw new ForbiddenException('Scopes insuficientes')
    }
    return true
  }

  private getRequiredScopes(context: ExecutionContext): string[] {
    const handler = context.getHandler()
    const classConstructor = context.getClass()

    const classMetadata = Reflect.getMetadata(
      REQUIRED_SCOPES_KEY,
      classConstructor,
    )
    const handlerMetadata = Reflect.getMetadata(REQUIRED_SCOPES_KEY, handler)

    return [...(classMetadata || []), ...(handlerMetadata || [])]
  }
}