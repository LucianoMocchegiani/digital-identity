#ifndef QUARK_BBS_H
#define QUARK_BBS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/** Free a buffer returned by quark_bbs_* (allocated with Rust allocator). */
void quark_bbs_free(uint8_t *ptr, int32_t len);

/**
 * blsCreateProof (MATTR-compatible).
 *
 * Inputs are raw byte lengths. `revealed` is an array of message indices (usize as uint32).
 * On success writes *out_proof / *out_proof_len (caller must quark_bbs_free).
 * Returns 0 on success, non-zero on error (optional error message in *out_err / *out_err_len).
 */
int32_t quark_bbs_bls_create_proof(
    const uint8_t *public_key, int32_t public_key_len,
    const uint8_t *signature, int32_t signature_len,
    const uint8_t *const *messages, const int32_t *message_lens, int32_t message_count,
    const uint32_t *revealed, int32_t revealed_count,
    const uint8_t *nonce, int32_t nonce_len,
    uint8_t **out_proof, int32_t *out_proof_len,
    uint8_t **out_err, int32_t *out_err_len);

/**
 * blsVerifyProof (MATTR-compatible).
 *
 * `messages` are only the revealed messages, in revealed-index order (same as MATTR).
 * Writes *out_verified (1/0). Returns 0 on completed check, non-zero on parse/input error.
 */
int32_t quark_bbs_bls_verify_proof(
    const uint8_t *public_key, int32_t public_key_len,
    const uint8_t *proof, int32_t proof_len,
    const uint8_t *const *messages, const int32_t *message_lens, int32_t message_count,
    const uint8_t *nonce, int32_t nonce_len,
    int32_t *out_verified,
    uint8_t **out_err, int32_t *out_err_len);

#ifdef __cplusplus
}
#endif

#endif /* QUARK_BBS_H */
