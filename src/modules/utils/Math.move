address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Math {

    const MAX_DECIMALS: u8 = 18;
    const POW_10_TO_MAX_DECIMALS: u128 = 1000000000000000000;

    const ERR_MORE_THAN_18_DECIMALS: u64 = 401;
    const U128_MAX: u128 = 340282366920938463463374607431768211455u128;

    struct Num has drop, store { value: u128, dec: u8 }

    public fun max_u128(): u128 {
        U128_MAX
    }

    public fun num(value: u128, dec: u8): Num {
        assert(
            dec <= MAX_DECIMALS,
            ERR_MORE_THAN_18_DECIMALS
        );
        Num { value, dec }
    }

    public fun scale_to_decimals(num: Num, scale_dec: u8): u128 {
        let (value, dec) = num_unpack(num);
        if (dec < scale_dec) {
            (value * pow_10(scale_dec - dec))
        } else {
            (value / pow_10(dec - scale_dec))
        }
    }

    public fun add(val1: Num, val2: Num): Num {
        let (num1, dec1) = num_unpack(val1);
        let (num2, dec2) = num_unpack(val2);
        let max_dec = max(dec1, dec2);

        let num1_scaled = num1 * pow_10(max_dec - dec1);
        let num2_scaled = num2 * pow_10(max_dec - dec2);

        num(num1_scaled + num2_scaled, max_dec)
    }

    public fun pow(base: u64, exp: u8): u128 {
        let result_val = 1u128;
        let i = 0;
        while (i < exp) {
            result_val = result_val * (base as u128);
            i = i + 1;
        };
        result_val
    }

    public fun pow_10(exp: u8): u128 {
        pow(10, exp)
    }

    public fun num_unpack(num: Num): (u128, u8) {
        let Num { value, dec } = num;
        (value, dec)
    }

    fun max(a: u8, b: u8): u8 {
        if (a > b) a else b
    }

    fun min(a: u8, b: u8): u8 {
        if (a > b) b else a
    }

    public fun sub(val1: Num, val2: Num): Num {
        let (num1, dec1) = num_unpack(val1);
        let (num2, dec2) = num_unpack(val2);
        let max_dec = max(dec1, dec2);

        let num1_scaled = num1 * pow_10(max_dec - dec1);
        let num2_scaled = num2 * pow_10(max_dec - dec2);

        num(num1_scaled - num2_scaled, max_dec)
    }

    public fun mul_div(val1: Num, val2: Num, val3: Num):Num {

        let num4 = num(val3.value,val3.dec);
        mul(div(val1,val3),div(val2,num4))
    }

    public fun mul(val1: Num, val2: Num): Num {
        let (num1, dec1) = num_unpack(val1);
        let (num2, dec2) = num_unpack(val2);
        let multiplied = num1 * num2;

        let new_decimals = dec1 + dec2;
        let multiplied_scaled = if (new_decimals < MAX_DECIMALS) {
            let decimals_underflow = MAX_DECIMALS - new_decimals;
            multiplied * pow_10(decimals_underflow)
        } else if (new_decimals > MAX_DECIMALS) {
            let decimals_overflow = new_decimals - MAX_DECIMALS;
            multiplied / pow_10(decimals_overflow)
        } else {
            multiplied
        };
        let multiplied_scaled_u128 = multiplied_scaled ;
        num(multiplied_scaled_u128, MAX_DECIMALS)
    }

    public fun div(val1: Num, val2: Num): Num {
        let (num1, dec1) = num_unpack(val1);
        let (num2, dec2) = num_unpack(val2);
        let num1_scaling_factor = pow_10(MAX_DECIMALS - dec1);
        let num1_scaled = num1 * num1_scaling_factor;
        let num1_scaled_with_overflow = num1_scaled * POW_10_TO_MAX_DECIMALS;
        let num2_scaling_factor = pow_10(MAX_DECIMALS - dec2);
        let num2_scaled = num2 * num2_scaling_factor ;
        let division = num1_scaled_with_overflow / num2_scaled ;
        num(division, MAX_DECIMALS)
    }

    public fun equals(val1: Num, val2: Num): bool {
        let num1 = scale_to_decimals(val1, 18);
        let num2 = scale_to_decimals(val2, 18);
        num1 == num2
    }
}
}
