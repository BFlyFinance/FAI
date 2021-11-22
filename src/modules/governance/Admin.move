address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Admin {
    use 0x1::Errors;

    use 0x1::Token;
    use 0x1::ChainId;
    use 0x1::Debug;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;
    const NOT_ADMIN_ADDRESS: u64 = 201;

    const ADMIN_ADDRESS: address = @0xb987F1aB0D7879b2aB421b98f96eFb44 ;
    public fun admin_address(): address {
        Token::token_address<FAI::FAI>()
    }

    public fun is_admin_address(address: address) {
        assert(ADMIN_ADDRESS == address, Errors::requires_role(NOT_ADMIN_ADDRESS));
    }

    public fun is_dev(): bool {
        let id = ChainId::get();
        Debug::print(&id);
        id == 254 || id == 255
    }


}
}