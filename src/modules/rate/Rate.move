address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module Rate {

    use 0x1:: Timestamp;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Config;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Exponential;

    const PERCENT_PRECISION: u128 = 10000;

    public fun stability_fee<VaultPoolType: copy + store + drop>(current_amount: u128, unpay_fee: u128, from_seconds: u64): u128 {
        let now = Timestamp::now_seconds();
        let ts_gap = now - from_seconds;
        let config = Config::get<VaultPoolType>();

        let (_, _, stability_fee_ratio, _, _, _, _) = Config::unpack<VaultPoolType>(config);
        //         amount * fee *ts_gap/sencod
        stability_fee_calc<VaultPoolType>(current_amount+unpay_fee, ts_gap, stability_fee_ratio)
    }

    fun stability_fee_calc<VaultPoolType: copy + store + drop>(amount: u128, time_delta: u64, stability_fee_ratio: u128): u128 {
        let ratio_exp = Exponential::exp(stability_fee_ratio, PERCENT_PRECISION);
        let ratio_expand = Exponential::mul_scalar_exp(copy ratio_exp, 1000);
        let ratio_per_second_expand = rate_per_second(ratio_expand);
        let ratio_timedelta_expand = Exponential::mul_scalar_exp(ratio_per_second_expand, (time_delta as u128));
        let amount_exp = Exponential::exp_direct(amount);
        let amount_ratio_expand = Exponential::mul_exp(amount_exp, ratio_timedelta_expand);
        let fee_exp = Exponential::div_scalar_exp(amount_ratio_expand, 1000);
        Exponential::mantissa(fee_exp)

    }

    fun rate_per_second(rate_year: Exponential::Exp): Exponential::Exp {
        // current rate_year div total seconds a year
        let total_year_seconds: u128 = 31536000;
        Exponential::div_scalar_exp(rate_year, total_year_seconds)
    }
}
}