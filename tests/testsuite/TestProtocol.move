//! account: admin ,FaiAdmin, 20000000000 StarcoinFramework::STC::STC
//! account: bob,20000000000000 StarcoinFramework::STC::STC
//! account: alice,20000000000000 StarcoinFramework::STC::STC
//! sender: admin
script {
    use StarcoinFramework::Token;
    use FaiAdmin::FAI;
    use FaiAdmin::Vault;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::TestHelper;

    fun test_init(sender: signer) {
        TestHelper::init_oracle(&sender);
        let pool_exists = STCVaultPoolA::is_exists();
        assert(!pool_exists, 101);
        Vault::initialize(&sender);
        let max_mint_amount = 200000000000 * Token::scaling_factor<FAI::FAI>();
        let min_mint_amount = 1 * Token::scaling_factor<FAI::FAI>();
        let stability_fee_ratio = 300u128;
        let ccr = 30000u128;
        let max_deposit_per_vault = 1000000000000000u128;
        let liquidation_penalty = 10u128;
        let liquidation_threshold = 8000u128;
        STCVaultPoolA::initialize(&sender,
            max_mint_amount,
            min_mint_amount,
            stability_fee_ratio,
            ccr,
            max_deposit_per_vault,
            liquidation_penalty,
            liquidation_threshold);
        pool_exists = STCVaultPoolA::is_exists();
        assert(pool_exists, 101);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use StarcoinFramework::STC;
    use StarcoinFramework::Signer;

    use FaiAdmin::Vault;
    use FaiAdmin::STCVaultPoolA;

    fun create_vault(sender: signer) {
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
    use StarcoinFramework::STC;
    use StarcoinFramework::Account;
    use StarcoinFramework::Token;
    use StarcoinFramework::Signer;
    use FaiAdmin::STCVaultPoolA;

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
    use StarcoinFramework::Account;
    use StarcoinFramework::Token;
    use StarcoinFramework::Signer;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::FAI;


    fun borrow_fai_a(sender: signer) {
        assert(
            STCVaultPoolA::current_fai_supply() == 0, 1
        );
        let amount = (200 * Token::scaling_factor<FAI::FAI>() as u128) ;
        STCVaultPoolA::borrow_fai(&sender, amount);
        let balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        assert(amount == balance, 1);
        assert(
            STCVaultPoolA::current_fai_supply() == amount, 1
        );
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use StarcoinFramework::Account;
    use StarcoinFramework::Token;
    use StarcoinFramework::Signer;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::FAI;

    fun borrow_fai(sender: signer) {
        let balance_before = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        let amount = (1000 * Token::scaling_factor<FAI::FAI>() as u128) ;
        STCVaultPoolA::borrow_fai(&sender, amount);
        let balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        assert(amount + balance_before == balance, 1);
    }
}
// check: "Keep(EXECUTED)"



//! new-transaction
//! sender: bob
script {
    use StarcoinFramework::Account;
    use StarcoinFramework::Token;
    use StarcoinFramework::Signer;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::FAI;

    fun borrow_fai(sender: signer) {
        // current mock max is 1280
        let balance_before = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        let amount = (80 * Token::scaling_factor<FAI::FAI>() as u128) + 1 ;
        STCVaultPoolA::borrow_fai(&sender, amount);
        let balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        assert((amount + balance_before) == balance, 1);
    }
}
// check: "Keep(EXECUTED)"


//! block-prologue
//! block-time: 31536000000
//! author: genesis
//! block-number: 1
//! new-transaction
//! sender: bob
script {
    use StarcoinFramework::Signer;
    use StarcoinFramework::STC;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::Vault;

    fun borrow_fai(sender: signer) {
        let (_, fai_debit, fee, toke_balance, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender));
        assert(38399999999 == fee, 1);
        assert(1280000000001 == fai_debit, 2);
        assert(10000000000000 == toke_balance, 3);
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: admin
script {
    use FaiAdmin::Config;

    fun switch_on(sender: signer) {
        Config::set_global_switch(&sender, true);
    }
}

//! new-transaction
//! sender: bob
script {

    use FaiAdmin::STCVaultPoolA;

    fun repay_mai(sender: signer) {

        STCVaultPoolA::repay_fai(&sender, 0u128);
    }
}
// check: " Keep(ABORTED { code: 52993, "

//! new-transaction
//! sender: admin
script {
    use FaiAdmin::Config;

    fun switch_off(sender: signer) {
        Config::set_global_switch(&sender, false);
    }
}


//! new-transaction
//! sender: bob
script {
    use StarcoinFramework::Token;
    use StarcoinFramework::Signer;

    use StarcoinFramework::STC;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::FAI;
    use FaiAdmin::Vault;
    use FaiAdmin::Treasury;

    fun repay_mai(sender: signer) {
        let b_market_cap = Token::market_cap<FAI::FAI>();
        let (_, b_fai_debit, b_fee, _, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender));
        let amount = 10 * Token::scaling_factor<FAI::FAI>();
        STCVaultPoolA::repay_fai(&sender, amount);
        let (_, a_fai_debit, a_fee, _, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender));
        let a_market_cap = Token::market_cap<FAI::FAI>();
        let after = (b_fai_debit - a_fai_debit) + (b_fee - a_fee);
        assert(amount == after, 1);
        assert(Treasury::treasury_balance<FAI::FAI>() == (b_fee - a_fee), 2);
        assert((b_fai_debit - a_fai_debit) == (b_market_cap - a_market_cap), 3);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use FaiAdmin::STCVaultPoolA;

    const U128_MAX: u128 = 340282366920938463463374607431768211455u128;

    fun repay_mai_all(sender: signer) {
        STCVaultPoolA::repay_fai(&sender, U128_MAX);
    }
}
// check: " Keep(ABORTED { code: 52231, "

//! new-transaction
//! sender: alice
address bob = {{bob}};
script {
    use StarcoinFramework::STC;
    use StarcoinFramework::Signer;
    use StarcoinFramework::Token;
    use StarcoinFramework:: Account;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::FAI;

    fun transfer_to_bob(sender: signer) {
        STCVaultPoolA::create_vault(&sender);
        let amount = (10000 * Token::scaling_factor<STC::STC>() as u128) ;
        STCVaultPoolA::deposit(&sender, amount);
        let amount = (200 * Token::scaling_factor<FAI::FAI>() as u128) ;
        STCVaultPoolA::borrow_fai(&sender, amount);
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
    use StarcoinFramework::Account;
    use StarcoinFramework::Signer;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::FAI;

    fun repay_mai_all(sender: signer) {
        let balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        let (debit, fee) = STCVaultPoolA::repay_fai(&sender, 0);
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
    use FaiAdmin::STCVaultPoolA;
    fun repay_fai_all(sender: signer) {
         STCVaultPoolA::repay_fai(&sender, 1);
    }
}
// check: " Keep(ABORTED { code: 52487, "



//! new-transaction
//! sender: bob
script {
    use StarcoinFramework::Account;
    use StarcoinFramework::Signer;
    use StarcoinFramework::STC;
    use FaiAdmin::STCVaultPoolA;
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
    use StarcoinFramework::Token;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::FAI;

    fun borrow_mai(sender: signer) {
        // current mock max is 1280
        let amount = (1280 * Token::scaling_factor<FAI::FAI>() as u128) + 1 ;
        STCVaultPoolA::borrow_fai(&sender, amount);
    }
}
// check: "Keep(EXECUTED)"



//! new-transaction
//! sender: bob
script {
    use StarcoinFramework::Signer;
//    use StarcoinFramework::Token;
    use FaiAdmin::STCVaultPoolA;
//    use FaiAdmin::FAI;
    fun borrow_mai(sender: signer) {
        let max = STCVaultPoolA::max_borrow(Signer::address_of(&sender));
        assert(max ==3333333333333,1);
        STCVaultPoolA::deposit(&sender, 1);
        max= STCVaultPoolA::max_borrow(Signer::address_of(&sender));
        assert(max == 3333333333333,2);
    }
}
// check: "Keep(EXECUTED)"