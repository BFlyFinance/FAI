
address FaiAdmin {
module FAIOracle {

    use FaiAdmin::Price ;

    public fun usdt_price(): Price::PriceNumber {
        Price::of(100,100)
    }
}
}