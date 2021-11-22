address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module STCOracle {

    use 0x1::STC::STC;
    use 0x1::STCUSDOracle::{STCUSD};
    use 0x1::PriceOracle;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Price ;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin ;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Exponential::{Self, Exp};
    //0.2
    public fun usdt_price(): Price::PriceNumber {
        let oracle_address = oracle_address<STC>();
        let (exp, scaling_factor) = usd_price<STCUSD>(oracle_address);
        Price::of(Exponential::mantissa(exp), scaling_factor)
    }

    fun usd_price<OracleType: store + drop + copy>
    (oracle_address: address): (Exp, u128) {
        let price = PriceOracle::read<OracleType>(oracle_address);
        let scaling_factor = PriceOracle::get_scaling_factor<OracleType>();
        let exp = Exponential::exp_direct(price);
        (exp, scaling_factor)
    }

    fun oracle_address<TokenType: store>(): address {
        if (!Admin::is_dev()) {
            return @0x07fa08a855753f0ff7292fdcbe871216
        };
        return Admin::admin_address()
    }
}
}
    