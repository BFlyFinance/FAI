address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module TestConfig {

    //    use 0x1::Debug;
    //    use 0x1::Signer;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Config;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TestHelper;
    #[test(account = @0xb987F1aB0D7879b2aB421b98f96eFb44) ]
    fun test_config(account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        let config = config_builder(1u128);
        Config::publish_new_config_with_capability<STCVaultPoolA::VaultPool>(&account, config);
        let get_config = Config::get<STCVaultPoolA::VaultPool>();
        assert_same_config(get_config, 1);
        let config_2 = config_builder(2u128);
        Config::update_config<STCVaultPoolA::VaultPool>(config_2);
        let get_config = Config::get<STCVaultPoolA::VaultPool>();
        assert_same_config(get_config, 2);
    }

    #[test(account = @0xf8af03dd08de49d81e4efd9e24c038cc) ]
    #[expected_failure(abort_code = 51459)]
    fun test_config_not_admin(account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        let config = config_builder(1u128);
        Config::publish_new_config_with_capability<STCVaultPoolA::VaultPool>(&account, config);
    }

//    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
//    account = @0x0000000000000000000000000a550c18 ) ]
//    fun test_config_other_account_update_error(admin: signer, account: signer) {
//        let std_signer = TestHelper::init_stdlib();
//        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
//        let config = config_builder(1u128);
//        Config::publish_new_config_with_capability<STCVaultPoolA::VaultPool>(&admin, config);
//        let get_config = Config::get<STCVaultPoolA::VaultPool>();
//        assert_same_config(get_config, 1);
//        let config_2 = config_builder(2u128);
//        Config::update_config<STCVaultPoolA::VaultPool>(config_2);
//        let get_config = Config::get<STCVaultPoolA::VaultPool>();
//        assert_same_config(get_config, 2);
//    }

    fun assert_same_config<T: copy + store + drop>(c: Config::VaultPoolConfig<T>, x: u128) {
        let config_build = config_builder<T>(x);
        let rst = c == config_build;
        assert(rst, 666);
    }

    fun config_builder<T: copy + store + drop>(x: u128): Config::VaultPoolConfig<T> {
        Config::new_config(
            100000u128 * x,
            10u128 * x,
            10u128 * x,
            10u128 * x,
            10000 * x,
            10u128 * x,
            90000
        )
    }
}
}
