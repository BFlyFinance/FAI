address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module STCOracle {

    use 0x1::STC::STC;
    use 0x1::STCUSDOracle::{STCUSD};
    use 0x1::PriceOracle;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Price ;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Admin ;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Exponential::{Self, Exp};
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
			if (Admin::is_barnard()){
				return @0x07fa08a855753f0ff7292fdcbe871216
			};
            return @0x82e35b34096f32c42061717c06e44a59
        };
        return Admin::admin_address()
    }
}
}
    