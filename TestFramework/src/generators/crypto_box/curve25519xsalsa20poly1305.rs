
//This file is originally from https://raw.githubusercontent.com/goldenMetteyya/microsalt/master/src/boxy/curve25519xsalsa20poly1305.rs
// and is used to be able to get the public and secret key bytes
use crate::generators::crypto_box::shared;
use microsalt::secretbox;
use microsalt::stream;
use index_fixed::*;
use rand::prelude::*;

pub const SECRET_KEY_LEN : usize = 32;
pub const PUBLIC_KEY_LEN : usize = 32;
pub const NONCE_LEN : usize = 24;
pub const ZERO_LEN : usize = 32;
pub const BOX_ZERO_LEN : usize = 16;

pub type BoxPublicKey = [u8; PUBLIC_KEY_LEN];
pub type BoxSecretKey = [u8; SECRET_KEY_LEN];
pub type BoxNonce = [u8; NONCE_LEN];

///Typedef: Gf -> i64 [16], representing 256-bit integer in radix 2^16
pub type Gf = [i64;16];
//const gf0 = {0}
const GF0 : Gf = [0; 16];

//const u8[32] = {9}
const C_9 : [u8;32] = [9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
//const u8[16] = {0}
const C_0 : [u8;16] = [0;16];
//const gf = {0xDB41,1}
const C_121665 : Gf = [0xDB41,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

fn scalarmult(q: &mut [u8;32], n: &[u8;32], p: &[u8;32]) {
    let mut z = *n;
    /* TODO: not init in tweet-nacl */
    let mut x = [0i64;80];

    let mut a = GF0;
    let mut c = a;
    let mut d = a;
    /* TODO: not init in tweet-nacl { */
    let mut e = a;
    let mut f = a;
    /* } */

    z[31]=(n[31]&127)|64;
    z[0]&=248;
    shared::unpack25519(index_fixed!(&mut x;..16),p);
    /* TODO: not init in tweet-nacl */
    let mut b = GF0;
    for i in 0..16 {
        b[i] = x[i];
    }

    a[0]=1;
    d[0]=1;
    for i in (0..255).rev() {
        let r: u8 = (z[i>>3]>>(i&7))&1; //might be i64 not u8
        shared::sel25519(&mut a, &mut b, r as isize);
        shared::sel25519(&mut c, &mut d, r as isize);

        /* XXX: avoid aliasing with an extra copy */
        let mut tmp = GF0;
        shared::gf_add(&mut e,a,c);
        shared::gf_subtract(&mut tmp,a,c);
        a = tmp;
        shared::gf_add(&mut c,b,d);
        shared::gf_subtract(&mut tmp,b,d);
        b = tmp;
        shared::gf_square(&mut d,e);
        shared::gf_square(&mut f,a);
        shared::gf_multiply(&mut tmp,c,a);
        a = tmp;
        shared::gf_multiply(&mut c,b,e);
        shared::gf_add(&mut e,a,c);
        shared::gf_subtract(&mut tmp,a,c);
        a = tmp;
        shared::gf_square(&mut b,a);
        shared::gf_subtract(&mut c,d,f);
        shared::gf_multiply(&mut a,c,C_121665);
        shared::gf_add(&mut tmp,a,d);
        a = tmp;
        shared::gf_multiply(&mut tmp,c,a);
        c = tmp;
        shared::gf_multiply(&mut a,d,f);
        shared::gf_multiply(&mut d,b, *index_fixed!(&x;..16));
        shared::gf_square(&mut b,e);
        shared::sel25519(&mut a, &mut b, r as isize);
        shared::sel25519(&mut c, &mut d, r as isize);
    }
    for i in 0..16 {
        x[i+16]=a[i];
        x[i+32]=c[i];
        x[i+48]=b[i];
        x[i+64]=d[i];
    }
    /* XXX: avoid aliasing with an extra copy */
    let mut tmp = [0i64;16];
    shared::inv25519(&mut tmp, *index_fixed!(&x[32..];..16));
    *index_fixed!(&mut x[32..];..16) = tmp;

    /* XXX: avoid aliasing with an extra copy */
    shared::gf_multiply(&mut tmp, *index_fixed!(&x[16..];..16), *index_fixed!(&x[32..];..16));
    *index_fixed!(&mut x[16..];..16) = tmp;
    shared::pack25519(q, *index_fixed!(&x[16..];..16));
}

fn scalarmult_base(q: &mut [u8;32], n: &[u8;32]) {
    scalarmult(q, n, &C_9)
}

pub fn box_keypair(public_key: &mut BoxPublicKey, secret_key: &mut BoxSecretKey) {
    let mut rng = rand::thread_rng();
    rng.fill_bytes( secret_key);
    scalarmult_base(public_key, secret_key)
}

pub fn box_beforenm(key: &mut[u8;32], public_key: &BoxPublicKey, secret_key: &BoxSecretKey) {
    /* TODO: uninit in tweet-nacl */
    let mut s = [0u8; 32];
    scalarmult(&mut s, secret_key, public_key);
    stream::xsalsa20::core_hsalsa20(key, &C_0, &s, stream::xsalsa20::SIGMA)
}

pub fn box_afternm(cipher: &mut[u8], message: &[u8], nonce: &[u8;24], key: &[u8;32]) -> Result<(),()> {
    secretbox::xsalsa20poly1305::secretbox(cipher, message, nonce, key)
}

pub fn box_open_afternm(m: &mut[u8], c: &[u8], n: &[u8;24], k: &[u8;32]) -> Result<(),()> {
    if secretbox::xsalsa20poly1305::secretbox_open(m,c,n,k) == false {
        Ok(())
    }else {
        Err(())
    }
}

pub fn box_(cipher: &mut [u8], message: &[u8], nonce: &BoxNonce, pk: &BoxPublicKey, sk: &BoxSecretKey) -> Result<(),()> {
    assert_eq!(&message[..32], &[0u8;32]);
    /* FIXME: uninit in tweet-nacl */
    let mut k = [0u8; 32];
    box_beforenm(&mut k, pk, sk);
    box_afternm(cipher, message, nonce, &k)
}

pub fn box_open(message: &mut [u8], cipher: &[u8], nonce: &BoxNonce, pk: &BoxPublicKey, sk: &BoxSecretKey) -> Result<(),()> {
    assert_eq!(&cipher[..16], &[0u8;16]);
    /* FIXME: uninit in tweet-nacl */
    let mut k = [0u8; 32];
    box_beforenm(&mut k, pk, sk);
    box_open_afternm(message, cipher, nonce, &k)
}

///////////////
//Scalar tests
///////////////
//https://github.com/maidsafe/rust_sodium/blob/master/src/crypto/scalarmult/curve25519.rs

#[test]
fn test_scalar_vector_1() {
    // corresponding to tests/scalarmult.c and tests/scalarmult3.cpp from NaCl
    let alicesk = [0x77, 0x07, 0x6d, 0x0a, 0x73, 0x18, 0xa5, 0x7d, 0x3c, 0x16, 0xc1,
        0x72, 0x51, 0xb2, 0x66, 0x45, 0xdf, 0x4c, 0x2f, 0x87, 0xeb, 0xc0,
        0x99, 0x2a, 0xb1, 0x77, 0xfb, 0xa5, 0x1d, 0xb9, 0x2c, 0x2a];

    let alicepk_expected = [0x85, 0x20, 0xf0, 0x09, 0x89, 0x30, 0xa7, 0x54, 0x74, 0x8b, 0x7d,
        0xdc, 0xb4, 0x3e, 0xf7, 0x5a, 0x0d, 0xbf, 0x3a, 0x0d, 0x26, 0x38,
        0x1a, 0xf4, 0xeb, 0xa4, 0xa9, 0x8e, 0xaa, 0x9b, 0x4e, 0x6a];

    let mut alicepk = [0u8; 32];
    scalarmult_base(&mut alicepk, &alicesk);
    assert!(alicepk == alicepk_expected);
}

#[test]
fn test_scalar_vector_2() {
    // corresponding to tests/scalarmult2.c and tests/scalarmult4.cpp from NaCl
    let bobsk = [0x5d, 0xab, 0x08, 0x7e, 0x62, 0x4a, 0x8a, 0x4b, 0x79, 0xe1, 0x7f,
        0x8b, 0x83, 0x80, 0x0e, 0xe6, 0x6f, 0x3b, 0xb1, 0x29, 0x26, 0x18,
        0xb6, 0xfd, 0x1c, 0x2f, 0x8b, 0x27, 0xff, 0x88, 0xe0, 0xeb];

    let bobpk_expected = [0xde, 0x9e, 0xdb, 0x7d, 0x7b, 0x7d, 0xc1, 0xb4, 0xd3, 0x5b, 0x61,
        0xc2, 0xec, 0xe4, 0x35, 0x37, 0x3f, 0x83, 0x43, 0xc8, 0x5b, 0x78,
        0x67, 0x4d, 0xad, 0xfc, 0x7e, 0x14, 0x6f, 0x88, 0x2b, 0x4f];

    let mut bobpk = [0u8; 32];
    scalarmult_base(&mut bobpk, &bobsk);
    assert!(bobpk == bobpk_expected);
}

#[test]
fn test_scalar_vector_3() {
    // corresponding to tests/scalarmult5.c and tests/scalarmult7.cpp from NaCl
    let alicesk = [0x77, 0x07, 0x6d, 0x0a, 0x73, 0x18, 0xa5, 0x7d, 0x3c, 0x16, 0xc1,
        0x72, 0x51, 0xb2, 0x66, 0x45, 0xdf, 0x4c, 0x2f, 0x87, 0xeb, 0xc0,
        0x99, 0x2a, 0xb1, 0x77, 0xfb, 0xa5, 0x1d, 0xb9, 0x2c, 0x2a];

    let bobpk = [0xde, 0x9e, 0xdb, 0x7d, 0x7b, 0x7d, 0xc1, 0xb4, 0xd3, 0x5b,
        0x61, 0xc2, 0xec, 0xe4, 0x35, 0x37, 0x3f, 0x83, 0x43, 0xc8,
        0x5b, 0x78, 0x67, 0x4d, 0xad, 0xfc, 0x7e, 0x14, 0x6f, 0x88,
        0x2b, 0x4f];

    let k_expected = [0x4a, 0x5d, 0x9d, 0x5b, 0xa4, 0xce, 0x2d, 0xe1, 0x72, 0x8e, 0x3b, 0xf4,
        0x80, 0x35, 0x0f, 0x25, 0xe0, 0x7e, 0x21, 0xc9, 0x47, 0xd1, 0x9e, 0x33,
        0x76, 0xf0, 0x9b, 0x3c, 0x1e, 0x16, 0x17, 0x42];

    let mut k = [0u8; 32];
    scalarmult(&mut k, &alicesk, &bobpk);
    assert!(k == k_expected);
}

#[test]
fn test_scalar_vector_4() {
    // corresponding to tests/scalarmult6.c from NaCl
    let bobsk = [0x5d, 0xab, 0x08, 0x7e, 0x62, 0x4a, 0x8a, 0x4b, 0x79, 0xe1, 0x7f,
        0x8b, 0x83, 0x80, 0x0e, 0xe6, 0x6f, 0x3b, 0xb1, 0x29, 0x26, 0x18,
        0xb6, 0xfd, 0x1c, 0x2f, 0x8b, 0x27, 0xff, 0x88, 0xe0, 0xeb];

    let alicepk = [0x85, 0x20, 0xf0, 0x09, 0x89, 0x30, 0xa7, 0x54, 0x74, 0x8b,
        0x7d, 0xdc, 0xb4, 0x3e, 0xf7, 0x5a, 0x0d, 0xbf, 0x3a, 0x0d,
        0x26, 0x38, 0x1a, 0xf4, 0xeb, 0xa4, 0xa9, 0x8e, 0xaa, 0x9b,
        0x4e, 0x6a];

    let k_expected = [0x4a, 0x5d, 0x9d, 0x5b, 0xa4, 0xce, 0x2d, 0xe1, 0x72, 0x8e, 0x3b, 0xf4,
        0x80, 0x35, 0x0f, 0x25, 0xe0, 0x7e, 0x21, 0xc9, 0x47, 0xd1, 0x9e, 0x33,
        0x76, 0xf0, 0x9b, 0x3c, 0x1e, 0x16, 0x17, 0x42];

    let mut k = [0u8; 32];
    scalarmult(&mut k, &bobsk, &alicepk);
    assert!(k == k_expected);
}