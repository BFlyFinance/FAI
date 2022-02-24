address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module TestHelper {
    use 0x1::Token;
    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::STC;
    use 0x1::ChainId;
    use 0x1::Oracle;
    use 0x1::PriceOracle;
    use 0x1::STCUSDOracle::{Self, STCUSD};
    use 0x1::Timestamp;
    use 0x1::CoreAddresses;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::FAI;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Admin;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Initialize;
    //    use 0x1::Debug;

    const PRECISION: u8 = 9;

    struct GenesisSignerCapability has key {
        cap: Account::SignerCapability,
    }

    public fun init_stdlib(): signer {
        let stdlib = Account::create_genesis_account(@0x1);
        Timestamp::initialize( & stdlib, 1631244104193u64);
        Token::register_token<STC::STC>( & stdlib, 9u8);
        ChainId::initialize(&stdlib, 254);
        Oracle::initialize(&stdlib);
        let admin_address = @0x4FFCC98F43ce74668264a0CF6Eebe42b;
        let admin_signer = Account::create_genesis_account(admin_address);
        STCUSDOracle::register(&admin_signer);
        init_oracle(&admin_signer);
        let cap = Account::remove_signer_capability( & stdlib);
        let genesis_cap = GenesisSignerCapability { cap };
        move_to( & stdlib, genesis_cap);
        stdlib
    }

    public fun update_price(signer: &signer, amount: u128)acquires GenesisSignerCapability {
        let now = Timestamp::now_milliseconds();

        set_timestamp(now + 1);
        PriceOracle::update<STCUSD>(signer, amount);
    }

    fun init_oracle(sender: &signer) {
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
            assert(stc_balance == amount, 999);
        };
        if (account_address == Admin::admin_address()) {
            if (!Token::is_registered_in<FAI::FAI>(account_address)) {
                Initialize::initialize(account);
            };
        }
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
}
}