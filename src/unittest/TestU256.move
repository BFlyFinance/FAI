address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module TestU256 {

    //    use 0x1::Debug;
    #[test_only]
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::U256;
    #[test]
    fun test_u8_cast_success() {
        assert(U256::as_u8(U256::from_u8(0)) == 0, 0);
        assert(U256::as_u8(U256::from_u8(13)) == 13, 1);
        assert(U256::as_u8(U256::from_u8(255)) == 255, 2);
    }
    #[test]
    fun test_u64_cast_success() {
        assert(U256::as_u64(U256::from_u64(0)) == 0, 0);
        assert(U256::as_u64(U256::from_u64(255)) == 255, 1);
        assert(U256::as_u64(U256::from_u64(256)) == 256, 2);
        assert(U256::as_u64(U256::from_u64(18446744073709551615u64)) == 18446744073709551615u64, 3);
    }

    #[test]
    fun test_u128_cast_success() {
        assert(U256::as_u128(U256::from_u128(0)) == 0, 0);
        assert(U256::as_u128(U256::from_u128(18446744073709551615)) == 18446744073709551615, 1);
        assert(U256::as_u128(U256::from_u128(18446744073709551616)) == 18446744073709551616, 2);
        assert(U256::as_u128(U256::from_u128(340282366920938463463374607431768211455u128)) == 340282366920938463463374607431768211455u128, 3);
    }


    #[test]
    #[expected_failure(abort_code = 263)]
    fun test_u8_cast_error() {
        U256::as_u8(U256::from_u64(256));
    }
    #[test]
    #[expected_failure(abort_code = 263)]
    fun test_u64_cast_error() {
        U256::as_u64(U256::from_u128(18446744073709551616));
    }

    #[test]
    fun test_add() {
        // add
        let l = U256::from_u128(999);
        let r = U256::from_u128(1);
        assert(U256::as_u128(U256::add(l, r, 10)) == 1000, 0);
        let l = U256::from_u128(999);
        let r = U256::from_u128(11111);
        assert(U256::as_u128(U256::add(l, r, 10)) == (999 + 11111), 1);
        let l = U256::from_u128(63374607431768211455u128);
        let r = U256::from_u128(63374607431768211455u128);
        assert(U256::as_u128(U256::add(l, r, 10)) == 126749214863536422910u128, 2);
        let l = U256::from_u128(340282366920938463463374607431768211455u128);
        let r = U256::from_u128(340282366920938463463374607431768211455u128);
        let max = b"680564733841876926926749214863536422910";
        assert(U256::from_string(max) == U256::add(l, r, 10), 3);
    }

    #[test]
    fun test_sub() {
        let l = U256::from_u128(999);
        let r = U256::from_u128(998);
        assert(U256::as_u128(U256::sub(l, r, 10)) == (999 - 998), 1);
        let l = U256::from_u128(63374607431768211456u128);
        let r = U256::from_u128(63374607431768211455u128);
        assert(U256::as_u128(U256::sub(l, r, 10)) == 1u128, 1);

        let l = U256::from_u128(998);
        let r = U256::from_u128(998);
        assert(U256::as_u128(U256::sub(l, r, 10)) == 0, 1);
    }


//    #[test]
//    fun test_binary() {
//        assert(U256::from_binary_string(b"0") == U256::to_radix_2(U256::from_u128(0)), 0);
//        assert(U256::from_binary_string(b"1") == U256::to_radix_2(U256::from_u128(1)), 1);
//        assert(U256::from_binary_string(b"10") == U256::to_radix_2(U256::from_u128(2)), 1);
//        assert(U256::from_binary_string(b"1100011") == U256::to_radix_2(U256::from_u128(99)), 1);
//        let binary = b"11101111011000110101001011000100";
//        let number = 4016263876;
//        assert(U256::from_binary_string(binary) == U256::to_radix_2(U256::from_u128(number)), 2);
//        let binary = b"11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
//        let number = 340282366920938463463374607431768211455u128;
//        let u256 = U256::from_u128(number);
//        let ttt = U256::to_radix_2(u256);
//        assert(U256::from_binary_string(binary) ==ttt, 2);
//    }
//
//
//
//    #[test]
//    public fun test_mult() {
//        let a = 22;
//        let b = 22;
//        let u = U256::multiply(U256::from_u128(a), U256::from_u128(b));
//        assert(u == U256::from_u128(a * b), 0);
//        let a = 99999;
//        let b = 1;
//        let u = U256::multiply(U256::from_u128(a), U256::from_u128(b));
//        assert(u == U256::from_u128(a * b), 1);
//
//        a = 18446744073709551615;
//        b = 18446744073709551615;
//        u = U256::multiply(U256::from_u128(a), U256::from_u128(b));
//        assert(u == U256::from_u128(a * b), 2);
//
//        a = 340282366920938463463374607431768211455u128;
//        b = 340282366920938463463374607431768211455u128;
//        let rst = U256::from_string(b"115792089237316195423570985008687907852589419931798687112530834793049593217025");
//        u = U256::multiply(U256::from_u128(a), U256::from_u128(b));
//        assert(u == rst, 3);
//        let a = U256::from_string(b"115792089237316195423570985008687907852589419931798687112530834793049593217025");
//        let b = U256::from_string(b"115792089237316195423570985008687907852589419931798687112530834793049593217025");
//        let rst = U256::from_string(b"13407807929942597099574024998205846127321757795806815460874445283321189574853922772255436408667651679983101098547615467186622977422789799388824888749850625");
//        u = U256::multiply(a, b);
//        assert(u == rst, 4);
//    }
}
}
