address FaiAdmin {
module TestConfig {
    #[test_only]
    use FaiAdmin::Config;
    #[test_only]
    use FaiAdmin::STCVaultPoolA;
    #[test_only]
    use FaiAdmin::TestHelper;

    #[test(account = @FaiAdmin) ]
    fun test_config(account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        let config = TestHelper::config_builder(1u128);
        Config::publish_new_config_with_capability<STCVaultPoolA::VaultPool>(&account, config);
        let get_config = Config::get<STCVaultPoolA::VaultPool>();
        TestHelper::assert_same_config(get_config, 1);
        let config_2 = TestHelper::config_builder(2u128);
        Config::update_config<STCVaultPoolA::VaultPool>(config_2);
        let get_config = Config::get<STCVaultPoolA::VaultPool>();
        TestHelper::assert_same_config(get_config, 2);
    }

    #[test(account = @0xf8af03dd08de49d81e4efd9e24c038cc) ]
    #[expected_failure(abort_code = 51459)]
    fun test_config_not_admin(account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        let config = TestHelper::config_builder(1u128);
        Config::publish_new_config_with_capability<STCVaultPoolA::VaultPool>(&account, config);
    }

//    #[test(admin = @FaiAdmin,
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

}
}
