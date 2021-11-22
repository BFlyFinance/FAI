//! account: admin ,0xb987F1aB0D7879b2aB421b98f96eFb44, 20000000000 0x1::STC::STC
//! account: bob,20000000000000 0x1::STC::STC
//! account: alice,20000000000000 0x1::STC::STC
//! sender: admin
script {
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::MAI;

    fun init_mai(sender: signer) {
        MAI::initialize(&sender);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: admin
script {
    use 0x1::Token;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;

    fun test_init(sender: signer) {
        let pool_exists = STCVaultPoolA::is_exists();
        assert(!pool_exists, 101);
        let max_mint_amount = 2000 * Token::scaling_factor<FAI::FAI>();
        let min_mint_amount = 1 * Token::scaling_factor<FAI::FAI>();
        STCVaultPoolA::initialize(&sender,
            max_mint_amount,
            min_mint_amount,
            350, 8000, 10, 8000);
        pool_exists = STCVaultPoolA::is_exists();
        assert(pool_exists, 101);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::STC;
    use 0x1::Signer;

    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Vault;

    fun create_vaule(sender: signer) {
        assert(
            !Vault::vault_exist<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender))
            , 1
        );
        STCVaultPoolA::create_vault(&sender);
        assert(
            Vault::vault_exist<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender))
            , 1
        );
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::STC;
    use 0x1::Account;
    use 0x1::Token;
    use 0x1::Signer;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;

    fun deposit(sender: signer) {
        let balance = Account::balance<STC::STC>(Signer::address_of(&sender));
        let amount = (10000 * Token::scaling_factor<STC::STC>() as u128) ;
        STCVaultPoolA::deposit(&sender, amount);
        let after_balance = Account::balance<STC::STC>(Signer::address_of(&sender));
        assert(after_balance + amount == balance, 1);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::Account;
    use 0x1::Token;
    use 0x1::Signer;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;


    fun borrow_mai_a(sender: signer) {
        assert(
            STCVaultPoolA::current_mai_supply() == 0, 1
        );
        let amount = (200 * Token::scaling_factor<FAI::FAI>() as u128) ;
        STCVaultPoolA::borrow_mai(&sender, amount);
        let balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        assert(amount == balance, 1);
        assert(
            STCVaultPoolA::current_mai_supply() == amount, 1
        );
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::Account;
    use 0x1::Token;
    use 0x1::Signer;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;

    fun borrow_mai(sender: signer) {
        let balance_before = Account::balance<MAI::MAI>(Signer::address_of(&sender));
        let amount = (1000 * Token::scaling_factor<MAI::MAI>() as u128) ;
        STCVaultPoolA::borrow_mai(&sender, amount);
        let balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        assert(amount + balance_before == balance, 1);
    }
}
// check: "Keep(EXECUTED)"



//! new-transaction
//! sender: bob
script {
    use 0x1::Account;
    use 0x1::Token;
    use 0x1::Signer;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;

    fun borrow_mai(sender: signer) {
        // current mock max is 1280
        let balance_before = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        let amount = (80 * Token::scaling_factor<FAI::FAI>() as u128) + 1 ;
        STCVaultPoolA::borrow_mai(&sender, amount);
        let balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        assert(amount + balance_before == balance, 1);
    }
}
// check: " Keep(ABORTED { code: 170503, "


//! block-prologue
//! block-time: 31536000000
//! author: genesis
//! block-number: 1
//! new-transaction
//! sender: bob
script {
    use 0x1::Signer;
    use 0x1::STC;
    use 0x1::Token;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Vault;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;

    fun borrow_mai(sender: signer) {
        let (_id, mai_debit, fee, toke_balance, _ts) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender));

        assert(42000000000 == fee, 1);
        assert(mai_debit == 1200 * Token::scaling_factor<FAI::FAI>(), 2);
        assert(toke_balance == 10000 * Token::scaling_factor<STC::STC>(), 3);
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: bob
script {
    use 0x1::Token;
    use 0x1::Signer;

    use 0x1::STC;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Vault;

    fun repay_mai(sender: signer) {
        let b_market_cap = Token::market_cap<FAI::FAI>();
        let (_, b_mai_debit, b_fee, _, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender));
        let amount = 10 * Token::scaling_factor<FAI::FAI>();
        STCVaultPoolA::repay_mai(&sender, amount);
        let (_, a_mai_debit, a_fee, _, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender));
        let a_market_cap = Token::market_cap<FAI::FAI>();
        let after = (b_mai_debit - a_mai_debit) + (b_fee - a_fee);
        assert(amount == after, 1);
        assert(MAI::treasury_balance() == (b_fee - a_fee), 2);
        assert((b_mai_debit - a_mai_debit) == (b_market_cap - a_market_cap), 3);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;

    const U128_MAX: u128 = 340282366920938463463374607431768211455u128;

    fun repay_mai_all(sender: signer) {
        STCVaultPoolA::repay_mai(&sender, U128_MAX);
    }
}
// check: " Keep(ABORTED { code: 52231, "

//! new-transaction
//! sender: alice
address bob = {{bob}};
script {
    use 0x1::STC;
    use 0x1::Signer;
    use 0x1::Token;
    use 0x1:: Account;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;

    fun transfer_to_bob(sender: signer) {
        STCVaultPoolA::create_vault(&sender);
        let amount = (10000 * Token::scaling_factor<STC::STC>() as u128) ;
        STCVaultPoolA::deposit(&sender, amount);
        let amount = (200 * Token::scaling_factor<FAI::FAI>() as u128) ;
        STCVaultPoolA::borrow_mai(&sender, amount);
        let alice_balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        assert(alice_balance == amount, 1);
        let bob_balance = Account::balance<FAI::FAI>(@bob);
        Account::pay_from<FAI::FAI>( & sender,@bob, amount / 2);
        let bob_balance_1 = Account::balance<FAI::FAI>(@bob);
        assert(bob_balance_1 - bob_balance == amount / 2, 3)
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: bob
script {
use 0x1::Account;
use 0x1::Signer;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;

    const U128_MAX: u128 = 340282366920938463463374607431768211455u128;

    fun repay_mai_all(sender: signer) {
        let balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        let (debit, fee) = STCVaultPoolA::repay_mai(&sender, U128_MAX);
        let after_balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        let amount = debit + fee;
        let ast = balance - amount;
        assert(ast == after_balance,1);
        let (_, debit,fee, _, _) = STCVaultPoolA::info(Signer::address_of(&sender));
        assert(debit==0,1);
        assert(fee==0,2);
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: bob
script {
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    fun repay_mai_all(sender: signer) {
     STCVaultPoolA::repay_mai(&sender, 1);
    }
}
// check: " Keep(ABORTED { code: 52487, "



//! new-transaction
//! sender: bob
script {
    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::STC;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    fun withdraw(sender: signer) {
        let balance = Account::balance<STC::STC>(Signer::address_of(&sender));
        STCVaultPoolA::withdraw(&sender, 1);
        let balance2 = Account::balance<STC::STC>(Signer::address_of(&sender));
        let n = (balance + 1);
        assert( n == balance2,1);
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: bob
script {
    use 0x1::Token;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;

    fun borrow_mai(sender: signer) {
        // current mock max is 1280
        let amount = (1280 * Token::scaling_factor<FAI::FAI>() as u128) + 1 ;
        STCVaultPoolA::borrow_mai(&sender, amount);
    }
}
// check: " Keep(ABORTED { code: 170503, "



//! new-transaction
//! sender: bob
script {
    use 0x1::Signer;
    use 0x1::Token;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::STCVaultPoolA;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;
    fun borrow_mai(sender: signer) {
        let max=    STCVaultPoolA::max_borrow(Signer::address_of(&sender));
        assert(max ==1279200000000,1);
        STCVaultPoolA::deposit(&sender, 1);
        max= STCVaultPoolA::max_borrow(Signer::address_of(&sender));
        assert(max == (1280 * Token::scaling_factor<FAI::FAI>() as u128),2);
    }
}
// check: "Keep(EXECUTED)"