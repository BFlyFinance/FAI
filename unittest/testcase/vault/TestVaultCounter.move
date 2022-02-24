address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module TestVaultCounter {

//    use 0x1::Debug;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::VaultCounter;
    #[test(account = @0x4FFCC98F43ce74668264a0CF6Eebe42b)]
    fun test_counter(account: signer) {
        let account_exists = VaultCounter::is_counter_exist();
        assert(!account_exists, 101);
        VaultCounter::initialize_counter(&account);
        account_exists = VaultCounter::is_counter_exist();
        assert(account_exists, 102);
        let start_guid = VaultCounter::get_guid_start_at();

        let i = 0;
        while ( i < 100) {
            let id = VaultCounter::fresh_guid();
            assert(id == (start_guid + i + 1), 103);
            i = i + 1;
        };
    }

    #[test(account = @0x4FFCC98F43ce74668264a0CF6Eebe42b) ]
    #[expected_failure(abort_code = 51462)]
    fun test_counter_error(account: signer) {
        let account_exists = VaultCounter::is_counter_exist();
        assert(!account_exists, 101);
        VaultCounter::initialize_counter(&account);
        account_exists = VaultCounter::is_counter_exist();
        assert(account_exists, 101);
        VaultCounter::initialize_counter(&account);
    }


    #[test(account = @0x1) ]
    #[expected_failure(abort_code = 51459)]
    fun test_admin_error(account: signer) {
        let account_exists = VaultCounter::is_counter_exist();
        assert(!account_exists, 101);
        VaultCounter::initialize_counter(&account);
        account_exists = VaultCounter::is_counter_exist();
        assert(account_exists, 101);
        VaultCounter::initialize_counter(&account);
    }
}
}
