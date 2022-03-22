address FaiAdmin {
//#[test_only]
module TestHelper {
    use StarcoinFramework::Token;
    use StarcoinFramework::Account;
    use StarcoinFramework::Signer;
    use StarcoinFramework::STC;
    use StarcoinFramework::ChainId;
    use StarcoinFramework::Oracle;
    use StarcoinFramework::PriceOracle;
    use StarcoinFramework::STCUSDOracle::{ STCUSD};
    use StarcoinFramework::Timestamp;
    use StarcoinFramework::CoreAddresses;
//    use StarcoinFramework::Genesis;
//    use FaiAdmin::FAI;
    use FaiAdmin::Config;
//    use FaiAdmin::Admin;
//    use FaiAdmin::Initialize;
    //    use StarcoinFramework::Debug;

    const PRECISION: u8 = 9;

    struct GenesisSignerCapability has key {
        cap: Account::SignerCapability,
    }

    public fun init_stdlib(): signer {
//        Genesis::initialize_for_unit_tests();
        let stdlib = Account::create_genesis_account(CoreAddresses::GENESIS_ADDRESS());
        Timestamp::initialize(&stdlib, 1655797763000u64);
        Token::register_token<STC::STC>( & stdlib, 9u8);
        ChainId::initialize(&stdlib, 254);
        Oracle::initialize(&stdlib);
        let cap = Account::remove_signer_capability( &stdlib);
        let genesis_cap = GenesisSignerCapability { cap: cap };
        move_to( &stdlib, genesis_cap);
//        GenesisSignerCapability::initialize(&stdlib, cap);
        let admin_address = @FaiAdmin;
        let admin_signer = Account::create_genesis_account(admin_address);
        let cap = Account::remove_signer_capability( &admin_signer);
        let genesis_cap = GenesisSignerCapability { cap: cap };
        move_to( &admin_signer, genesis_cap);
//        STCUSDOracle::register(&admin_signer);
//        init_oracle(&admin_signer);
        stdlib
    }

    public fun update_price(signer: &signer, amount: u128) {
        PriceOracle::update<STCUSD>(signer, amount);
    }

    public fun init_oracle(sender: &signer) {
        if (!PriceOracle::is_data_source_initialized<STCUSD>(Signer::address_of(sender))) {
            //STCUSDOracle::register(sender);
            PriceOracle::init_data_source<STCUSD>(sender, 1000000);
        };
    }

    public fun init_account_with_stc(account: &signer, amount: u128, stdlib: &signer) {
        let account_address = Signer::address_of(account);
        if (!Account::exists_at(copy account_address)) {
            Account::create_genesis_account(account_address);
        };
        if (amount >0) {
            deposit_stc_to(account, amount, stdlib);
            let stc_balance = Account::balance<STC::STC>(account_address);
            assert!(stc_balance == amount, 999);
        };
//        if (account_address == Admin::admin_address()) {
//            if (!Token::is_registered_in<FAI::FAI>(account_address)) {
//                Initialize::initialize(account);
//            };
//        }
    }

    public fun deposit_stc_to(account: &signer, amount: u128, stdlib: &signer) {
        let is_accept_token = Account::is_accepts_token<STC::STC>(Signer::address_of(account));
        if (!is_accept_token) {
            Account::do_accept_token<STC::STC>(account);
        };
        let total_stc = Token::mint<STC::STC>(stdlib, amount);
        Account::deposit<STC::STC>(Signer::address_of(account), total_stc);
    }

    public fun mint_stc_to(amount: u128, stdlib: &signer): Token::Token<STC::STC> {
        Token::mint<STC::STC>(stdlib, amount)
    }


    public fun wrap_to_stc_amount(amount: u128): u128 {
        amount * pow_10(PRECISION)
    }

    public fun pow_10(exp: u8): u128 {
        pow(10, exp)
    }

    public fun pow(base: u64, exp: u8): u128 {
        let result_val = 1u128;
        let i = 0;
        while (i < exp) {
            result_val = result_val * (base as u128);
            i = i + 1;
        };
        result_val
    }

    public fun set_timestamp(time: u64) acquires GenesisSignerCapability {
        let genesis_cap = borrow_global<GenesisSignerCapability>(CoreAddresses::GENESIS_ADDRESS());
        let genesis_account = Account::create_signer_with_cap(&genesis_cap.cap);
        Timestamp::update_global_time(&genesis_account, time);
    }
    public fun assert_same_config<T: copy + store + drop>(c: Config::VaultPoolConfig<T>, x: u128) {
        let config_build = config_builder<T>(x);
        let rst = c == config_build;
        assert!(rst, 666);
    }

    public fun config_builder<T: copy + store + drop>(x: u128): Config::VaultPoolConfig<T> {
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