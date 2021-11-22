address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
    module Treasury {

        use 0x1::Token;
        use 0x1::Signer;
        use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin;

        const INVALID_AMOUNT: u64 = 301;

        struct Vault<TokenType: store> has key, store {
            token: Token::Token<TokenType>
        }

        public fun initialize<TokenType: store> (account: &signer) {
            move_to(account, Vault<TokenType> {
                token: Token::zero<TokenType>()
            })
        }

        public fun deposit<TokenType: store> (tokens: Token::Token<TokenType>) acquires Vault {
            let admin_address = Admin::admin_address();
            let vault = borrow_global_mut<Vault<TokenType>>(admin_address);
            Token::deposit<TokenType>(&mut vault.token, tokens);
        }

        public fun withdraw<TokenType: store> (account: &signer, amount: u128): Token::Token<TokenType> acquires Vault {
            let vault = borrow_global_mut<Vault<TokenType>>(Signer::address_of(account));
            let reserve_amount = Token::value(&vault.token);
            assert(reserve_amount >= amount, INVALID_AMOUNT);
            Token::withdraw<TokenType>(&mut vault.token, amount)
        }
    }
}
