address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module PriceOracle {

    use 0x1::Token;
    use 0x1::STC;
    use 0x1::Errors;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI ;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCOracle;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAIOracle;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Price ;

    const NOT_SUPPROT_TOKEN_TYPE: u64 = 1;


    public fun usdt_price<TokenType: store>(): Price::PriceNumber {
        if (Token::is_same_token<TokenType, STC::STC>()) {
            return STCOracle::usdt_price()
        };
        if (Token::is_same_token<TokenType, FAI::FAI>()) {
            return FAIOracle::usdt_price()
        };
        abort Errors::invalid_argument(NOT_SUPPROT_TOKEN_TYPE)
    }
}
}