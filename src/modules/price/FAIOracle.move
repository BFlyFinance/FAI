
address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module FAIOracle {

    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Price ;

    public fun usdt_price(): Price::PriceNumber {
        Price::of(100,100)
    }
}
}