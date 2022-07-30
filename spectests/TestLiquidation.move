//# init -n dev --public-keys FaiAdmin=0x1725f86f6e4492afc3c2a6089d7d53a07ae88297b780464d13bba404a969d189

//# faucet --addr admin --amount 100000000000000

//# faucet --addr FaiAdmin --amount 100000000000000

//# faucet --addr alice --amount 100000000000000

//# faucet --addr bob --amount 1000000000000000

//# block --timestamp 31136000000

//# run --signers FaiAdmin
script {
    use StarcoinFramework::Token;
    use FaiAdmin::FAI;
    use FaiAdmin::Vault;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::TestHelper;

    fun test_init(sender: signer) {
        TestHelper::init_oracle(&sender);
        let pool_exists = STCVaultPoolA::is_exists();
        assert!(!pool_exists, 101);
        Vault::initialize(&sender);
        let max_mint_amount = 200000000000 * Token::scaling_factor<FAI::FAI>();
        let min_mint_amount = 1 * Token::scaling_factor<FAI::FAI>();
        let stability_fee_ratio = 300u128;
        let ccr = 30000u128;
        let max_deposit_per_vault = 1000000000000000u128;
        let liquidation_penalty = 10u128;
        let liquidation_threshold = 15000u128;
        STCVaultPoolA::initialize(&sender,
            max_mint_amount,
            min_mint_amount,
            stability_fee_ratio,
            ccr,
            max_deposit_per_vault,
            liquidation_penalty,
            liquidation_threshold);
        STCVaultPoolA::initialize_event(&sender);
        pool_exists = STCVaultPoolA::is_exists();
        assert!(pool_exists, 101);
    }
}
// check: EXECUTED

//# run --signers bob
script {
    use StarcoinFramework::STC;
    use StarcoinFramework::Signer;

    use FaiAdmin::Vault;
    use FaiAdmin::STCVaultPoolA;

    fun create_vault(sender: signer) {
        assert!(
            !Vault::vault_exist<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender))
            , 1
        );
        STCVaultPoolA::create_vault(&sender);
        assert!(
            Vault::vault_exist<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender))
            , 1
        );
    }
}
// check: "Keep(EXECUTED)"

//# run --signers bob
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
        assert!(after_balance + amount == balance, 1);
    }
}
// check: "Keep(EXECUTED)"


//# run --signers bob
script {
    use StarcoinFramework::Account;
    use StarcoinFramework::Token;
    use StarcoinFramework::Signer;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::FAI;


    fun borrow_fai_a(sender: signer) {
        assert!(
            STCVaultPoolA::current_fai_supply() == 0, 1
        );
        let amount = (200 * Token::scaling_factor<FAI::FAI>() as u128) ;
        STCVaultPoolA::borrow_fai(&sender, amount);
        let balance = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        assert!(amount == balance, 1);
        assert!(
            STCVaultPoolA::current_fai_supply() == amount, 1
        );
    }
}
// check: "Keep(EXECUTED)"

//# run --signers bob
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
        assert!(amount + balance_before == balance, 1);
    }
}
// check: "Keep(EXECUTED)"



//# run --signers bob
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
        assert!((amount + balance_before) == balance, 1);
    }
}
// check: "Keep(EXECUTED)"

//# block --timestamp 31536000000


//# run --signers bob
script {
    use StarcoinFramework::Signer;
    use StarcoinFramework::STC;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::Vault;

    fun borrow_fai(sender: signer) {
        let (_, fai_debit, fee, toke_balance, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender));
        assert!(487062404 == fee, 1);
        assert!(1280000000001 == fai_debit, 2);
        assert!(10000000000000 == toke_balance, 3);
    }
}
// check: "Keep(EXECUTED)"

//# run --signers bob
script {
    use FaiAdmin::STCVaultPoolA;

    fun borrow_all_of_fai(sender: signer) {
        STCVaultPoolA::borrow_fai(&sender, 0u128);
    }
}
// check: "Keep(EXECUTED)"

//# run --signers FaiAdmin
script {
    use FaiAdmin::TestHelper;

    fun update_stc_oracle(sender: signer) {
        TestHelper::update_price(&sender, 500000u128);
    }
}
// check: "Keep(EXECUTED)"

//# run --signers bob
script {

    use StarcoinFramework::STC;
    use FaiAdmin::Vault;
    use FaiAdmin::Liquidation;
    use FaiAdmin::STCVaultPoolA;

    fun check_health_factor_calc() {

        let health_factor_of_bob = Liquidation::health_factor_by_address<STCVaultPoolA::VaultPool, STC::STC>(@bob);
        assert!(health_factor_of_bob == 1000000000000200000, 4);
        let (_, debt_fai_amount, stability_fee, collateral_amount, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(@bob);
        StarcoinFramework::Debug::print(&debt_fai_amount);
        StarcoinFramework::Debug::print(&stability_fee);
        StarcoinFramework::Debug::print(&collateral_amount);
    }
}
// check: "Keep(EXECUTED)"




//# run --signers FaiAdmin
script {
    use FaiAdmin::Config;

    fun switch_on(sender: signer) {
        Config::set_global_switch(&sender, true);
    }
}
// check: "Keep(EXECUTED)"


//# run --signers bob
script {

    use FaiAdmin::STCVaultPoolA;

    fun repay_mai(sender: signer) {
        STCVaultPoolA::repay_fai(&sender, 0u128);
    }
}
// check: " Keep(ABORTED { code: 52993, "

//# run --signers FaiAdmin
script {
    use FaiAdmin::Config;

    fun switch_off(sender: signer) {
        Config::set_global_switch(&sender, false);
    }
}

//# run --signers alice
script {
    use StarcoinFramework::STC;
    use StarcoinFramework::Signer;

    use FaiAdmin::Vault;
    use FaiAdmin::STCVaultPoolA;

    fun create_vault(sender: signer) {
        assert!(
            !Vault::vault_exist<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender))
            , 1
        );
        STCVaultPoolA::create_vault(&sender);
        assert!(
            Vault::vault_exist<STCVaultPoolA::VaultPool, STC::STC>(Signer::address_of(&sender))
            , 1
        );
    }
}
// check: "Keep(EXECUTED)"

//# run --signers alice
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
        assert!(after_balance + amount == balance, 1);
    }
}
// check: "Keep(EXECUTED)"

//# run --signers alice
script {
    use FaiAdmin::STCVaultPoolA;

    fun borrow_all_of_fai(sender: signer) {
        STCVaultPoolA::borrow_fai(&sender, 0u128);
    }
}
// check: "Keep(EXECUTED)"

//# run --signers FaiAdmin
script {
    use FaiAdmin::TestHelper;

    fun update_stc_oracle(sender: signer) {
        TestHelper::update_price(&sender, 400000u128);
    }
}
// check: "Keep(EXECUTED)"

//# run --signers alice
script {
    use StarcoinFramework::Account;
    use StarcoinFramework::Signer;
    use StarcoinFramework::STC;
    use FaiAdmin::FAI;
    use FaiAdmin::Math;
    use FaiAdmin::Vault;
    use FaiAdmin::Config;
    use FaiAdmin::Liquidation;
    use FaiAdmin::Exponential;
    use FaiAdmin::STCVaultPoolA;

    fun clip_bob(sender: signer) {
        let health_factor_of_bob = Liquidation::health_factor_by_address<STCVaultPoolA::VaultPool, STC::STC>(@bob);
        StarcoinFramework::Debug::print(&health_factor_of_bob);
        let (_, debt_fai_amount, stability_fee, before_collateral_amount, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(@bob);
        let before_liq_fai_amount = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        let before_liq_stc_amount = Account::balance<STC::STC>(Signer::address_of(&sender));
        Liquidation::clip<STCVaultPoolA::VaultPool, STC::STC>(&sender, @bob, 0u128);
        let (_, _, _, after_collateral_amount, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(@bob);
        let after_liq_fai_amount = Account::balance<FAI::FAI>(Signer::address_of(&sender));
        let after_liq_stc_amount = Account::balance<STC::STC>(Signer::address_of(&sender));
        let cover_amount = before_liq_fai_amount - after_liq_fai_amount;
        let bob_liq_collateral = before_collateral_amount - after_collateral_amount;
        let bob_liq_amount = (debt_fai_amount + stability_fee) / 2;
        let alice_get_collateral = after_liq_stc_amount - before_liq_stc_amount;
        let config = Config::get<STCVaultPoolA::VaultPool>();
        let (_, _, _, _, _, liq_penalty, _) = Config::unpack<STCVaultPoolA::VaultPool>(config);
        let price_discount = 400000u128 * (100 - liq_penalty);
        let liquidate_collateral_amount_exp = Exponential::exp(cover_amount, price_discount);
        let exp_scaling = Math::pow_10(18);
        let scaling = exp_scaling / (1000000u128 * 100u128);
        let check_collateral_liq_amount = Exponential::mantissa(liquidate_collateral_amount_exp) / scaling;
        StarcoinFramework::Debug::print(&before_collateral_amount);
//        StarcoinFramework::Debug::print(&before_liq_fai_amount);
//        StarcoinFramework::Debug::print(&after_liq_fai_amount);
//        StarcoinFramework::Debug::print(&bob_liq_amount);
//        StarcoinFramework::Debug::print(&alice_get_collateral);
//        StarcoinFramework::Debug::print(&check_collateral_liq_amount);

        assert!(cover_amount == bob_liq_amount, 5);
        assert!(bob_liq_collateral == alice_get_collateral, 6);
        assert!(check_collateral_liq_amount == alice_get_collateral, 7);
    }
}
// check: "Keep(EXECUTED)"

//# run --signers bob
script {

    use StarcoinFramework::STC;
    use FaiAdmin::Vault;
    use FaiAdmin::Liquidation;
    use FaiAdmin::STCVaultPoolA;

    fun check_health_factor_calc() {

        let health_factor_of_bob = Liquidation::health_factor_by_address<STCVaultPoolA::VaultPool, STC::STC>(@bob);
//        assert!(health_factor_of_bob == 1000000000000200000, 4);
        StarcoinFramework::Debug::print(&health_factor_of_bob);
        let (_, debt_fai_amount, stability_fee, collateral_amount, _) = Vault::info<STCVaultPoolA::VaultPool, STC::STC>(@bob);
        StarcoinFramework::Debug::print(&debt_fai_amount);
        StarcoinFramework::Debug::print(&stability_fee);
        StarcoinFramework::Debug::print(&collateral_amount);
    }
}
// check: "Keep(EXECUTED)"
