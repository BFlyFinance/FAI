address FaiAdmin {
module Liquidation {
    use StarcoinFramework::STC;
    use StarcoinFramework::Token;
    use StarcoinFramework::Signer;
    use StarcoinFramework::Errors;
    use StarcoinFramework::Account;
    use FaiAdmin::FAI;
    use FaiAdmin::Math;
    use FaiAdmin::Price;
    use FaiAdmin::Vault;
    use FaiAdmin::Config;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::Exponential;
    use FaiAdmin::PriceOracle::{usdt_price};

    const VAULT_IS_HEALTHY: u64 = 16;
    const AMOUNT_IS_INVALID: u64 = 17;
    const INSUFFICIENT_BALANCE: u64 = 18;
    const EDEPRECATED_FUNCTION: u64 = 19;

    const PERCENT_PRECISION: u8 = 4;
    const E18: u128 = 1000000000000000000;

    public fun clip<VaultPoolType: copy + store + drop, TokenType: copy + store + drop>(sender: &signer, vault_address: address, cover_amount: u128) {
       // if cover_amount is 0u128, liquidate 50%
        // if cover_amount > 0, check sender has enough FAI to cover debt
        // select operator according to VaultPoolType
        // calc how much to
        Config::check_global_switch();
        let health_factor_of_vault = health_factor_by_address<VaultPoolType, TokenType>(copy vault_address);
        assert!(health_factor_of_vault <= Math::pow_10(18), VAULT_IS_HEALTHY);
        StarcoinFramework::Debug::print(&111111);
        let (
            _,
            debt_fai_amount,
            stability_fee,
            _,
            _
        ) = Vault::info<VaultPoolType, TokenType>(vault_address);
        let total_debt = debt_fai_amount + stability_fee;
        let debt_cover_amount = if (cover_amount == 0u128) {
            (debt_fai_amount + stability_fee) / 2
        } else {
            let half_debt = total_debt / 2u128;
            assert!(half_debt >= cover_amount, AMOUNT_IS_INVALID);
            cover_amount
        };
        let fai_balance = Account::balance<FAI::FAI>(Signer::address_of(sender));
        assert!(fai_balance >= debt_cover_amount, INSUFFICIENT_BALANCE);
        let config = Config::get<VaultPoolType>();
        let (_, _, _, _, _, liq_penalty, _) = Config::unpack<VaultPoolType>(config);
        let price_number = usdt_price<STC::STC>();
        let (price, price_scaling) = Price::unpack(price_number);
        let price_discount = price * (100 - liq_penalty);
        let liquidate_collateral_amount_exp = Exponential::exp(debt_cover_amount, price_discount);
        let exp_scaling = Math::pow_10(18);
        let scaling = exp_scaling / (price_scaling * 100);
        let liquidate_collateral_amount = Exponential::mantissa(liquidate_collateral_amount_exp) / scaling;
        if (Token::is_same_token<TokenType, STC::STC>()) {
            STCVaultPoolA::crack(
                sender,
                vault_address,
                liquidate_collateral_amount,
                debt_cover_amount
            );
        }
    }

    public fun health_factor_by_address<VaultPoolType: copy + store + drop, TokenType: store>
    (account: address): u128{
        let (
            _,
            debt_fai_amount,
            stability_fee,
            collateral_amount,
            _
        ) = Vault::info<VaultPoolType, TokenType>(account);
        let price_number = usdt_price<STC::STC>();
        let (price, price_scaling) = Price::unpack(price_number);
        let price = Exponential::exp(price, price_scaling);
        // may have probs if price_scaling is e18
        let collateral_value = Exponential::mul_scalar_exp(price, collateral_amount);
        let config = Config::get<VaultPoolType>();
        let (_, _, _, _, _, _, liq_threshold) = Config::unpack<VaultPoolType>(config);
        let liq_threshold_exp = Exponential::exp(liq_threshold, 100000u128);
        let total_debt = debt_fai_amount + stability_fee;
        let debt_fai_liq_threshold_exp = Exponential::mul_scalar_exp(liq_threshold_exp, total_debt);
        let health_factor = Exponential::exp(Exponential::truncate(collateral_value), Exponential::truncate(debt_fai_liq_threshold_exp));
        Exponential::mantissa(health_factor)
    }

    public fun check_health_factor<VaultPoolType: copy + store + drop, TokenType: store>
    (_amount: u128, _unpay_stability_fee: u128, _debt_mai_amount: u128, _collateral: u128) {
        abort Errors::deprecated(EDEPRECATED_FUNCTION)
    }

    public fun cal_max_borrow<VaultPoolType: copy + store + drop, TokenType: store>
    (_unpay_stability_fee: u128, _collateral: u128): u128 {
        abort Errors::deprecated(EDEPRECATED_FUNCTION)
    }

    public fun cal_max_withdraw<VaultPoolType: copy + store + drop>
    (_debt_fai: u128, _unpay_stability_fee: u128, _collateral: u128): u128 {
        abort Errors::deprecated(EDEPRECATED_FUNCTION)
    }
}
}