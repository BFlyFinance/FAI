address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module TestAdmin {

    #[test_only]
    use 0x1::Signer;
    #[test_only]
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Admin;

    #[test(account = @0x4FFCC98F43ce74668264a0CF6Eebe42b) ]
    fun test_counter_error(account: signer) {
        let account_address = Signer::address_of(&account);
        Admin::is_admin_address(account_address)
    }


    #[test(account = @0x1) ]
    #[expected_failure(abort_code = 51459)]
    fun test_admin_error(account: signer) {
        let account_address = Signer::address_of(&account);
        Admin::is_admin_address(account_address)
    }
}
}
