address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Price {

    struct PriceNumber has drop,copy{
        value: u128,
        scaling_factor: u128
    }

    public fun of(value: u128, dec: u128): PriceNumber {
        PriceNumber {
            value: value,
            scaling_factor: dec
        }
    }

    public fun unpack(v: PriceNumber): (u128, u128) {
        (v.value, v.scaling_factor)
    }
}
}
    