//file is needed for curve25519xsalsa20poly1305
//obtained from https://github.com/goldenMetteyya/microsalt/blob/master/src/shared.rs

//Internal Shared Functions
use std::num::Wrapping as W;

///Typedef: Gf -> i64 [16], representing 256-bit integer in radix 2^16
pub type Gf = [i64;16];
//const gf0 = {0}
const GF0 : Gf = [0; 16];

fn vn(x: &[u8], y: &[u8]) -> isize {
    assert_eq!(x.len(), y.len());
    let mut d = 0u32;
    for i in 0..x.len() {
        d |= (x[i] ^ y[i]) as u32;
    }

    /* FIXME: check this cast. appears this function might be attempting to sign extend. This also
     * affects a bunch of other functions that right now have isize as a return type */
    ((W(1) & ((W(d) - W(1)) >> 8)) - W(1)).0 as isize //(1 & ((d - 1) >> 8)) - 1;
}

/* XXX: public in tweet-nacl */
pub fn verify_16(x: &[u8;16], y: &[u8;16]) -> bool { vn(&x[..], &y[..]) == 0 }

/* XXX: public in tweet-nacl */
pub fn verify_32(x: &[u8;32], y: &[u8;32]) -> bool { vn(&x[..], &y[..]) == 0 }

//load integer mod 2^255 - 19
pub fn unpack25519(o: &mut Gf, n: &[u8]) {
    for i in 0..16 {
        o[i]=n[2*i] as i64+((n[2*i+1] as i64)<<8);
    }
    o[15]&=0x7fff;
}

//256-bit conditional swap
pub fn sel25519(p: &mut Gf,q: &mut Gf, b: isize /* int */) {
    /* XXX: FIXME: check sign extention */
    let c : i64 = !(b - 1) as i64;
    for i in 0..16 {
        let t = c & (p[i]^q[i]);
        p[i]^=t;
        q[i]^=t;
    }
}

//Add 256-bit integers, radix 2^16
pub fn gf_add(o: &mut Gf, a: Gf, b: Gf) {
    for i in 0..16 {
        o[i]=a[i]+b[i];
    }
}

//Subtract 256-bit integers, radix 2^16
pub fn gf_subtract(o: &mut Gf, a: Gf, b: Gf) {
    for i in 0..16 {
        o[i]=a[i]-b[i];
    }
}

//reduce mod 2^255 - 19, radix 2^16
pub fn car25519(o: &mut Gf){
    for i in 0..16 {
        o[i] += 1<<16;
        let c = o[i]>>16;
        o[if i<15 {i+1} else {0}] += c-1 + (if i==15 {37*(c-1)} else {0});
        o[i]-=c<<16;
    }
}

//multiply mod 2^255 - 19, radix 2^16
pub fn gf_multiply(o: &mut Gf, a: Gf, b: Gf) {
    let mut t = [0i64;31];

    for i in 0..16 {
        for j in 0..16 {
            t[i+j] += a[i]*b[j];
        }
    }

    for i in 0..15 {
        t[i] += 38*t[i+16];
    }

    for i in 0..16 {
        o[i]=t[i];
    }

    car25519(o);
    car25519(o);
}

//Square mod 2^255 - 19, radix 2^16
pub fn gf_square(o: &mut Gf, a: Gf) {
    gf_multiply(o,a,a);
}

//Power 2^255 - 21 mod 2^255 - 19
pub fn inv25519(o: &mut Gf, i: Gf) {
    let mut c = GF0;
    for a in 0..16 {
        c[a]=i[a];
    }
    for a in (0..254).rev() {
        /* XXX: avoid aliasing with a copy */
        let mut tmp = GF0;
        gf_square(&mut tmp,c);
        if a!=2 && a!=4 {
            gf_multiply(&mut c,tmp,i);
        } else {
            c = tmp;
        }
    }
    for a in 0..16 {
        o[a]=c[a];
    }
}

//Freeze integer mod 2^255 - 19 and store
pub fn pack25519(o: &mut [u8;32], n: Gf) {
    /* XXX: uninit in tweet-nacl */
    let mut m : Gf = GF0;
    let mut t : Gf = n;

    for i in 0..16 { t[i] = n[i]; }

    car25519(&mut t);
    car25519(&mut t);
    car25519(&mut t);

    for _ in 0..2 {
        m[0]=t[0]-0xffed;
        for i in 1..15 {
            m[i]=t[i]-0xffff-((m[i-1]>>16)&1);
            m[i-1]&=0xffff;
        }
        m[15]=t[15]-0x7fff-((m[14]>>16)&1);
        /* FIXME: check isize casts here, seems like b is a boolean */
        let b : isize = ((m[15]>>16)&1) as isize;
        m[14]&=0xffff;
        /* FIXME: check isize cast here */
        sel25519(&mut t, &mut m, 1-b as isize);
    }
    for i in 0..16 {
        o[2*i]= t[i] as u8; //o[2*i]=t[i]&0xff; compare these later
        o[2*i+1]= (t[i]>>8) as u8;
    }
}

