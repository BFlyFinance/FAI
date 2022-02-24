address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module TestSTCVaultPoolA {

    //    use 0x1::Account;
    //    use 0x1::Signer;
    //    use 0x1::Debug;
    //        use 0x1::STC;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::VaultCounter;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TestHelper;



    #[test(account = @0xb987F1aB0D7879b2aB421b98f96eFb44)]
    fun test_create(account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);

        let pool_exists = STCVaultPoolA::is_exists();
        assert(pool_exists, 101);
//        STCVaultPoolA::initialize(&account, 100000u128, 10u128, 10u128, 10u128, 10u128,100u128);
//        pool_exists = STCVaultPoolA::is_exists();
//        assert(pool_exists, 101);
    }

    #[test(account = @0xb987F1aB0D7879b2aB421b98f96eFb44)]
    #[expected_failure(abort_code = 51718)]
    fun test_alread_create_error(account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
//        STCVaultPoolA::initialize(&account, 100000u128, 10u128, 10u128, 10u128, 10u128,100u128);
        STCVaultPoolA::initialize(&account, 100000u128, 10u128, 10u128, 10u128, 100000u128, 10u128,100u128);
    }

    #[test(account = @0x1) ]
    #[expected_failure(abort_code = 51459)]
    fun test_admin_error(account: signer) {
        STCVaultPoolA::initialize(&account, 100000u128, 10u128, 10u128, 10u128, 100000u128, 10u128,100u128);
    }

    #[test(account = @0x1) ]
    #[expected_failure(abort_code = 51973)]
    fun test_create_vault_not_create_pool(account: signer) {
        STCVaultPoolA::create_vault(&account);
    }

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44, account = @0x0000000000000000000000000a550c18) ]
    fun test_create_vault(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);

//        STCVaultPoolA::initialize(&admin, 100000u128, 10u128, 10u128, 10u128, 10u128,100u128);
        let id = STCVaultPoolA::create_vault(&account);
        let start_at = VaultCounter::get_guid_start_at();
        assert(id == start_at + 1, 303);
        let vault_count = STCVaultPoolA::vault_count();
        assert(vault_count == 1, 304);
    }

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44, account = @0x0000000000000000000000000a550c18) ]
    #[expected_failure(abort_code = 25857)]
    fun test_create_vault_failure(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);

//        STCVaultPoolA::initialize(&admin, 100000u128, 10u128, 10u128, 10u128, 10u128,100u128);
        STCVaultPoolA::create_vault(&account);
        STCVaultPoolA::create_vault(&account);
    }


    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    fun test_deposit(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        let init_amount = TestHelper::wrap_to_stc_amount(1000u128);
        TestHelper::init_account_with_stc(&account, init_amount, &std_signer);

//        STCVaultPoolA::initialize(&admin, 100000u128, 10u128, 10u128, 10u128, 10u128,100u128);
        STCVaultPoolA::create_vault(&account);
        let deposit_amount = TestHelper::wrap_to_stc_amount(999u128);
        let balance = STCVaultPoolA::deposit(&account, deposit_amount);
        assert(balance == deposit_amount, 305);
        let stc_locked = STCVaultPoolA::current_stc_locked();
        assert(stc_locked == deposit_amount, 305);
    }


    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    #[expected_failure(abort_code = 52231)]
    fun test_deposit_insufficient_balance(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        let init_amount = TestHelper::wrap_to_stc_amount(999u128);
        TestHelper::init_account_with_stc(&account, init_amount, &std_signer);
//        STCVaultPoolA::initialize(&admin, 100000u128, 10u128, 10u128, 10u128, 10u128,100u128);
        STCVaultPoolA::create_vault(&account);
        let deposit_amount = TestHelper::wrap_to_stc_amount(1000u128);
        let balance = STCVaultPoolA::deposit(&account, deposit_amount);
        assert(balance == deposit_amount, 305);
    }

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    #[expected_failure(abort_code = 170503)]
    fun test_borrow_mai_more_than_max_supply(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
//        STCVaultPoolA::initialize(&admin, 100u128, 10u128, 10u128, 10u128, 10u128,100u128);
        let init_amount = TestHelper::wrap_to_stc_amount(2000000000000u128);
        TestHelper::init_account_with_stc(&account, init_amount, &std_signer);
        STCVaultPoolA::create_vault(&account);
        STCVaultPoolA::borrow_fai(&account, 10000000000u128);
    }

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    #[expected_failure(abort_code = 52487)]
    fun test_borrow_fai_less_than_min_mint(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
//        STCVaultPoolA::initialize(&admin, 100u128, 10u128, 10u128, 10u128, 10u128,100u128);
        let init_amount = TestHelper::wrap_to_stc_amount(999u128);
        TestHelper::init_account_with_stc(&account, init_amount, &std_signer);
        STCVaultPoolA::create_vault(&account);
        STCVaultPoolA::borrow_fai(&account, 1u128);
    }

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    fun test_max_borrow_fai(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        //        STCVaultPoolA::initialize(&admin, 100u128, 10u128, 10u128, 10u128, 10u128,100u128);
        let init_amount = TestHelper::wrap_to_stc_amount(999u128);
        TestHelper::init_account_with_stc(&account, init_amount, &std_signer);
        STCVaultPoolA::create_vault(&account);
        STCVaultPoolA::borrow_fai(&account, 0u128);
    }

}
}
