/*
    TODO: 
    - whitelist should be adapted here?
*/ 

module baptswap::router_v2 {
    use aptos_framework::coin;
    use std::signer;
    use baptswap::swap_utils;
    use baptswap::swap_v2;

    // ------
    // Errors
    // ------

    // Output amount is less than required
    const E_OUTPUT_LESS_THAN_MIN: u64 = 0;
    // Require Input amount is more than max limit
    const E_INPUT_MORE_THAN_MAX: u64 = 1;
    // Insufficient X
    const E_INSUFFICIENT_X_AMOUNT: u64 = 2;
    // Insufficient Y
    const E_INSUFFICIENT_Y_AMOUNT: u64 = 3;
    // Pair is not created
    const E_PAIR_NOT_CREATED: u64 = 4;
    // Pool already created
    const E_POOL_EXISTS: u64 = 5;
    // Pool not created
    const E_POOL_NOT_CREATED: u64 = 6;

    // Create a Pair from 2 Coins
    // Should revert if the pair is already created
    public entry fun create_pair<X, Y>(
        sender: &signer,
    ) {
        if (swap_utils::sort_token_type<X, Y>()) {
            swap_v2::create_pair<X, Y>(sender);
        } else {
            swap_v2::create_pair<Y, X>(sender);
        }
    }

    public entry fun create_rewards_pool<X, Y>(
        sender: &signer,
        is_x_staked: bool
    ) {
        assert!(((swap_v2::is_pair_created<X, Y>() || swap_v2::is_pair_created<Y, X>())), E_PAIR_NOT_CREATED);
        assert!(!((swap_v2::is_pool_created<X, Y>() || swap_v2::is_pool_created<Y, X>())), E_POOL_EXISTS);

        if (swap_utils::sort_token_type<X, Y>()) {
            swap_v2::init_rewards_pool<X, Y>(sender, is_x_staked);
        } else {
            swap_v2::init_rewards_pool<Y, X>(sender, !is_x_staked);
        }
    }

    public entry fun stake_tokens_in_pool<X, Y>(
        sender: &signer,
        amount: u64
    ) {
        assert!(((swap_v2::is_pair_created<X, Y>() || swap_v2::is_pair_created<Y, X>())), E_PAIR_NOT_CREATED);
        assert!(((swap_v2::is_pool_created<X, Y>() || swap_v2::is_pool_created<Y, X>())), E_POOL_NOT_CREATED);

        if (swap_utils::sort_token_type<X, Y>()) {
            swap_v2::stake_tokens<X, Y>(sender, amount);
        } else {
            swap_v2::stake_tokens<Y, X>(sender, amount);
        }
    }


    public entry fun withdraw_tokens_from_pool<X, Y>(
        sender: &signer,
        amount: u64
    ) {
        assert!(((swap_v2::is_pair_created<X, Y>() || swap_v2::is_pair_created<Y, X>())), E_PAIR_NOT_CREATED);
        assert!(((swap_v2::is_pool_created<X, Y>() || swap_v2::is_pool_created<Y, X>())), E_POOL_NOT_CREATED);

        if (swap_utils::sort_token_type<X, Y>()) {
            swap_v2::withdraw_tokens<X, Y>(sender, amount);
        } else {
            swap_v2::withdraw_tokens<Y, X>(sender, amount);
        }
    }

    public entry fun claim_rewards_from_pool<X, Y>(
        sender: &signer
    ) {
        assert!(((swap_v2::is_pair_created<X, Y>() || swap_v2::is_pair_created<Y, X>())), E_PAIR_NOT_CREATED);
        assert!(((swap_v2::is_pool_created<X, Y>() || swap_v2::is_pool_created<Y, X>())), E_POOL_NOT_CREATED);

        if (swap_utils::sort_token_type<X, Y>()) {
            swap_v2::claim_rewards<X, Y>(sender);
        } else {
            swap_v2::claim_rewards<Y, X>(sender);
        }
    }

    // Add Liquidity, create pair if it's needed
    public entry fun add_liquidity<X, Y>(
        sender: &signer,
        amount_x_desired: u64,
        amount_y_desired: u64,
        amount_x_min: u64,
        amount_y_min: u64,
    ) {
        if (!(swap_v2::is_pair_created<X, Y>() || swap_v2::is_pair_created<Y, X>())) {
            create_pair<X, Y>(sender);
        };

        let amount_x;
        let amount_y;
        let _lp_amount;
        if (swap_utils::sort_token_type<X, Y>()) {
            (amount_x, amount_y, _lp_amount) = swap_v2::add_liquidity<X, Y>(sender, amount_x_desired, amount_y_desired);
            assert!(amount_x >= amount_x_min, E_INSUFFICIENT_X_AMOUNT);
            assert!(amount_y >= amount_y_min, E_INSUFFICIENT_Y_AMOUNT);
        } else {
            (amount_y, amount_x, _lp_amount) = swap_v2::add_liquidity<Y, X>(sender, amount_y_desired, amount_x_desired);
            assert!(amount_x >= amount_x_min, E_INSUFFICIENT_X_AMOUNT);
            assert!(amount_y >= amount_y_min, E_INSUFFICIENT_Y_AMOUNT);
        };
    }

    fun is_pair_created_internal<X, Y>(){
        assert!(swap_v2::is_pair_created<X, Y>() || swap_v2::is_pair_created<Y, X>(), E_PAIR_NOT_CREATED);
    }

    // Remove Liquidity
    public entry fun remove_liquidity<X, Y>(
        sender: &signer,
        liquidity: u64,
        amount_x_min: u64,
        amount_y_min: u64
    ) {
        is_pair_created_internal<X, Y>();
        let amount_x;
        let amount_y;
        if (swap_utils::sort_token_type<X, Y>()) {
            (amount_x, amount_y) = swap_v2::remove_liquidity<X, Y>(sender, liquidity);
            assert!(amount_x >= amount_x_min, E_INSUFFICIENT_X_AMOUNT);
            assert!(amount_y >= amount_y_min, E_INSUFFICIENT_Y_AMOUNT);
        } else {
            (amount_y, amount_x) = swap_v2::remove_liquidity<Y, X>(sender, liquidity);
            assert!(amount_x >= amount_x_min, E_INSUFFICIENT_X_AMOUNT);
            assert!(amount_y >= amount_y_min, E_INSUFFICIENT_Y_AMOUNT);
        }
    }

    fun add_swap_event_with_address_internal<X, Y>(
        sender_addr: address,
        amount_x_in: u64,
        amount_y_in: u64,
        amount_x_out: u64,
        amount_y_out: u64
    ) {
        if (swap_utils::sort_token_type<X, Y>()){
            swap_v2::add_swap_event_with_address<X, Y>(sender_addr, amount_x_in, amount_y_in, amount_x_out, amount_y_out);
        } else {
            swap_v2::add_swap_event_with_address<Y, X>(sender_addr, amount_y_in, amount_x_in, amount_y_out, amount_x_out);
        }
    }

    fun add_swap_event_internal<X, Y>(
        sender: &signer,
        amount_x_in: u64,
        amount_y_in: u64,
        amount_x_out: u64,
        amount_y_out: u64
    ) {
        let sender_addr = signer::address_of(sender);
        add_swap_event_with_address_internal<X, Y>(sender_addr, amount_x_in, amount_y_in, amount_x_out, amount_y_out);
    }

    // Swap exact input amount of X to maxiumin possible amount of Y
    public entry fun swap_exact_input<X, Y>(
        sender: &signer,
        x_in: u64,
        y_min_out: u64,
    ) {
        is_pair_created_internal<X, Y>();
        let y_out = if (swap_utils::sort_token_type<X, Y>()) {
            swap_v2::swap_exact_x_to_y<X, Y>(sender, x_in, signer::address_of(sender))
        } else {
            swap_v2::swap_exact_y_to_x<Y, X>(sender, x_in, signer::address_of(sender))
        };
        assert!(y_out >= y_min_out, E_OUTPUT_LESS_THAN_MIN);
        add_swap_event_internal<X, Y>(sender, x_in, 0, 0, y_out);
    }

    // TODO: swap_exact_output

    // TODO: get_intermediate_output

    // TODO: swap_exact_x_to_y_direct_external

    // TODO: get_intermediate_output_x_to_exact_y

    // TODO: get_amount_in_internal

    // TODO: get_amount_in

    // TODO: 

    public entry fun register_lp<X, Y>(sender: &signer) {
        swap_v2::register_lp<X, Y>(sender);
    }

    public entry fun register_token<X>(sender: &signer) {
        coin::register<X>(sender);
    }
}