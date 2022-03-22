address FaiAdmin {
module PriceOracle {

    use StarcoinFramework::Token;
    use StarcoinFramework::STC;
    use StarcoinFramework::Errors;
    use FaiAdmin::FAI ;
    use FaiAdmin::STCOracle;
    use FaiAdmin::FAIOracle;
    use FaiAdmin::Price ;

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