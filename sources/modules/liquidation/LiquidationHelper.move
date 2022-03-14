address FaiAdmin {
module LiquidationHelper {

    use StarcoinFramework::STC;
    use StarcoinFramework::Token;
    use StarcoinFramework::Errors;
    use StarcoinFramework::Math as SMath;
    use FaiAdmin::FAI;
    use FaiAdmin::Math;
    use FaiAdmin::Price;
    use FaiAdmin::Config;
    use FaiAdmin::Exponential::{Self, Exp};
    use FaiAdmin::PriceOracle::{usdt_price};

    const HF_IS_TOO_LOW: u64 = 666;

    const PERCENT_PRECISION: u8 = 4;

    public fun cal_max_borrow<VaultPoolType: copy + store + drop, TokenType: store>
    (unpay_stability_fee: u128, collateral: u128): u128 {
        let config = Config::get<VaultPoolType>();
        let (_, _, _, ccr, _, _, _) = Config::unpack<VaultPoolType>(config);
        let max_borrow = max_borrow<TokenType>(collateral, Math::pow_10(PERCENT_PRECISION));
        let base_line = SMath::mul_div(max_borrow, Math::pow_10(PERCENT_PRECISION), ccr) ;
        base_line - unpay_stability_fee
    }

    public fun cal_max_withdraw<VaultPoolType: copy + store + drop>
    (debt_fai: u128, unpay_stability_fee: u128, collateral: u128): u128 {
        let config = Config::get<VaultPoolType>();
        let (_, _, _, ccr, _, _, _) = Config::unpack<VaultPoolType>(config);
        let total_fai = debt_fai + unpay_stability_fee;
        let collateral_needed = min_collateral(total_fai, ccr);
        collateral - collateral_needed
    }

    public fun check_health_factor<VaultPoolType: copy + store + drop, TokenType: store>
    (amount: u128, unpay_stability_fee: u128, debt_mai_amount: u128, collateral: u128) {
        let base_line = cal_max_borrow<VaultPoolType, TokenType>(unpay_stability_fee, collateral);
        assert!(amount + debt_mai_amount <= base_line + 2, Errors::invalid_argument(HF_IS_TOO_LOW));
    }

    fun min_collateral(amount: u128, ccr: u128): u128 {
        let token_usd = token_value_of_usd<FAI::FAI>(amount);
        let equal_value_stc_amount = to_token_amount<STC::STC>(token_usd);
        SMath::mul_div(equal_value_stc_amount, ccr, Math::pow_10(PERCENT_PRECISION))
    }

    fun max_borrow<TokenType: store>(collateral: u128, lt: u128): u128 {
        let token_usd = token_value_of_usd<STC::STC>(collateral);
        let equal_value_mai_amount = to_token_amount<FAI::FAI>(token_usd);
        SMath::mul_div(equal_value_mai_amount, lt, Math::pow_10(PERCENT_PRECISION))
    }

    fun to_token_amount<TokenType: store>(amount: Exp): u128 {
        let token_scaling = Token::scaling_factor<TokenType>();
        let exp_scale: u128 = Exponential::exp_scale();
        let price_number = usdt_price<TokenType>();
        let (price, price_scaling) = Price::unpack(price_number);
        let price = Exponential::exp_direct(price);
        // may have probs if price_scaling is e18
        let amount_price_scaling = Exponential::mul_scalar_exp(amount, price_scaling);
        let token_amount_exp = Exponential::div_scalar_exp(amount_price_scaling, Exponential::mantissa(price));
        let token_amount = Exponential::mantissa(token_amount_exp) / (exp_scale / token_scaling);
        token_amount
    }

    fun token_value_of_usd<TokenType: store>(amount: u128): Exp {
        // return exp(amount*price, token_scaling*price_scaling)
        let exp_scale: u128 = Exponential::exp_scale();
        let token_scaling = Token::scaling_factor<TokenType>();
        let price_number = usdt_price<TokenType>();
        let (price, price_scaling) = Price::unpack(price_number);
        let price = Exponential::exp_direct(price);
        let amount_exp = Exponential::exp_direct(amount);
        let token_usdt_value_exp = Exponential::mul_scalar_exp(amount_exp, Exponential::mantissa(price));
        if (price_scaling == 0) {
            price_scaling = 1;
        };
        let token_usdt_value_exp_scaling = token_scaling * price_scaling;
        if (token_usdt_value_exp_scaling >= exp_scale) {
            Exponential::div_scalar_exp(token_usdt_value_exp, token_usdt_value_exp_scaling / exp_scale)
        } else {
            let scaling = exp_scale / token_usdt_value_exp_scaling;
            Exponential::mul_scalar_exp(token_usdt_value_exp, scaling)
        }
    }

}
}