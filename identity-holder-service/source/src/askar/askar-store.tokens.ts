/**
 * Token Nest de {@link import('@identity/core').QuarkAskarStoreOptions}.
 *
 * Config de la bóveda Askar (id, passphrase, URL, binding nativo). La consumen
 * `createRoot*Agent` / `ensureAskarStoreProvisioned`; no es el adapter KMS ni el de records.
 */
export const ASKAR_STORE_OPTIONS = Symbol('AskarStoreOptions')
