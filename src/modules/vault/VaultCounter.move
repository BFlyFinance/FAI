address 0x4FFCC98F43ce74668264a0CF6Eebe42b {

module VaultCounter {
    use 0x1::Errors;
    use 0x1::Signer;
    use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Admin;


    const GUID_START_AT: u64 = 10000;
    const COUNTER_ALREADY_PUBLISHED: u64 = 201;

    struct Counter has key {
        guid: u64
    }

    public fun fresh_guid(): u64 acquires Counter {
        let admin_address = Admin::admin_address();
        let counter = borrow_global_mut<Counter>(admin_address);
        counter.guid = counter.guid + 1 ;
        counter.guid
    }

    public fun get_guid_start_at(): u64 {
        GUID_START_AT
    }

    public fun initialize_counter(account: &signer): u64 {
        let account_address = Signer::address_of(account);
        Admin::is_admin_address(account_address);
        assert(!is_counter_exist(), Errors::already_published(COUNTER_ALREADY_PUBLISHED));
        let guid = GUID_START_AT;
        let counter = Counter {
            guid: guid
        };
        move_to(account, counter);
        guid
    }

    public fun is_counter_exist(): bool {
        exists<Counter>(Admin::admin_address())
    }
}
}