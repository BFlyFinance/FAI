//#[test_only]
address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module TestVault {
    use 0x1::Signer;
    use 0x1::STC;
    use 0x1::Timestamp;
//        use 0x1::Account;
    use 0x1::Debug;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Vault;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::VaultCounter;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TestHelper;

    #[test(account = @0x1)]
    #[expected_failure(abort_code = 26119)]
    fun test_deposit_not_exist(account: &signer) {
        Vault::deposit<STCVaultPoolA::VaultPool, STC::STC>(account, 0);
    }


    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    fun test_deposit(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        create_value( &account);

        let balance = Vault::balance<STCVaultPoolA::VaultPool, STC::STC>( Signer::address_of(&account));
        assert(balance == 0, 305);
        let amount: u128 = TestHelper::wrap_to_stc_amount(1000u128);
        let balance = deposit(&account, amount, &std_signer);
        assert(balance == amount, 305);
    }


    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    fun test_borrow_fai(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        create_value( &account);
        let deposit_amount: u128 = TestHelper::wrap_to_stc_amount(1000u128);
        let _ = deposit(&account, deposit_amount, &std_signer);
//
        let ts = Timestamp::now_seconds();
        let borrow_mai = 20u128;
        let balance = Vault::borrow_fai<STCVaultPoolA::VaultPool, STC::STC>(&account, borrow_mai);
        assert(balance == borrow_mai, 11);

        let up_ts =Vault::last_update_at<STCVaultPoolA::VaultPool, STC::STC>(&Signer::address_of(&account));
        assert(ts==up_ts,12);

        Debug::print(&ts);
        Debug::print(&up_ts);
    }

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    fun test_borrow_max_fai(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        create_value( &account);
        let stc_amount = 3000u128;
        let deposit_amount: u128 = TestHelper::wrap_to_stc_amount(stc_amount);
        let _ = deposit(&account, deposit_amount, &std_signer);
        //
        let ts = Timestamp::now_seconds();
        let borrow_mai = 0u128;
        let balance = Vault::borrow_fai<STCVaultPoolA::VaultPool, STC::STC>(&account, borrow_mai);
        assert(balance == stc_amount*1000000000/3, 11);

        let up_ts =Vault::last_update_at<STCVaultPoolA::VaultPool, STC::STC>(&Signer::address_of(&account));
        assert(ts==up_ts,12);
    }

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    fun test_withdraw_max(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        create_value( &account);
        let stc_amount = 4000u128;
        let deposit_amount: u128 = TestHelper::wrap_to_stc_amount(stc_amount);
        let _ = deposit(&account, deposit_amount, &std_signer);
        //
        let ts = Timestamp::now_seconds();
        let borrow_fai = 1000000000000u128;
        let balance = Vault::borrow_fai<STCVaultPoolA::VaultPool, STC::STC>(&account, borrow_fai);
        assert(balance == borrow_fai, 11);
        let max_withdraw = Vault::withdraw<STCVaultPoolA::VaultPool, STC::STC>(&account, 0u128);
        0x1::Debug::print(&555555);
        0x1::Debug::print(&max_withdraw);
        assert(max_withdraw == 1000000000000u128, 12);

        let up_ts =Vault::last_update_at<STCVaultPoolA::VaultPool, STC::STC>(&Signer::address_of(&account));
        assert(ts==up_ts,12);
    }

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    fun test_repay_max(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        create_value( &account);
        let stc_amount = 4000u128;
        let deposit_amount: u128 = TestHelper::wrap_to_stc_amount(stc_amount);
        let _ = deposit(&account, deposit_amount, &std_signer);
        //
        let ts = Timestamp::now_seconds();
        let borrow_fai = 1000000000000u128;
        let balance = Vault::borrow_fai<STCVaultPoolA::VaultPool, STC::STC>(&account, borrow_fai);
        assert(balance == borrow_fai, 11);
        let (debt, fee) = Vault::repay_fai<STCVaultPoolA::VaultPool, STC::STC>(&account, 0u128);
        assert(debt == 1000000000000u128, 12);
        assert(fee == 0u128, 12);

        let up_ts =Vault::last_update_at<STCVaultPoolA::VaultPool, STC::STC>(&Signer::address_of(&account));
        assert(ts==up_ts,12);
    }

    #[test(admin = @0xb987F1aB0D7879b2aB421b98f96eFb44,
    account = @0x0000000000000000000000000a550c18 ) ]
    #[expected_failure(abort_code = 52487)]
    fun test_deposit_max(admin: signer, account: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        TestHelper::init_account_with_stc(&account, 0u128, &std_signer);
        create_value( &account);
        let stc_amount = 100000u128;
        let deposit_amount: u128 = TestHelper::wrap_to_stc_amount(stc_amount);
        let _ = deposit(&account, deposit_amount, &std_signer);
    }


    struct TestConfig  has drop {
        max_mai_supply: u128,
        min_mint_amount: u128,
        stability_fee_ratio: u128,
        liquidation_ratio: u128,
        liquidation_penalty: u128,
        liquidation_threshold: u128,
    }

    fun create_value(account: &signer) {
//        STCVaultPoolA::initialize(admin, config.max_mai_supply,
//            config.min_mint_amount, config.stability_fee_ratio,
//            config.liquidation_ratio, config.liquidation_penalty,config.liquidation_threshold);
        let id = STCVaultPoolA::create_vault(account);
        let start_at = VaultCounter::get_guid_start_at();
        assert(id == start_at + 1, 303);
        let vault_count = STCVaultPoolA::vault_count();
        assert(vault_count == 1, 304);

        let balance = Vault::balance<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(account));
        assert(balance == 0, 305);
    }

    fun deposit(account: &signer, amount: u128, std_signer: &signer, ): u128 {
        TestHelper::deposit_stc_to(account,amount, std_signer);

        Vault::deposit<STCVaultPoolA::VaultPool, STC::STC>(account, amount)

    }
}
}
