address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module FAI {
    use 0x1::Token ;
    use 0x1::Signer;
    use 0x1::Account;
    use 0x1::Treasury;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Admin;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Config;

    struct FAI has copy, drop, store {}

    const FAI_PRECISION: u8 = 9;


    struct SharedTreasuryWithdrawCapability has key, store {
        cap: Treasury::WithdrawCapability<FAI>,
    }

    public fun initialize(account: &signer): (Token::MintCapability<FAI>, Token::BurnCapability<FAI>) {
        Admin::is_admin_address(Signer::address_of(account));
        Token::register_token<FAI>(account, FAI_PRECISION);
        Account::do_accept_token<FAI>(account);
        let mint_cap = Token::remove_mint_capability<FAI>(account);
        let burn_cap = Token::remove_burn_capability<FAI>(account);
        (mint_cap, burn_cap)
    }

    public fun mint_with_cap(amount: u128, cap: &Token::MintCapability<FAI>): Token::Token<FAI>
    {
        Config::check_global_switch();
        Token::mint_with_capability<FAI>(
            cap,
            amount
        )
    }

    public fun burn_with_cap(amount: Token::Token<FAI>, cap: &Token::BurnCapability<FAI>)
    {
        Config::check_global_switch();
        Token::burn_with_capability<FAI>(
            cap,
            amount
        )
    }

    public fun deposit_to_treasury(amount: Token::Token<FAI>) {
        Config::check_global_switch();
        Treasury::deposit<FAI>(amount)
    }

    public fun treasury_balance(): u128 {
        Treasury::balance<FAI>()
    }
}
}
