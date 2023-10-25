#[test_only]
module baptswap::swap_v2_test {
    use std::signer;
    use test_coin::test_coins::{Self, TestCAKE, TestBUSD, TestUSDC, TestBNB, TestAPT};
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::genesis;
    use aptos_framework::resource_account;
    use baptswap::swap_v2::{Self, LPToken, initialize};
    use baptswap::router_v2;
    use baptswap::math;
    use aptos_std::math64::pow;
    use baptswap::swap_utils;

    const MAX_U64: u64 = 18446744073709551615;
    const MINIMUM_LIQUIDITY: u128 = 1000;

    public fun setup_test_with_genesis(dev: &signer, admin: &signer, treasury: &signer, resource_account: &signer) {
        genesis::setup();
        setup_test(dev, admin, treasury, resource_account);
    }

    public fun setup_test(dev: &signer, admin: &signer, treasury: &signer, resource_account: &signer) {
        account::create_account_for_test(signer::address_of(dev));
        account::create_account_for_test(signer::address_of(admin));
        account::create_account_for_test(signer::address_of(treasury));
        resource_account::create_resource_account(dev, b"datswap", x"");
        initialize(resource_account);
        swap_v2::set_admin_address(admin, signer::address_of(treasury))
    }

    #[test(dev = @dev, admin = @default_admin, resource_account = @baptswap, treasury = @0x23456, bob = @0x12345, alice = @0x12346)]
    fun test_create_and_staked_tokens(
        dev: &signer,
        admin: &signer,
        resource_account: &signer,
        treasury: &signer,
        bob: &signer,
        alice: &signer,
    ) {
        account::create_account_for_test(signer::address_of(bob));
        account::create_account_for_test(signer::address_of(alice));

        setup_test_with_genesis(dev, admin, treasury, resource_account);

        let coin_owner = test_coins::init_coins();

        test_coins::register_and_mint<TestCAKE>(&coin_owner, bob, 100 * pow(10, 8));
        test_coins::register_and_mint<TestBUSD>(&coin_owner, bob, 100 * pow(10, 8));
        test_coins::register_and_mint<TestCAKE>(&coin_owner, alice, 100 * pow(10, 8));
        test_coins::register_and_mint<TestBUSD>(&coin_owner, alice, 10 * pow(10, 8));

        let bob_liquidity_x = 10 * pow(10, 8);
        let bob_liquidity_y = 10 * pow(10, 8);
        let alice_liquidity_x = 2 * pow(10, 8);
        let alice_liquidity_y = 4 * pow(10, 8);

        // bob provider liquidity for 5:10 CAKE-BUSD
        router_v2::add_liquidity<TestCAKE, TestBUSD>(bob, bob_liquidity_x, bob_liquidity_y, 0, 0);

        swap_v2::set_token_pair_owner<TestCAKE, TestBUSD>(admin, signer::address_of(bob));

        // Initialize rewards pool
        router_v2::create_rewards_pool<TestBUSD, TestCAKE>(bob, false); 

        // set fees
        swap_v2::set_buy_liquidity_fee<TestCAKE, TestBUSD>(bob, 100);
        swap_v2::set_buy_rewards_fee<TestBUSD, TestCAKE>(bob, 200);
        swap_v2::set_buy_team_fee<TestBUSD, TestCAKE>(bob, 200);

        swap_v2::set_sell_liquidity_fee<TestCAKE, TestBUSD>(bob, 100);
        swap_v2::set_sell_rewards_fee<TestBUSD, TestCAKE>(bob, 200);
        swap_v2::set_sell_team_fee<TestBUSD, TestCAKE>(bob, 200);

        let input_x = 1 * pow(10, 8);

        router_v2::stake_tokens_in_pool<TestCAKE, TestBUSD>(alice, 5 * pow(10, 8));
        router_v2::stake_tokens_in_pool<TestBUSD, TestCAKE>(bob, 5 * pow(10, 8));

        let (staked_tokens, balance_x, balance_y, magnified_dividends_per_share_x, magnified_dividends_per_share_y, precision_factor, is_x_staked) = swap_v2::token_rewards_pool_info<TestBUSD, TestCAKE>();

        assert!(staked_tokens == 10 * pow(10, 8), 130);

        router_v2::swap_exact_input<TestCAKE, TestBUSD>(alice, input_x, 0);
        router_v2::swap_exact_input<TestBUSD, TestCAKE>(alice, input_x, 0);

        let (treasury_balance_x, treasury_balance_y, team_balance_x, team_balance_y, pool_balance_x, pool_balance_y) = swap_v2::token_fees_accumulated<TestBUSD, TestCAKE>();

        assert!(treasury_balance_y == 1 * pow(10, 5), 125);
        assert!(pool_balance_y == 2 * pow(10, 6), 126);
        assert!(pool_balance_x == 2 * pow(10, 6), 126);

        let (staked_tokens, balance_x, balance_y, magnified_dividends_per_share_x, magnified_dividends_per_share_y, precision_factor, is_x_staked) = swap_v2::token_rewards_pool_info<TestBUSD, TestCAKE>();

        assert!(precision_factor == (1 * pow(10, 12) as u128), 127);
        assert!(!is_x_staked, 128);
        assert!(balance_y == 2 * pow(10, 6), 131);
        assert!(magnified_dividends_per_share_y > 0, 132);
        assert!(magnified_dividends_per_share_x == magnified_dividends_per_share_y, 133);

        router_v2::withdraw_tokens_from_pool<TestBUSD, TestCAKE>(alice, 3 * pow(10, 8));
        router_v2::claim_rewards_from_pool<TestCAKE, TestBUSD>(bob);

        router_v2::stake_tokens_in_pool<TestBUSD, TestCAKE>(bob, 1 * pow(10, 8));

        let (staked_tokens, balance_x, balance_y, magnified_dividends_per_share_x, magnified_dividends_per_share_y, precision_factor, is_x_staked) = swap_v2::token_rewards_pool_info<TestBUSD, TestCAKE>();

        assert!(balance_y == 0 * pow(10, 6), 134);
        assert!(balance_x == 0 * pow(10, 6), 135);
        assert!(staked_tokens == 8 * pow(10, 8), 136);

        router_v2::swap_exact_input<TestBUSD, TestCAKE>(alice, input_x, 0);

        let (staked_tokens, balance_x, balance_y, magnified_dividends_per_share_x, magnified_dividends_per_share_y, precision_factor, is_x_staked) = swap_v2::token_rewards_pool_info<TestBUSD, TestCAKE>();

        assert!(balance_x == 2 * pow(10, 6), 134);

        router_v2::claim_rewards_from_pool<TestCAKE, TestBUSD>(alice);

        let (staked_tokens, balance_x, balance_y, magnified_dividends_per_share_x, magnified_dividends_per_share_y, precision_factor, is_x_staked) = swap_v2::token_rewards_pool_info<TestBUSD, TestCAKE>();

        assert!(balance_x == 15 * pow(10, 5), 135);

        router_v2::withdraw_tokens_from_pool<TestCAKE, TestBUSD>(bob, 6 * pow(10, 8));

        let (staked_tokens, balance_x, balance_y, magnified_dividends_per_share_x, magnified_dividends_per_share_y, precision_factor, is_x_staked) = swap_v2::token_rewards_pool_info<TestBUSD, TestCAKE>();

        assert!(staked_tokens == 2 * pow(10, 8), 136);

    }

}
