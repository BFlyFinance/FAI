address FaiAdmin {
module MarketScript {

    use FaiAdmin::Config;
    use FaiAdmin::STCVaultPoolA;

    public(script) fun create_vault(sender: signer) {
        STCVaultPoolA::create_vault(&sender);
    }

    public(script) fun deposit(sender: signer, amount: u128) {
        let _ = STCVaultPoolA::deposit(&sender, amount);
    }

    public(script) fun withdraw(sender: signer, amount: u128) {
        STCVaultPoolA::withdraw(&sender, amount);
    }

    public(script) fun borrow_fai(sender: signer, amount: u128) {
        STCVaultPoolA::borrow_fai(&sender, amount);
    }

    public(script) fun repay_fai(sender: signer, amount: u128) {
        let (_, _) = STCVaultPoolA::repay_fai(&sender, amount);
    }

    public(script) fun init_event(sender: signer) {
        let (_, _) = STCVaultPoolA::initialize_event(&sender);
    }

    public(script) fun update_config
    (sender: signer,
     max_fai_supply: u128,
     min_mint_amount: u128,
     stability_fee_ratio: u128,
     ccr: u128,
     max_deposit_per_vault: u128,
     liquidation_panalty: u128,
     liquidation_threshold: u128) {
        let config = Config::new_config<STCVaultPoolA::VaultPool>(max_fai_supply, min_mint_amount, stability_fee_ratio,
            ccr, max_deposit_per_vault, liquidation_panalty, liquidation_threshold);
        Config::update_config_sign<STCVaultPoolA::VaultPool>(&sender, config);
    }

	public(script) fun set_global_switch(sender: signer, switch: bool) {
		Config::set_global_switch(&sender, switch);
	}
}
}
