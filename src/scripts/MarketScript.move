address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module MarketScript {

    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;

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
}
}
