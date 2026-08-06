//! C FFI for BBS+ pairing — logic mirrored from
//! `@mattrglobal/bbs-signatures` (`blsCreateProof` / `blsVerifyProof`, bbs 0.4.x).

use arrayref::array_ref;
use bbs::prelude::*;
use std::collections::{BTreeMap, BTreeSet};
use std::iter::FromIterator;
use std::slice;

const G2_COMPRESSED_SIZE: usize = 96;

/// Proof bytes = [u16 BE message_count][bitvector BE][PoK compressed].
struct ProofWrapper {
    bit_vector: Vec<u8>,
    proof: PoKOfSignatureProof,
}

impl ProofWrapper {
    fn new(message_count: usize, revealed: &BTreeSet<usize>, proof: PoKOfSignatureProof) -> Self {
        let mut bit_vector = (message_count as u16).to_be_bytes().to_vec();
        bit_vector.append(&mut revealed_to_bitvector(message_count, revealed));
        Self { bit_vector, proof }
    }

    fn to_bytes(&self) -> Vec<u8> {
        let mut data = self.bit_vector.clone();
        data.append(&mut self.proof.to_bytes_compressed_form());
        data
    }

    fn try_from_bytes(value: &[u8]) -> Result<Self, String> {
        if value.len() < 2 {
            return Err("proof too short".into());
        }
        let message_count = u16::from_be_bytes(*array_ref![value, 0, 2]) as usize;
        let bitvector_length = (message_count / 8) + 1;
        let offset = bitvector_length + 2;
        if offset > value.len() {
            return Err("proof bitvector out of bounds".into());
        }
        let proof = PoKOfSignatureProof::try_from(&value[offset..])
            .map_err(|e| format!("proof parse: {e:?}"))?;
        Ok(Self {
            bit_vector: value[..offset].to_vec(),
            proof,
        })
    }

    fn unwrap(self) -> (BTreeSet<usize>, PoKOfSignatureProof) {
        (
            bitvector_to_revealed(&self.bit_vector[2..]),
            self.proof,
        )
    }
}

fn revealed_to_bitvector(total: usize, revealed: &BTreeSet<usize>) -> Vec<u8> {
    let mut bytes = vec![0u8; (total / 8) + 1];
    for r in revealed {
        let idx = *r / 8;
        let bit = (*r % 8) as u8;
        bytes[idx] |= 1u8 << bit;
    }
    bytes.reverse();
    bytes
}

fn bitvector_to_revealed(data: &[u8]) -> BTreeSet<usize> {
    let mut revealed_messages = BTreeSet::new();
    let mut scalar = 0usize;
    for b in data.iter().rev() {
        let mut v = *b;
        let mut remaining = 8;
        while v > 0 {
            if v & 1u8 == 1 {
                revealed_messages.insert(scalar);
            }
            v >>= 1;
            scalar += 1;
            remaining -= 1;
        }
        scalar += remaining;
    }
    revealed_messages
}

fn read_slice<'a>(ptr: *const u8, len: i32) -> Result<&'a [u8], String> {
    if len < 0 {
        return Err("negative length".into());
    }
    if ptr.is_null() {
        if len == 0 {
            return Ok(&[]);
        }
        return Err("null pointer".into());
    }
    Ok(unsafe { slice::from_raw_parts(ptr, len as usize) })
}

fn alloc_bytes(data: &[u8]) -> (*mut u8, i32) {
    let mut v = data.to_vec().into_boxed_slice();
    let len = v.len() as i32;
    let ptr = v.as_mut_ptr();
    std::mem::forget(v);
    (ptr, len)
}

fn write_err(msg: String, out_err: *mut *mut u8, out_err_len: *mut i32) {
    if out_err.is_null() || out_err_len.is_null() {
        return;
    }
    let (ptr, len) = alloc_bytes(msg.as_bytes());
    unsafe {
        *out_err = ptr;
        *out_err_len = len;
    }
}

fn clear_err(out_err: *mut *mut u8, out_err_len: *mut i32) {
    if out_err.is_null() || out_err_len.is_null() {
        return;
    }
    unsafe {
        *out_err = std::ptr::null_mut();
        *out_err_len = 0;
    }
}

fn parse_dpk(public_key: &[u8]) -> Result<DeterministicPublicKey, String> {
    if public_key.len() != G2_COMPRESSED_SIZE {
        return Err(format!(
            "publicKey len {} != {G2_COMPRESSED_SIZE}",
            public_key.len()
        ));
    }
    Ok(DeterministicPublicKey::from(array_ref![
        public_key,
        0,
        G2_COMPRESSED_SIZE
    ]))
}

fn parse_signature(signature: &[u8]) -> Result<Signature, String> {
    Signature::try_from(signature).map_err(|e| format!("signature parse: {e:?}"))
}

fn read_messages(
    messages: *const *const u8,
    message_lens: *const i32,
    message_count: i32,
) -> Result<Vec<Vec<u8>>, String> {
    if message_count < 0 {
        return Err("negative message_count".into());
    }
    if message_count == 0 {
        return Ok(vec![]);
    }
    if messages.is_null() || message_lens.is_null() {
        return Err("null messages".into());
    }
    let count = message_count as usize;
    let ptrs = unsafe { slice::from_raw_parts(messages, count) };
    let lens = unsafe { slice::from_raw_parts(message_lens, count) };
    let mut out = Vec::with_capacity(count);
    for i in 0..count {
        out.push(read_slice(ptrs[i], lens[i])?.to_vec());
    }
    Ok(out)
}

#[no_mangle]
pub extern "C" fn quark_bbs_free(ptr: *mut u8, len: i32) {
    if ptr.is_null() || len <= 0 {
        return;
    }
    unsafe {
        let _ = Box::from_raw(slice::from_raw_parts_mut(ptr, len as usize));
    }
}

#[no_mangle]
pub extern "C" fn quark_bbs_bls_create_proof(
    public_key: *const u8,
    public_key_len: i32,
    signature: *const u8,
    signature_len: i32,
    messages: *const *const u8,
    message_lens: *const i32,
    message_count: i32,
    revealed: *const u32,
    revealed_count: i32,
    nonce: *const u8,
    nonce_len: i32,
    out_proof: *mut *mut u8,
    out_proof_len: *mut i32,
    out_err: *mut *mut u8,
    out_err_len: *mut i32,
) -> i32 {
    clear_err(out_err, out_err_len);
    let result = (|| -> Result<Vec<u8>, String> {
        let pk_bytes = read_slice(public_key, public_key_len)?;
        let sig_bytes = read_slice(signature, signature_len)?;
        let msgs = read_messages(messages, message_lens, message_count)?;
        let nonce_bytes = read_slice(nonce, nonce_len)?;
        if revealed_count < 0 {
            return Err("negative revealed_count".into());
        }
        let revealed_idx: Vec<usize> = if revealed_count == 0 {
            vec![]
        } else {
            if revealed.is_null() {
                return Err("null revealed".into());
            }
            unsafe { slice::from_raw_parts(revealed, revealed_count as usize) }
                .iter()
                .map(|i| *i as usize)
                .collect()
        };
        if revealed_idx.iter().any(|r| *r >= msgs.len()) {
            return Err("revealed value is out of bounds".into());
        }
        let dpk = parse_dpk(pk_bytes)?;
        let pk = dpk
            .to_public_key(msgs.len())
            .map_err(|e| format!("to_public_key: {e:?}"))?;
        let sig = parse_signature(sig_bytes)?;
        let revealed_set: BTreeSet<usize> = BTreeSet::from_iter(revealed_idx.into_iter());
        let mut proof_messages = Vec::with_capacity(msgs.len());
        for (i, m) in msgs.iter().enumerate() {
            if revealed_set.contains(&i) {
                proof_messages.push(ProofMessage::Revealed(SignatureMessage::hash(m)));
            } else {
                proof_messages.push(ProofMessage::Hidden(HiddenMessage::ProofSpecificBlinding(
                    SignatureMessage::hash(m),
                )));
            }
        }
        let pok = PoKOfSignature::init(&sig, &pk, proof_messages.as_slice())
            .map_err(|e| format!("PoK init: {e:?}"))?;
        let mut challenge_bytes = pok.to_bytes();
        if nonce_bytes.is_empty() {
            challenge_bytes.extend_from_slice(&[0u8; FR_COMPRESSED_SIZE]);
        } else {
            let n = ProofNonce::hash(nonce_bytes);
            challenge_bytes.extend_from_slice(n.to_bytes_uncompressed_form().as_ref());
        }
        let challenge_hash = ProofChallenge::hash(&challenge_bytes);
        let proof = pok
            .gen_proof(&challenge_hash)
            .map_err(|e| format!("gen_proof: {e:?}"))?;
        Ok(ProofWrapper::new(msgs.len(), &revealed_set, proof).to_bytes())
    })();

    match result {
        Ok(bytes) => {
            if out_proof.is_null() || out_proof_len.is_null() {
                return 2;
            }
            let (ptr, len) = alloc_bytes(&bytes);
            unsafe {
                *out_proof = ptr;
                *out_proof_len = len;
            }
            0
        }
        Err(e) => {
            write_err(e, out_err, out_err_len);
            1
        }
    }
}

#[no_mangle]
pub extern "C" fn quark_bbs_bls_verify_proof(
    public_key: *const u8,
    public_key_len: i32,
    proof: *const u8,
    proof_len: i32,
    messages: *const *const u8,
    message_lens: *const i32,
    message_count: i32,
    nonce: *const u8,
    nonce_len: i32,
    out_verified: *mut i32,
    out_err: *mut *mut u8,
    out_err_len: *mut i32,
) -> i32 {
    clear_err(out_err, out_err_len);
    if out_verified.is_null() {
        return 2;
    }
    let result = (|| -> Result<bool, String> {
        let pk_bytes = read_slice(public_key, public_key_len)?;
        let proof_bytes = read_slice(proof, proof_len)?;
        let msgs = read_messages(messages, message_lens, message_count)?;
        let nonce_bytes = read_slice(nonce, nonce_len)?;
        let wrapper = ProofWrapper::try_from_bytes(proof_bytes)?;
        let message_count_in_proof =
            u16::from_be_bytes(*array_ref![wrapper.bit_vector, 0, 2]) as usize;
        let dpk = parse_dpk(pk_bytes)?;
        let pk = dpk
            .to_public_key(message_count_in_proof)
            .map_err(|e| format!("to_public_key: {e:?}"))?;
        let (revealed, pok_proof) = wrapper.unwrap();
        if msgs.len() != revealed.len() {
            return Err(format!(
                "messages count ({}) != revealed count ({})",
                msgs.len(),
                revealed.len()
            ));
        }
        let nonce = if nonce_bytes.is_empty() {
            ProofNonce::default()
        } else {
            ProofNonce::hash(nonce_bytes)
        };
        let proof_request = ProofRequest {
            revealed_messages: revealed,
            verification_key: pk,
        };
        let revealed_vec: Vec<&usize> = proof_request.revealed_messages.iter().collect();
        let mut revealed_messages = BTreeMap::new();
        for i in 0..revealed_vec.len() {
            revealed_messages.insert(*revealed_vec[i], SignatureMessage::hash(&msgs[i]));
        }
        let signature_proof = SignatureProof {
            revealed_messages,
            proof: pok_proof,
        };
        Ok(Verifier::verify_signature_pok(&proof_request, &signature_proof, &nonce).is_ok())
    })();

    match result {
        Ok(v) => {
            unsafe {
                *out_verified = if v { 1 } else { 0 };
            }
            0
        }
        Err(e) => {
            unsafe {
                *out_verified = 0;
            }
            write_err(e, out_err, out_err_len);
            1
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use base64::Engine;
    use serde_json::Value;
    use std::fs;

    fn b64(s: &str) -> Vec<u8> {
        base64::engine::general_purpose::STANDARD
            .decode(s)
            .expect("base64")
    }

    fn call_verify(
        public_key: &[u8],
        proof: &[u8],
        messages: &[Vec<u8>],
        nonce: &[u8],
    ) -> bool {
        let msg_ptrs: Vec<*const u8> = messages.iter().map(|m| m.as_ptr()).collect();
        let msg_lens: Vec<i32> = messages.iter().map(|m| m.len() as i32).collect();
        let mut verified: i32 = 0;
        let mut err: *mut u8 = std::ptr::null_mut();
        let mut err_len: i32 = 0;
        let rc = quark_bbs_bls_verify_proof(
            public_key.as_ptr(),
            public_key.len() as i32,
            proof.as_ptr(),
            proof.len() as i32,
            msg_ptrs.as_ptr(),
            msg_lens.as_ptr(),
            messages.len() as i32,
            nonce.as_ptr(),
            nonce.len() as i32,
            &mut verified,
            &mut err,
            &mut err_len,
        );
        if !err.is_null() {
            let msg = unsafe {
                String::from_utf8_lossy(slice::from_raw_parts(err, err_len as usize)).into_owned()
            };
            quark_bbs_free(err, err_len);
            assert_eq!(rc, 0, "verify_proof error: {msg}");
        } else {
            assert_eq!(rc, 0, "verify_proof returned error code");
        }
        verified == 1
    }

    fn call_create(
        public_key: &[u8],
        signature: &[u8],
        messages: &[Vec<u8>],
        revealed: &[u32],
        nonce: &[u8],
    ) -> Vec<u8> {
        let msg_ptrs: Vec<*const u8> = messages.iter().map(|m| m.as_ptr()).collect();
        let msg_lens: Vec<i32> = messages.iter().map(|m| m.len() as i32).collect();
        let mut out: *mut u8 = std::ptr::null_mut();
        let mut out_len: i32 = 0;
        let mut err: *mut u8 = std::ptr::null_mut();
        let mut err_len: i32 = 0;
        let rc = quark_bbs_bls_create_proof(
            public_key.as_ptr(),
            public_key.len() as i32,
            signature.as_ptr(),
            signature.len() as i32,
            msg_ptrs.as_ptr(),
            msg_lens.as_ptr(),
            messages.len() as i32,
            revealed.as_ptr(),
            revealed.len() as i32,
            nonce.as_ptr(),
            nonce.len() as i32,
            &mut out,
            &mut out_len,
            &mut err,
            &mut err_len,
        );
        if rc != 0 {
            let msg = if err.is_null() {
                "unknown".into()
            } else {
                let s = unsafe {
                    String::from_utf8_lossy(slice::from_raw_parts(err, err_len as usize)).into_owned()
                };
                quark_bbs_free(err, err_len);
                s
            };
            panic!("create_proof failed: {msg}");
        }
        let bytes = unsafe { slice::from_raw_parts(out, out_len as usize).to_vec() };
        quark_bbs_free(out, out_len);
        bytes
    }

    #[test]
    fn verifies_mattr_golden_proof() {
        let path = concat!(env!("CARGO_MANIFEST_DIR"), "/testdata/bbs_pairing_golden.json");
        let raw = fs::read_to_string(path).expect("golden fixture");
        let v: Value = serde_json::from_str(&raw).unwrap();
        let public_key = b64(v["publicKey"].as_str().unwrap());
        let signature = b64(v["signature"].as_str().unwrap());
        let nonce = b64(v["nonce"].as_str().unwrap());
        let proof = b64(v["proof"].as_str().unwrap());
        let messages: Vec<Vec<u8>> = v["messages"]
            .as_array()
            .unwrap()
            .iter()
            .map(|m| b64(m.as_str().unwrap()))
            .collect();
        let revealed: Vec<u32> = v["revealed"]
            .as_array()
            .unwrap()
            .iter()
            .map(|i| i.as_u64().unwrap() as u32)
            .collect();
        let revealed_msgs: Vec<Vec<u8>> = revealed
            .iter()
            .map(|i| messages[*i as usize].clone())
            .collect();

        assert!(
            call_verify(&public_key, &proof, &revealed_msgs, &nonce),
            "native must accept MATTR blsCreateProof golden"
        );

        let created = call_create(&public_key, &signature, &messages, &revealed, &nonce);
        assert!(
            call_verify(&public_key, &created, &revealed_msgs, &nonce),
            "native createProof must verify with native verifyProof"
        );

        // Export for optional MATTR cross-check on the host:
        // node tool/bbs_verify_proof_mattr.mjs < native/bbs/testdata/last_created_proof.json
        let export = serde_json::json!({
            "publicKey": v["publicKey"],
            "nonce": v["nonce"],
            "messages": revealed
                .iter()
                .map(|i| v["messages"][*i as usize].clone())
                .collect::<Vec<_>>(),
            "proof": base64::engine::general_purpose::STANDARD.encode(&created),
        });
        let export_path =
            concat!(env!("CARGO_MANIFEST_DIR"), "/testdata/last_created_proof.json");
        fs::write(export_path, serde_json::to_string_pretty(&export).unwrap()).unwrap();
    }
}
