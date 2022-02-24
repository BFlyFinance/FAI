
address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module FAIOracle {

    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Price ;

    public fun usdt_price(): Price::PriceNumber {
        Price::of(100,100)
    }
}
}