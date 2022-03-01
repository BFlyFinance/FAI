address FaiAdmin {
module Vault {

    use StarcoinFramework::Token ;
    use StarcoinFramework::Errors;
    use StarcoinFramework::Signer;
    use StarcoinFramework::Account;
    use StarcoinFramework::Timestamp;
    use FaiAdmin::FAI;
    use FaiAdmin::Rate;
    use FaiAdmin::Admin;
    use FaiAdmin::Config;
    use FaiAdmin::Treasury;
    use FaiAdmin::Liquidation;

    const VAULT_EXISTS: u64 = 101;
    const VAULT_NOT_EXISTS: u64 = 102;
    const NOT_SAME_TOKEN: u64 = 103;
    const U128_MAX: u128 = 340282366920938463463374607431768211455u128;
    const INSUFFICIENT_BALANCE: u64 = 204;
    const WRONG_AMOUNT: u64 = 205;

    struct Vault<phantom VaultPoolType: store, phantom TokenType: store> has key, store {
        debt_fai_amount: u128,
        unpay_stability_fee: u128,
        token: Token::Token<TokenType>,
        id: u64,
        last_update_at: u64,
    }

    struct SharedMintCapability has key, store {
        cap: Token::MintCapability<FAI::FAI>,
    }

    struct SharedBurnCapability has key, store {
        cap: Token::BurnCapability<FAI::FAI>,
    }

    public fun initialize(account: &signer) {
        let (mint_cap, burn_cap) = FAI::initialize(account);
        Treasury::initialize<FAI::FAI>(account);
        move_to(account, SharedMintCapability{cap: mint_cap});
        move_to(account, SharedBurnCapability{cap: burn_cap});
    }

    public fun create_vault<VaultPoolType: store, TokenType: store>(account: &signer, guid: u64) {
        Config::check_global_switch();
        assert!(
            !vault_exist<VaultPoolType, TokenType>(Signer::address_of(account)),
            Errors::invalid_state(VAULT_EXISTS)
        );
        let vault = Vault<VaultPoolType, TokenType> {
            debt_fai_amount: 0u128,
            unpay_stability_fee: 0u128,
            token: Token::zero<TokenType>(),
            id: guid,
            last_update_at: Timestamp::now_seconds()
        };
        move_to(account, vault);
    }

    public fun vault_exist<VaultPoolType: store, TokenType: store>(address: address): bool {
        exists<Vault<VaultPoolType, TokenType>>(address)
    }


    public fun deposit<VaultPoolType: copy+store+drop, TokenType: store>(account: &signer, amount: u128): u128
    acquires Vault {
        Config::check_global_switch();
        assert!(
            vault_exist<VaultPoolType, TokenType>(Signer::address_of(account)),
            Errors::invalid_argument(VAULT_NOT_EXISTS)
        );
        let config = Config::get<VaultPoolType>();
        let (_, _, _, _, max_deposit_per_vault, _, _) = Config::unpack<VaultPoolType>(config);
        let vault = borrow_global_mut<Vault<VaultPoolType, TokenType>>(Signer::address_of(account));
        assert!(
            balance_for<VaultPoolType, TokenType>(vault) + amount <= max_deposit_per_vault,
            Errors::invalid_argument(WRONG_AMOUNT)
        );
        let tokens = Account::withdraw<TokenType>(account, amount);
        Token::deposit<TokenType>(&mut vault.token, tokens);
        balance<VaultPoolType, TokenType>(Signer::address_of(account))
    }

    public fun balance<VaultPoolType: store, TokenType: store>(address: address): u128
    acquires Vault {
        let vault = borrow_global<Vault<VaultPoolType, TokenType>>(address);
        balance_for<VaultPoolType, TokenType>(vault)
    }

    public fun last_update_at<VaultPoolType: store, TokenType: store>(account: &address): u64
    acquires Vault {
        let vault = borrow_global<Vault<VaultPoolType, TokenType>>(*account);
        vault.last_update_at
    }

    fun balance_for<VaultPoolType: store, TokenType: store>
    (vault: &Vault<VaultPoolType, TokenType>): u128 {
        Token::value<TokenType>(&vault.token)
    }

    public fun info<VaultPoolType: store + drop + copy, TokenType: store>
    (address: address): (u64, u128, u128, u128, u64) acquires Vault {
        let vault = borrow_global<Vault<VaultPoolType, TokenType>>(address);
        let stability_fee = Rate::stability_fee<VaultPoolType>(vault.debt_fai_amount, vault.unpay_stability_fee, vault.last_update_at);
        (vault.id,
            vault.debt_fai_amount,
            vault.unpay_stability_fee + stability_fee,
            balance_for<VaultPoolType, TokenType>(vault),
            Timestamp::now_seconds())
    }

    public fun withdraw<VaultPoolType: store + drop + copy, TokenType: store>(account: &signer, amount: u128): u128 acquires Vault {
        Config::check_global_switch();
        assert!(
            vault_exist<VaultPoolType, TokenType>(Signer::address_of(account)),
            Errors::invalid_argument(VAULT_NOT_EXISTS)
        );
        let vault = borrow_global_mut<Vault<VaultPoolType, TokenType>>(Signer::address_of(account));
        let stability_fee = Rate::stability_fee<VaultPoolType>(vault.debt_fai_amount, vault.unpay_stability_fee, vault.last_update_at);
        vault.unpay_stability_fee = vault.unpay_stability_fee + stability_fee;
        vault.last_update_at = Timestamp::now_seconds();
        if (amount == 0u128) {
            amount = Liquidation::cal_max_withdraw<VaultPoolType>(vault.debt_fai_amount, vault.unpay_stability_fee, balance_for(vault));
        };
        let balance = balance_for(vault);
        Liquidation::check_health_factor<VaultPoolType, TokenType>(0u128, vault.unpay_stability_fee, vault.debt_fai_amount, balance - amount);
        let tokens = Token::withdraw<TokenType>(&mut vault.token, amount);
        Account::deposit_to_self<TokenType>(account, tokens);
        amount
    }


    public fun borrow_fai<VaultPoolType: store + drop + copy, TokenType: store>
    (account: &signer, amount: u128): u128
    acquires Vault, SharedMintCapability {
        Config::check_global_switch();
        assert!(
            vault_exist<VaultPoolType, TokenType>(Signer::address_of(account)),
            Errors::invalid_argument(VAULT_NOT_EXISTS)
        );
        let vault = borrow_global_mut<Vault<VaultPoolType, TokenType>>(Signer::address_of(account));
        let stability_fee = Rate::stability_fee<VaultPoolType>(vault.debt_fai_amount, vault.unpay_stability_fee, vault.last_update_at);
        vault.last_update_at = Timestamp::now_seconds();
        vault.unpay_stability_fee = vault.unpay_stability_fee + stability_fee;
        if (amount == 0u128) {
            let max_amount = Liquidation::cal_max_borrow<VaultPoolType, TokenType>(vault.unpay_stability_fee, balance_for(vault));
            amount = max_amount - vault.debt_fai_amount;
        };
        Liquidation::check_health_factor<VaultPoolType, TokenType>(amount, vault.unpay_stability_fee, vault.debt_fai_amount, balance_for(vault));
        let cap = borrow_global<SharedMintCapability>(Admin::admin_address());
        let tokens = FAI::mint_with_cap(amount, &cap.cap);
        let is_accept_token = Account::is_accepts_token<FAI::FAI>(Signer::address_of(account));
        if (!is_accept_token) {
            Account::do_accept_token<FAI::FAI>(account);
        };
        let fai_amount = Token::value<FAI::FAI>(&tokens);
        Account::deposit_to_self<FAI::FAI>(account, tokens);
        let vault = borrow_global_mut<Vault<VaultPoolType, TokenType>>(Signer::address_of(account));
        vault.debt_fai_amount = vault.debt_fai_amount + fai_amount;
        fai_amount
    }

    public fun repay_fai<VaultPoolType: store + drop + copy, TokenType: store>
    (account: &signer, amount: u128): (u128, u128) acquires Vault, SharedBurnCapability {
        Config::check_global_switch();
        assert!(
            vault_exist<VaultPoolType, TokenType>(Signer::address_of(account)),
            Errors::invalid_argument(VAULT_NOT_EXISTS)
        );
        let vault = borrow_global_mut<Vault<VaultPoolType, TokenType>>(Signer::address_of(account));
        let stability_fee = Rate::stability_fee<VaultPoolType>(vault.debt_fai_amount, vault.unpay_stability_fee, vault.last_update_at);

        vault.unpay_stability_fee = vault.unpay_stability_fee + stability_fee;
        vault.last_update_at = Timestamp::now_seconds();
        let fai_balance = Account::balance<FAI::FAI>(Signer::address_of(account));
        if (amount == 0u128) {
            amount = vault.unpay_stability_fee + vault.debt_fai_amount;
            if (amount > fai_balance) {
                amount = fai_balance;
            }
        };

        assert!(fai_balance >= amount, Errors::invalid_argument(INSUFFICIENT_BALANCE));
        assert!(
            (vault.unpay_stability_fee + vault.debt_fai_amount) >= amount,
            Errors::invalid_argument(WRONG_AMOUNT)
        );
        let tokens = Account::withdraw<FAI::FAI>(account, amount);

        let before_debit = vault.debt_fai_amount;
        let before_fee = vault.unpay_stability_fee;
        if (amount > vault.unpay_stability_fee) {
            vault.unpay_stability_fee = 0;
            vault.debt_fai_amount = vault.debt_fai_amount - (amount - before_fee);
        }else {
            vault.unpay_stability_fee = vault.unpay_stability_fee - amount;
        };
        let after_debit = vault.debt_fai_amount;
        let after_fee = vault.unpay_stability_fee;
        let pay_debit = before_debit - after_debit;
        let pay_fee = before_fee - after_fee;
        assert!(pay_fee + pay_debit == amount, 501);

        let (debit, fee) = Token::split<FAI::FAI>(tokens, pay_fee);
        let cap = borrow_global<SharedBurnCapability>(Admin::admin_address());
        FAI::burn_with_cap(debit, &cap.cap);
        Treasury::deposit(fee);
        (pay_debit, pay_fee)
    }

    public fun max_borrow<VaultPoolType: store + drop + copy, TokenType: store>(address: address): u128
    acquires Vault {
        let vault = borrow_global<Vault<VaultPoolType, TokenType>>(address);
        Liquidation::cal_max_borrow<VaultPoolType, TokenType>(vault.unpay_stability_fee, balance_for(vault))
    }
}
}