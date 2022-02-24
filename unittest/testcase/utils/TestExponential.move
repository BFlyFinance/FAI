address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module TestExponential {
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TestHelper;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Exponential;
   use 0x1::Debug;

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44 ) ]
    fun test(admin: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        let exp = Exponential::exp(51, 1);
        let exp_u128 = Exponential::truncate(copy exp);
//        Debug::print(&exp_u128);
        assert(51  == exp_u128, 1);
        let u = Exponential::mantissa(exp);
        assert(51000000000000000000 == u, 2);

        let exp = Exponential::exp(1, 9);
        Debug::print(&exp);
    }
}
}
    