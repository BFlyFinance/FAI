address FaiAdmin {
module STCVaultPoolA {
    use StarcoinFramework::STC;
    use StarcoinFramework::Token;
    use StarcoinFramework::Event;
    use StarcoinFramework::Signer;
    use StarcoinFramework::Errors;
    use StarcoinFramework::Account;
    use FaiAdmin::Admin;
    use FaiAdmin::Vault;
    use FaiAdmin::VaultCounter;
    use FaiAdmin::Config;

    friend FaiAdmin::Liquidation;

    const POOL_ALREADY_PUBLISHED: u64 = 202;
    const POOL_NOT_PUBLISHED: u64 = 203;
    const INSUFFICIENT_BALANCE: u64 = 204;

    const POOL_ID: u64 = 10;

    struct VaultPool has key, copy, store, drop {
        id: u64,
        current_fai_supply: u128,
        vault_count: u64,
        stc_amount: u128,
    }

    struct ClipEvent has drop, store {
        pool_type: Token::TokenCode,
        liquidator: address,
        clip_address: address,
        collateral_amount: u128,
        debit: u128,
        stability_fee: u128
    }

    struct DepositEvent has drop, store {
        pool_type: Token::TokenCode,
        depositor: address,
        amount: u128,
    }

    struct WithdrawEvent has drop, store {
        pool_type: Token::TokenCode,
        withdrawer: address,
        amount: u128
    }

    struct BorrowEvent has drop, store {
        pool_type: Token::TokenCode,
        borrower: address,
        amount: u128
    }

    struct RepayEvent has drop, store {
        pool_type: Token::TokenCode,
        repayer: address,
        amount: u128,
        debit: u128,
        stability_fee: u128
    }

    struct CreateVaultEvent has drop, store {
        pool_type: Token::TokenCode,
        vault_id: u64,
        creator: address,
    }

    struct STCPoolEvent has key, store {
        create_vault_event: Event::EventHandle<CreateVaultEvent>,
        deposit_event: Event::EventHandle<DepositEvent>,
        borrow_event: Event::EventHandle<BorrowEvent>,
        repay_event: Event::EventHandle<RepayEvent>,
        withdraw_event: Event::EventHandle<WithdrawEvent>,
        clip_event: Event::EventHandle<ClipEvent>
    }

    fun empty_pool(): VaultPool {
        VaultPool {
            id: POOL_ID,
            current_fai_supply: 0u128,
            vault_count: 0u64,
            stc_amount: 0u128,
        }
    }


    public fun is_exists(): bool {
        exists<VaultPool>(Admin::admin_address())
    }

    public fun initialize(
        account: &signer,
        max_fai_supply: u128,
        min_mint_amount: u128,
        stability_fee_ratio: u128,
        ccr: u128,
        max_deposit_per_vault: u128,
        liquidation_penalty: u128,
        liquidation_threshold: u128
    ) {
        let account_address = Signer::address_of(account);
        Admin::is_admin_address(account_address);
        if (!VaultCounter::is_counter_exist()) {
            VaultCounter::initialize_counter(account);
        };
        assert!(!is_exists(), Errors::already_published(POOL_ALREADY_PUBLISHED));
        let pool = empty_pool();
        move_to(account, pool);
        let config = Config::new_config(
            max_fai_supply,
            min_mint_amount,
            stability_fee_ratio,
            ccr,
            max_deposit_per_vault,
            liquidation_penalty,
            liquidation_threshold
        );
        Config::publish_new_config_with_capability<VaultPool>(account, config);
    }

    public fun initialize_event(account: &signer) {
        Admin::is_admin_address(Signer::address_of(account));
        move_to(account, STCPoolEvent {
            create_vault_event: Event::new_event_handle<CreateVaultEvent>(account),
            deposit_event: Event::new_event_handle<DepositEvent>(account),
            borrow_event: Event::new_event_handle<BorrowEvent>(account),
            repay_event: Event::new_event_handle<RepayEvent>(account),
            withdraw_event: Event::new_event_handle<WithdrawEvent>(account),
            clip_event: Event::new_event_handle<ClipEvent>(account)
        });
    }

    public(friend) fun crack
    (account: &signer, vault_address: address, liquidate_collateral_amount:u128, cover_amount: u128)
    acquires VaultPool, STCPoolEvent {
        let (debit, pay_fee) = Vault::rearrange<VaultPool, STC::STC>
                               (account, copy vault_address, liquidate_collateral_amount, cover_amount);
        let pool = borrow_global_mut<VaultPool>(Admin::admin_address());
        pool.current_fai_supply = pool.current_fai_supply - debit;
        pool.stc_amount = pool.stc_amount - liquidate_collateral_amount;

        // Publish liquidate event to net
        let admin_address = Admin::admin_address();
        let event = borrow_global_mut<STCPoolEvent>(admin_address);
        Event::emit_event(&mut event.clip_event,
            ClipEvent {
                pool_type: Token::token_code<STC::STC>(),
                liquidator: Signer::address_of(account),
                clip_address: vault_address,
                collateral_amount: liquidate_collateral_amount,
                debit: debit,
                stability_fee: pay_fee
            });
    }

    public fun create_vault(account: &signer): u64  acquires VaultPool, STCPoolEvent {
        Config::check_global_switch();
        assert!(is_exists(), Errors::not_published(POOL_NOT_PUBLISHED));
        let guid = VaultCounter::fresh_guid();
        Vault::create_vault<VaultPool, STC::STC>(account, guid);
        let valut_pool = borrow_global_mut<VaultPool>(Admin::admin_address());
        valut_pool.vault_count = valut_pool.vault_count + 1;
        // Publish create vault event to net
        let admin_address = Admin::admin_address();
        let event = borrow_global_mut<STCPoolEvent>(admin_address);
        Event::emit_event(&mut event.create_vault_event,
            CreateVaultEvent {
                pool_type: Token::token_code<STC::STC>(),
                vault_id: guid,
                creator: Signer::address_of(account)
            });
        guid
    }

    public fun vault_count(): u64 acquires VaultPool {
        let pool = borrow_global<VaultPool>(Admin::admin_address());
        pool.vault_count
    }

    public fun current_fai_supply(): u128 acquires VaultPool {
        let pool = borrow_global<VaultPool>(Admin::admin_address());
        pool.current_fai_supply
    }

    public fun current_stc_locked(): u128 acquires VaultPool {
        let pool = borrow_global<VaultPool>(Admin::admin_address());
        pool.stc_amount
    }

    public fun deposit(account: &signer, amount: u128): u128 acquires VaultPool, STCPoolEvent {
        Config::check_global_switch();
        let account_address = Signer::address_of(account);
        let stc_balance = Account::balance<STC::STC>(copy account_address);
        assert!(stc_balance >= amount, Errors::invalid_argument(INSUFFICIENT_BALANCE));
        let balance = Vault::deposit<VaultPool, STC::STC>(account, amount);
        let pool = borrow_global_mut<VaultPool>(Admin::admin_address());
        pool.stc_amount = pool.stc_amount + balance;
        // Publish deposit event to net
        let admin_address = Admin::admin_address();
        let event = borrow_global_mut<STCPoolEvent>(admin_address);
        Event::emit_event(&mut event.deposit_event,
            DepositEvent {
                pool_type: Token::token_code<STC::STC>(),
                depositor: Signer::address_of(account),
                amount: amount
            });
        balance
    }

    public fun withdraw(account: &signer, amount: u128): u128 acquires VaultPool, STCPoolEvent{
        Config::check_global_switch();
        let withdraw_amount = Vault::withdraw<VaultPool, STC::STC>(account, amount);
        let pool = borrow_global_mut<VaultPool>(Admin::admin_address());
        pool.stc_amount = pool.stc_amount - withdraw_amount;
        // Publish withdraw event to net
        let admin_address = Admin::admin_address();
        let event = borrow_global_mut<STCPoolEvent>(admin_address);
        Event::emit_event(&mut event.withdraw_event,
            WithdrawEvent {
                pool_type: Token::token_code<STC::STC>(),
                withdrawer: Signer::address_of(account),
                amount: withdraw_amount
            });
        withdraw_amount

    }

    public fun max_borrow(address: address): u128 {
        Vault::max_borrow<VaultPool, STC::STC>(address)
    }

    public fun borrow_fai(account: &signer, amount: u128)
    acquires VaultPool, STCPoolEvent
    {
        Config::check_global_switch();
        assert!(is_exists(), Errors::not_published(POOL_NOT_PUBLISHED));
        let config: Config::VaultPoolConfig<VaultPool> = Config::get<VaultPool>();
        Config::check_max_fai_supply(&config, current_fai_supply(), amount);
        Config::check_min_mint_amount(&config, amount);
        amount = Vault::borrow_fai<VaultPool, STC::STC>(account, amount);
        let vault_pool = borrow_global_mut<VaultPool>(Admin::admin_address());
        vault_pool.current_fai_supply = vault_pool.current_fai_supply + amount;
        // Publish borrow event to net
        let admin_address = Admin::admin_address();
        let event = borrow_global_mut<STCPoolEvent>(admin_address);
        Event::emit_event(&mut event.borrow_event,
            BorrowEvent {
                pool_type: Token::token_code<STC::STC>(),
                borrower: Signer::address_of(account),
                amount: amount
            });
    }

    public fun repay_fai(account: &signer, amount: u128): (u128, u128) acquires VaultPool, STCPoolEvent {
        Config::check_global_switch();
        assert!(is_exists(), Errors::not_published(POOL_NOT_PUBLISHED));
        let (debit, fee) = Vault::repay_fai<VaultPool, STC::STC>(account, amount);
        let vault_pool = borrow_global_mut<VaultPool>(Admin::admin_address());
        vault_pool.current_fai_supply = vault_pool.current_fai_supply - debit;
        // Publish repay event to net
        let admin_address = Admin::admin_address();
        let event = borrow_global_mut<STCPoolEvent>(admin_address);
        Event::emit_event(&mut event.repay_event,
            RepayEvent {
                pool_type: Token::token_code<STC::STC>(),
                repayer: Signer::address_of(account),
                amount: debit + fee,
                debit: debit,
                stability_fee: fee
            });
        (debit, fee)
    }

    public fun info(address: address): (u64, u128, u128, u128, u64) {
        Vault::info<VaultPool, STC::STC>(address)
    }
}
}