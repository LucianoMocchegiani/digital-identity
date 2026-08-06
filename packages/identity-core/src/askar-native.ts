/**
 * Registra el binding nativo Askar sobre `askar-shared` y reexporta el handle.
 *
 * Debe evaluarse **antes** de cargar `@credo-ts/askar`. Ese paquete ESM importa
 * `{ askar }` de `@openwallet-foundation/askar-shared`; Node fija el named export
 * en el primer load. Si aún es `undefined` (antes de `NativeAskar.register`),
 * `AskarKeyManagementService.createKey` falla con
 * `Cannot read properties of undefined (reading 'keyGetJwkSecret')`.
 *
 * En `@openwallet-foundation/askar-nodejs@0.6` el nativo se exporta como
 * `askarNodeJS`; el nombre `askar` en askar-shared empieza vacío y solo se
 * asigna al registrar.
 */
import '@openwallet-foundation/askar-nodejs'

export { askarNodeJS as askar } from '@openwallet-foundation/askar-nodejs'
