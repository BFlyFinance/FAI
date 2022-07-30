address FaiAdmin {
module Config {
    use StarcoinFramework::Config;
    use StarcoinFramework::Signer;
    use StarcoinFramework::Errors;
    //    use StarcoinFramework::Debug;
    use FaiAdmin::Admin;

    const DEFAULT_GLOBAL_SWITCH: bool = false;
    const EDEPRECATED_FUNCTION: u64 = 1001;

    struct CapHolder<phantom VaultPoolType: copy + store + drop> has key, store {
        cap: Config::ModifyConfigCapability<VaultPoolConfig<VaultPoolType>>,
    }

    struct VaultPoolConfig<phantom VaultPoolType: copy + store + drop>  has copy, drop, store {
        max_fai_supply: u128,
        min_mint_amount: u128,
        stability_fee_ratio: u128,
        ccr: u128,
        max_deposit_per_vault: u128,
        liquidation_penalty: u128,
        liquidation_threshold: u128,
    }

    struct GlobalSwitch has copy, drop, store {
        switch: bool
    }

    public fun new_config<VaultPoolType: copy + store + drop>
    (max_fai_supply: u128,
     min_mint_amount: u128,
     stability_fee_ratio: u128,
     ccr: u128,
     max_deposit_per_vault: u128,
     liquidation_penalty: u128,
     liquidation_threshold: u128): VaultPoolConfig<VaultPoolType> {
        VaultPoolConfig<VaultPoolType> {
            max_fai_supply: max_fai_supply,
            min_mint_amount: min_mint_amount,
            stability_fee_ratio: stability_fee_ratio,
            ccr: ccr,
            max_deposit_per_vault: max_deposit_per_vault,
            liquidation_penalty: liquidation_penalty,
            liquidation_threshold: liquidation_threshold,
        }
    }


    public fun unpack<VaultPoolType: copy + store + drop>(config: VaultPoolConfig<VaultPoolType>): (u128, u128, u128, u128, u128, u128, u128) {
        (   config.max_fai_supply,
            config.min_mint_amount,
            config.stability_fee_ratio,
            config.ccr,
            config.max_deposit_per_vault,
            config.liquidation_penalty,
            config.liquidation_threshold,
        )
    }

    public fun publish_new_config_with_capability<VaultPoolType: copy + store + drop>
    (account: &signer, cofing: VaultPoolConfig<VaultPoolType>) {
        let account_address = Signer::address_of(account);
        Admin::is_admin_address(account_address);
        let cap = Config::publish_new_config_with_capability<VaultPoolConfig<VaultPoolType>>(account, cofing);
        move_to(account, CapHolder { cap: cap });
    }

    public fun update_config<VaultPoolType: copy + store + drop>(_cofing: VaultPoolConfig<VaultPoolType>) {
        abort Errors::deprecated(EDEPRECATED_FUNCTION)
    }

    public fun update_config_sign<VaultPoolType: copy + store + drop>(account: &signer, config: VaultPoolConfig<VaultPoolType>)
    acquires CapHolder {
        Admin::is_admin_address(Signer::address_of(account));
        let holder = borrow_global_mut<CapHolder<VaultPoolType>>(Admin::admin_address());
        Config::set_with_capability(&mut holder.cap, config);
    }

    public fun get<VaultPoolType: copy + store + drop>(): VaultPoolConfig<VaultPoolType> {
        Config::get_by_address<VaultPoolConfig<VaultPoolType>>(Admin::admin_address())
    }

    public fun set_global_switch(signer: &signer, switch: bool) {
        Admin::is_admin_address(Signer::address_of(signer));
        let config = GlobalSwitch {
            switch
        };
        if (Config::config_exist_by_address<GlobalSwitch>(Signer::address_of(signer))) {
            Config::set<GlobalSwitch>(signer, config);
        } else {
            Config::publish_new_config<GlobalSwitch>(signer, config);
        }
    }

    public fun get_global_switch(): bool {
        if (Config::config_exist_by_address<GlobalSwitch>(Admin::admin_address())) {
            let switch_config = Config::get_by_address<GlobalSwitch>(Admin::admin_address());
            switch_config.switch
        } else {
            DEFAULT_GLOBAL_SWITCH
        }
    }

    const MIN_MINT_AMOUNT: u64 = 205;
    const MAX_MINT_AMOUNT: u64 = 206;
    const GLOBAL_SWITCH_OFF: u64 = 207;

    public fun check_max_fai_supply<VaultPoolType: copy + store + drop>
    (config: &VaultPoolConfig<VaultPoolType>, current_supply: u128, borrow_amount: u128) {
        assert!(config.max_fai_supply >=current_supply + borrow_amount, Errors::invalid_argument(MAX_MINT_AMOUNT));
    }

    public fun check_min_mint_amount<VaultPoolType: copy + store + drop>
    (config: &VaultPoolConfig<VaultPoolType>, borrow_amount: u128) {
        assert!(config.min_mint_amount <= borrow_amount || borrow_amount == 0u128, Errors::invalid_argument(MIN_MINT_AMOUNT));
    }

    public fun check_global_switch() {
        assert!(!get_global_switch(), Errors::invalid_state(GLOBAL_SWITCH_OFF));
    }
}
}