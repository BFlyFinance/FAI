address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module U256 {
    use 0x1::Vector;
    use 0x1::Errors;

    //    use 0x1::Debug;

    const ZERO: u8 = 0;
    const U8_MAX: u8 = 255u8;
    const U64_MAX: u64 = 18446744073709551615u64;

    const U128_MAX: u128 = 340282366920938463463374607431768211455u128;

    const ARITHMETIC_ERROR: u64 = 1;

    const INDEX: vector<u8> = b"0123456789";

    struct U256 has store, copy, drop {
        val: vector<u8>,
    }


    public fun from_u8(value: u8): U256 {
        from_u128((value as u128))
    }

    public fun from_u64(value: u64): U256 {
        from_u128((value as u128))
    }

    public fun from_u128(value: u128): U256 {
        U256 {
            val: pack(value)
        }
    }


    public fun as_u8(value: U256): u8 {
        let v = as_u128(value);
        assert(v <= (U8_MAX as u128), Errors::invalid_argument(ARITHMETIC_ERROR));
        (v as u8)
    }

    public fun as_u64(value: U256): u64 {
        let v = as_u128(value);
        assert(v <= (U64_MAX as u128), Errors::invalid_argument(ARITHMETIC_ERROR));
        (v as u64)
    }

    public fun as_u128(value: U256): u128 {
        let v = val(value);
        inner_as_u128(v)
    }

    fun inner_as_u128(v: vector<u8>): u128 {
        let length = Vector::length(&v);
        let i = 0;
        let rst = 0u128;
        while (i < length) {
            let v = Vector::pop_back(&mut v);
            rst = rst + (v as u128) * pow(10, i);
            i = i + 1;
        } ;
        rst
    }

    public fun from_string(v: vector<u8>): U256 {
        if (Vector::is_empty(&v)) {
            return from_u8(0)
        };
        let i = 0;
        let len = Vector::length(&v);
        let vec = Vector::empty();

        while (i < len) {
            let t: u8 = Vector::pop_back(&mut v);
            let (exists, index) = Vector::index_of<u8>(&INDEX, &t);
            assert(exists, Errors::invalid_argument(ARITHMETIC_ERROR));
            Vector::push_back(&mut vec, (index as u8));
            i = i + 1;
        };
        Vector::reverse<u8>(&mut vec);
        U256 {
            val: vec
        }
    }

    public fun from_binary_string(v: vector<u8>): vector<u8> {
        let i = 0;
        let len = Vector::length(&v);
        let vec = Vector::empty();

        while (i < len) {
            let t: u8 = Vector::pop_back(&mut v);
            let (exists, index) = Vector::index_of<u8>(&INDEX, &t);
            assert(exists, Errors::invalid_argument(ARITHMETIC_ERROR));
            let v = u8_to_binary((index as u8));
            Vector::append(&mut vec, v);
            i = i + 1;
        };
        Vector::reverse<u8>(&mut vec);
        vec
    }

    public fun add(l: U256, r: U256, radix: u8): U256 {
        let l_vec = val(l);
        let r_vec = val(r);
        let vec = inner_add(l_vec, r_vec, radix);
        U256 {
            val: vec
        }
    }

    public fun inner_add(l_vec: vector<u8>, r_vec: vector<u8>, radix: u8): vector<u8> {
        let vec = Vector::empty();
        let (ll, lr) = (Vector::length(&l_vec), Vector::length(&r_vec));
        let (carry, p1, p2) = (0, ll - 1, lr - 1);
        let hit = 0;
        while (p1>=0 || p2 >=0  ) {
            let (x1, x2) = (0, 0);
            if (p1>=0 && hit <ll) { x1 = *Vector::borrow(&l_vec, p1); };
            if (p2>=0 && hit <lr) { x2 = *Vector::borrow(&r_vec, p2); };
            let value = (x1 + x2 + carry);
            carry = value / radix;
            Vector::push_back(&mut vec, value % radix);
            hit = hit + 1;
            if (p1 == 0 && p2 == 0) { break };
            if (p1 > 0) { p1 = p1 - 1; };
            if (p2 > 0) { p2 = p2 - 1; };
        };
        if (carry == 1) {
            Vector::push_back(&mut vec, 1);
        };
        Vector::reverse<u8>(&mut vec);
        vec
    }

    public fun sub(l: U256, r: U256, radix: u8): U256 {
        let l_vec = val(l);
        let r_vec = val(r);
        let vec = inner_sub(l_vec, r_vec, radix);
        U256 {
            val: vec
        }
    }

    public fun inner_sub(l_vec: vector<u8>, r_vec: vector<u8>, radix: u8): vector<u8> {
        let vec = Vector::empty();
        let (ll, lr) = (Vector::length(&l_vec), Vector::length(&r_vec));
        let (carry, p1, p2) = (0, ll - 1, lr - 1);
        let hit = 0;
        while (p1>=0 || p2 >=0  ) {
            let (x1, x2) = (0, 0);
            if (p1>=0 && hit <ll) { x1 = *Vector::borrow(&l_vec, p1); };
            if (p2>=0 && hit <lr) { x2 = *Vector::borrow(&r_vec, p2); };
            let value = (radix + x1 - x2 - carry) % radix;
            if ( x1 >= (x2 + carry)) {
                carry = 0;
            }else {
                carry = 1;
            };
            Vector::push_back(&mut vec, value);
            hit = hit + 1;
            if (p1 == 0 && p2 == 0) { break };
            if (p1 > 0) { p1 = p1 - 1; };
            if (p2 > 0) { p2 = p2 - 1; };
        };
        assert(carry == 0, Errors::invalid_argument(ARITHMETIC_ERROR));
        Vector::reverse<u8>(&mut vec);
        vec
    }


    public fun to_radix_2(number: U256): vector<u8> {
        let v = val(number);
        let i = 0;
        let ll = Vector::length(&v);

        if (ll == 1) {
            let r = u8_to_binary(Vector::remove(&mut v, 0));
            return r
        };
        let vec = Vector::empty();
        while (i < ll) {
            if (i == 0) {
                let m = Vector::remove(&mut v, 0);
                let r = u8_to_binary(m);
                Vector::append(&mut vec, copy r);
                Vector::push_back(&mut vec, 0);
                Vector::push_back(&mut vec, 0);
                vec = inner_add(copy vec, r, 2);
                Vector::push_back(&mut vec, 0);
            };
            if (i == 1) {
                let n = Vector::remove(&mut v, 0);
                let r1 = u8_to_binary(n);
                vec = inner_add(copy vec, r1, 2);
            };
            if (i>1) {
                let o_vec = copy vec;
                Vector::push_back(&mut vec, 0);
                Vector::push_back(&mut vec, 0);
                vec = inner_add(copy vec, o_vec, 2);
                Vector::push_back(&mut vec, 0);
                let n = Vector::remove(&mut v, 0);
                let r1 = u8_to_binary(n);
                vec = inner_add(copy vec, r1, 2);
            };
            i = i + 1;
        };
        vec
    }


    fun max(a: u128, b: u128): u128 {
        if (a >b ) {
            return a
        };
        return b
    }

    fun pow(base: u64, exp: u64): u128 {
        let result_val = 1u128;
        let i = 0;
        while (i < exp) {
            result_val = result_val * (base as u128);
            i = i + 1;
        };
        result_val
    }

    fun pack(value: u128): vector<u8> {
        let vec = Vector::empty<u8>();
        if (value <10) {
            return Vector::singleton((value as u8))
        };
        while (value > 0) {
            let i = value % 10u128;
            Vector::push_back(&mut vec, (i as u8));
            value = value / 10u128;
        };
        Vector::reverse<u8>(&mut vec);
        vec
    }

    public fun val(value: U256): vector<u8> {
        let vec = *&value.val;
        vec
    }


    public fun u8_to_binary(value: u8): vector<u8> {
        if (value == 0) {
            return Vector::singleton(0)
        };
        if (value == 1) {
            return Vector::singleton(1)
        };
        let vec = Vector::empty<u8>();
        while (value > 0) {
            let i = value % 2;
            Vector::push_back(&mut vec, (i as u8));
            value = value / 2;
        };
        Vector::reverse<u8>(&mut vec);
        vec
    }


    public fun binary_to_u128(vec: vector<u8>): u128 {
        let ll = Vector::length(&vec);
        assert(ll <=128, Errors::invalid_argument(ARITHMETIC_ERROR));
        let i = 0;
        let j = ll - 1;
        let rst = 0u128;
        while (i < ll) {
            let n = *Vector::borrow(&vec, i);
            let x = 0u128;
            if (j >0) {
                x = 2 << (j - 1 as u8) ;
                j = j - 1;
            };

            let m = x * (n as u128);
            rst = m + rst;
            i = i + 1;
        };
        //        Debug::print(&rst);
        rst
    }


    fun get_upper(ver: &vector<u8>, half: u64): vector<u8> {
        let l = Vector::length(ver);
        if ( l <= half) {
            return Vector::empty()
        };
        let rst = Vector::empty();
        let start_at = 0;
        let end_at = l - half;
        while (start_at <end_at  ) {
            let m = *Vector::borrow(ver, start_at);
            Vector::push_back(&mut rst, m);
            start_at = start_at + 1;
        };
        rst
    }

    fun get_lower(ver: &vector<u8>, half: u64): vector<u8> {
        let l = Vector::length(ver);
        if ( l <= half) {
            return *ver
        };

        let rst = Vector::empty();
        let start_at = l - half ;
        while (start_at < l ) {
            let m = *Vector::borrow(ver, start_at);
            Vector::push_back(&mut rst, m);
            start_at = start_at + 1;
        };
        rst
    }


    public fun multiply_karatsuba(l: U256, r: U256): U256 {
        let l_vec = val(copy l);
        let r_vec = val(copy r);
        let (ll, lr) = (Vector::length(&l_vec), Vector::length(&r_vec));

        if (ll <10 && lr < 10) {
            let rst = as_u128(l) * as_u128(r);
            return from_u128(rst)
        };

        let half = (max((ll as u128), (lr as u128)) + 1) / 2;
        //        Debug::print(&half);
        let xl = get_lower(&l_vec, (half as u64));
        let xh = get_upper(&l_vec, (half as u64));
        let yl = get_lower(&r_vec, (half as u64));
        let yh = get_upper(&r_vec, (half as u64));


        let p1 = multiply_karatsuba(U256 { val: copy xh }, U256 { val: copy yh });
        let p2 = multiply_karatsuba(U256 { val: copy  xl }, U256 { val: copy yl });


        let x1 = add(U256 { val: copy xh }, U256 { val: copy  xl }, 10);
        let x2 = add(U256 { val: copy yh }, U256 { val: copy yl }, 10);
        let p3 = multiply_karatsuba(x1, x2);
        // result = p1 * 2^(32*2*half) + (p3 - p1 - p2) * 2^(32*half) + p2
        let m1 = shift_left(copy p1, 32 * (half as u64));
        let n1 = sub(sub(copy p3, copy p1, 10), copy p2, 10);
        let m2 = shift_left(copy n1, 32 * (half as u64));
        let o1 = add(copy m1, copy m2, 10);
        let o2 = add(copy o1, copy p2, 10);
        o2
    }

    fun shift_left(p1: U256, n: u64): U256 {
        //        Debug::print(&p1);

        let p128 = as_u128(p1);
        //        Debug::print(&p128);
        //        Debug::print(&n);

        let r = p128<< (n as u8);

        from_u128(r)
    }


    public fun multiply(l: U256, r: U256): U256 {
        let l_vec = val(l);
        let r_vec = val(r);
        let (ll, lr) = (Vector::length(&l_vec), Vector::length(&r_vec));

        let max = ll + lr;
        if ( max <32) {
            let rstu128 = inner_as_u128(l_vec) * inner_as_u128(r_vec);
            return from_u128(rstu128)
        };
        let vec = Vector::empty();
        let t = 0;
        while (t < (ll + lr)) {
            Vector::push_back(&mut vec, 0);
            t = t + 1;
        };

        if (ll < lr) {
            let swap = copy l_vec;
            l_vec = copy r_vec;
            r_vec = swap;
        };
        let (ll, lr) = (Vector::length(&l_vec), Vector::length(&r_vec));
        let i = ll - 1;
        while (i >= 0) {
            let n1 = *Vector::borrow(&l_vec, i);
            let j = lr - 1;
            while (j >= 0) {
                let n2 = *Vector::borrow(&r_vec, j);
                let sum = *Vector::borrow(&vec, i + j + 1) + n1 * n2;
                let a = Vector::borrow_mut<u8>(&mut vec, i + j + 1);
                let x = copy sum % 10;
                *a = (x as u8);
                let b = Vector::borrow_mut<u8>(&mut vec, i + j);
                let y = copy sum / 10;
                *b = ((*b as u8) + y as u8);
                if (j == 0  ) { break };
                j = j - 1;
            };
            if (i == 0) { break };
            i = i - 1;
        };
        let rst = Vector::empty();
        let o = 0;
        let start = false;
        while (o < (ll + lr)) {
            let p = *Vector::borrow(&vec, o);
            if (!start && p>0) {
                start = true;
            };
            if (start) {
                Vector::push_back(&mut rst, p);
            };
            o = o + 1;
        };
        U256 {
            val: rst
        }
    }

    public fun div(_l: U256, _r: U256): U256 {

//        let l_vec = val(l);
//        let r_vec = val(r);
//        let (ll, lr) = (Vector::length(&l_vec), Vector::length(&r_vec));

        U256 {
            val: Vector::empty()
        }
    }
}
}