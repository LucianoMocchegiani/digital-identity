/**
 * Scope de almacenamiento del agente root en Credo 0.6 (`contextCorrelationId: "default"`).
 * KMS y records internos del root deben usar el mismo valor en el seed inicial.
 */
export const ROOT_STORAGE_SCOPE = 'default'

/**
 * Scope dedicado para claves compartidas entre todos los tenants (ej. certificado x5c del dominio).
 * El KMS usa este scope como fallback cuando un tenant no tiene una clave con el keyId buscado.
 */
export const DOMAIN_KEY_SCOPE = 'domain-key'
