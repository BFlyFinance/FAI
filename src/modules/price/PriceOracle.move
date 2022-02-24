address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module PriceOracle {

    use 0x1::Token;
    use 0x1::STC;
    use 0x1::Errors;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::FAI ;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::STCOracle;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::FAIOracle;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Price ;

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