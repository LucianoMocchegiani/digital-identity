/**
 * Token Nest de {@link import('@quarkid/identity-core').QuarkAskarStoreOptions}.
 *
 * Config de la bóveda Askar. La consumen `createRoot*Agent` /
 * `ensureAskarStoreProvisioned`; no es el adapter KMS ni el de records.
 */
export const ASKAR_STORE_OPTIONS = Symbol('AskarStoreOptions')
