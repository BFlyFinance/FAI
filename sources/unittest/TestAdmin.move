address FaiAdmin {
module TestAdmin {

    #[test_only]
    use StarcoinFramework::Signer;
    #[test_only]
    use FaiAdmin::Admin;

    #[test(account = @FaiAdmin) ]
    fun test_counter_error(account: signer) {
        let account_address = Signer::address_of(&account);
        Admin::is_admin_address(account_address)
    }


    #[test(account = @StarcoinFramework) ]
    #[expected_failure(abort_code = 51459)]
    fun test_admin_error(account: signer) {
        let account_address = Signer::address_of(&account);
        Admin::is_admin_address(account_address)
    }
}
}
