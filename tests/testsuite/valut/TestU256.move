//! account: alice
//! sender: alice
script {
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::U256;

    fun test_mult() {
        let a = 340282366920938463463374607431768211455u128;
        let b = 340282366920938463463374607431768211455u128;
        U256::multiply(U256::from_u128(a), U256::from_u128(b));
    }
}
// check: gas_used
// check: 25383370
// check: "Keep(EXECUTED)"

//! new-transaction
script {
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::U256;

    fun test_mult() {
        let a = 18446744073709551615u64;
        let b = 18446744073709551615u64;
        U256::multiply(U256::from_u64(a), U256::from_u64(b));
    }
}
// check: gas_used
// check: 7078676
// check: "Keep(EXECUTED)"

//! new-transaction
script {
    fun test_mult() {
        let a = 18446744073709551615u64;
        let b = 18446744073709551615u64;
        a * b;
    }
}
// check: gas_used
// check: 606