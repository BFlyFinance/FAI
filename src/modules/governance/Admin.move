address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
module Admin {

    use 0x1::Errors;
    use 0x1::ChainId;

    const NOT_ADMIN_ADDRESS: u64 = 201;
    const ADMIN_ADDRESS: address = @0x4FFCC98F43ce74668264a0CF6Eebe42b ;

    public fun admin_address(): address {
        ADMIN_ADDRESS
    }

    public fun is_admin_address(address: address) {
        assert(ADMIN_ADDRESS == address, Errors::requires_role(NOT_ADMIN_ADDRESS));
    }

    public fun is_dev(): bool {
        let id = ChainId::get();
        id == 252 || id == 254 || id == 255
    }

	public fun is_barnard(): bool {
		let id = ChainId::get();
		id == 251
	}

}
}