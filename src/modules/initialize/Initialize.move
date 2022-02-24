address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module Initialize {

    use 0x1::Token;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Vault;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::FAI;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::STCVaultPoolA;

    public fun initialize(sender: &signer) {
        Vault::initialize(sender);
        let max_mint_amount = 200000000000 * Token::scaling_factor<FAI::FAI>();
        let min_mint_amount = 1 * Token::scaling_factor<FAI::FAI>();
        let stability_fee_ratio = 300u128;
        let ccr = 30000u128;
        let max_deposit_per_vault = 10000000000000u128;
        let liquidation_penalty = 10u128;
        let liquidation_threshold = 8000u128;
        STCVaultPoolA::initialize(sender,
            max_mint_amount,
            min_mint_amount,
            stability_fee_ratio,
            ccr,
            max_deposit_per_vault,
            liquidation_penalty,
            liquidation_threshold);
    }
}
}

