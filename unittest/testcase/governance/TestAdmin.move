address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module TestAdmin {

    use 0x1::Signer;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin;

    #[test(account = @0xb987F1aB0D7879b2aB421b98f96eFb44) ]
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
