address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module TestRate {
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Rate;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::TestHelper;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::STCVaultPoolA::{VaultPool};

    #[test(admin = @0x4FFCC98F43ce74668264a0CF6Eebe42b ) ]
    fun test_rate(admin: signer) {
        let std_signer = TestHelper::init_stdlib();
        TestHelper::init_account_with_stc(&admin, 0u128, &std_signer);
        TestHelper::set_timestamp(1631244104193u64+31536000000u64);
        let fee = Rate::stability_fee<VaultPool>(1000000u128, 0u128, 1631244104u64);
        0x1::Debug::print(&fee);
        0x1::Debug::print(&((1000000 * 350 / 10000) as u128));
        assert(fee == ((1000000 * 350 / 10000) as u128), 100);
    }

}
}
