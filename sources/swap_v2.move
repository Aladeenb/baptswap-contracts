/*
    baptswap v2
    new features:
        - whitelist: allowing token owners to whitelist addresses to exempt them from fees; token owners are the first one to whitelist
    TODO: 
        - add resource for storing whitelist addresses; 
        whitelist addresses are exempted from token fee 
        and can be added/removed (by token owners?). 
        NOTE: THE WHITELIST IS MANAGED IN WHITELIST.move, TOKEN OWNER IS RETRIEVED FROM
        THE APTOSTOKENDEPLOYERCONTRACT.move => ONLY TOKENS DEPLOYED VIA THAT MODULE CAN BENEFIT FROM THE WHITELIST FEATURE.
        SWAP FUNCTIONS WILL CHECK IF THE SWAPPER IS WHITELISTED OR NOT.

        - add function to claim all rewards and convert them to APT or any given token.
        HINT: check TokenPairRewardsPool
        - add function to restake a given amount of tokens and claim the rest (check docs).
        - handle DEX Fees separately between LP providers and treasury.
        - swap exotic coins the moment the trade is made.
        - set a threshold for the token taxes (team fees?) and make it configurable.
        - Treasury address must be configurable (can be changed).
        - check audit report and work on fix the issue.
        - add multisignature support (check convo).
        - route finder: check which swap func is best for it + use swap_utils::sort_token_type<X,Y>().
        - Individual token fees should not exceed the threshold (15%).
        - work on Errors in assert funcs.
        - add a func for the lp pair to send fees to their destiniation (liquidity?, team, rewards).
*/
module baptswap::swap_v2 {
    use std::signer;
    use std::option;
    use std::string;
    use std::vector;

    use aptos_std::event;
    use aptos_std::math64;
    use aptos_std::type_info;
    
    use aptos_framework::coin;
    use aptos_framework::timestamp;
    use aptos_framework::account;
    use aptos_framework::resource_account;

    use baptswap::math;
    use baptswap::swap_utils;
    use baptswap::u256;

    friend baptswap::router_v2;

    const ZERO_ACCOUNT: address = @zero;
    const DEFAULT_ADMIN: address = @default_admin;
    const RESOURCE_ACCOUNT: address = @baptswap;
    const DEV: address = @dev;
    const MINIMUM_LIQUIDITY: u128 = 1000;
    const MAX_COIN_NAME_LENGTH: u64 = 32;

    // List of errors
    const ERROR_ONLY_ADMIN: u64 = 0;
    const ERROR_ALREADY_INITIALIZED: u64 = 1;
    const ERROR_NOT_CREATOR: u64 = 2;
    const ERROR_INSUFFICIENT_LIQUIDITY_MINTED: u64 = 4;
    const ERROR_INSUFFICIENT_AMOUNT: u64 = 6;
    const ERROR_INSUFFICIENT_LIQUIDITY: u64 = 7;
    const ERROR_INVALID_AMOUNT: u64 = 8;
    const ERROR_TOKENS_NOT_SORTED: u64 = 9;
    const ERROR_INSUFFICIENT_LIQUIDITY_BURNED: u64 = 10;
    const ERROR_INSUFFICIENT_OUTPUT_AMOUNT: u64 = 13;
    const ERROR_INSUFFICIENT_INPUT_AMOUNT: u64 = 14;
    const ERROR_K: u64 = 15;
    const ERROR_X_NOT_REGISTERED: u64 = 16;
    const ERROR_Y_NOT_REGISTERED: u64 = 16;
    const ERROR_NOT_ADMIN: u64 = 17;
    const ERROR_NOT_treasury_addr: u64 = 18;
    const ERROR_NOT_EQUAL_EXACT_AMOUNT: u64 = 19;
    const ERROR_NOT_RESOURCE_ACCOUNT: u64 = 20;
    const ERROR_NO_FEE_WITHDRAW: u64 = 21;
    const ERROR_EXCESSIVE_FEE: u64 = 22;
    const ERROR_PAIR_NOT_CREATED: u64 = 23;
    const ERROR_MUST_BE_INFERIOR_TO_TWENTY: u64 = 24;
    const ERROR_POOL_NOT_CREATED: u64 = 25;
    const ERROR_NO_STAKE: u64 = 26;
    const ERROR_INSUFFICIENT_BALANCE: u64 = 27;
    const ERROR_NO_REWARDS: u64 = 28;
    const ERROR_NOT_OWNER: u64 = 29;

    const PRECISION: u64 = 10000;

    // Max `u128` value.
    const MAX_U128: u128 = 340282366920938463463374607431768211455;

    // Max DEX fee threshold: 0.9%
    const MAX_DEX_FEE_THRESHOLD_NUMERATOR: u64 = 9;
    const MAX_DEX_FEE_THRESHOLD_DENOMINATOR: u64 = 1000;

    // Max individual token fee threshold: 15%
    const MAX_INDIVIDUAL_TOKEN_FEE_THRESHOLD_NUMERATOR: u64 = 15;
    const MAX_INDIVIDUAL_TOKEN_FEE_THRESHOLD_DENOMINATOR: u64 = 100;

    // The LP Token type
    struct LPToken<phantom X, phantom Y> has key {}

    // Stores the metadata required for the token pairs
    struct TokenPairMetadata<phantom X, phantom Y> has key {
        // The first provider of the token pair
        creator: address,
        // The admin of the token pair
        owner: address,
        // It's reserve_x * reserve_y, as of immediately after the most recent liquidity event
        k_last: u128,
        // The variable liquidity fee granted to providers; dex fee
        liquidity_fee: LiquidityFee,  
        // The team fee
        team_fee: TeamFee, 
        // The rewards fee
        rewards_fee: RewardsFee,  
        // T0 token balance
        balance_x: coin::Coin<X>,
        // T1 token balance
        balance_y: coin::Coin<Y>,
        // T0 treasury balance
        treasury_balance_x: coin::Coin<X>,
        // T1 treasury balance
        treasury_balance_y: coin::Coin<Y>,
        // T0 team balance
        team_balance_x: coin::Coin<X>,
        // T1 team balance
        team_balance_y: coin::Coin<Y>,
        // Mint capacity of LP Token
        mint_cap: coin::MintCapability<LPToken<X, Y>>,
        // Burn capacity of LP Token
        burn_cap: coin::BurnCapability<LPToken<X, Y>>,
        // Freeze capacity of LP Token
        freeze_cap: coin::FreezeCapability<LPToken<X, Y>>,
    }

    // Stores the liquidity fee
    struct LiquidityFee has key, store {
        buy: u128,
        sell: u128
    }

    // Stores the team fee
    struct TeamFee has key, store {
        buy: u128,
        sell: u128
    }

    // Stores the rewards fee
    struct RewardsFee has key, store {
        buy: u128,
        sell: u128
    }

    // Stores the reservation info required for the token pairs
    struct TokenPairReserve<phantom X, phantom Y> has key {
        reserve_x: u64,
        reserve_y: u64,
        block_timestamp_last: u64
    }

    // Stores the rewards pool info for token pairs
    struct TokenPairRewardsPool<phantom X, phantom Y> has key {
        staked_tokens: u64,
        balance_x: coin::Coin<X>,
        balance_y: coin::Coin<Y>,
        magnified_dividends_per_share_x: u128,
        magnified_dividends_per_share_y: u128,
        precision_factor: u128,
        is_x_staked: bool,
    }

    // Global storage for setting threshold for dex fees; configurable by dex owner.
    struct DexFeeThreshold has key {
        // current threshold for dex fees; should not exceed MAX_DEX_FEE_THRESHOLD
        numenator: u64,
        denominator: u64,
    }

    // Global storage for setting threshold individual token fees; configurable by dex owner.
    // as a rule: liquidity fee + team fee + rewards fee <= threshold
    // meaning: buy + buy + buy <= threshold
    // and: sell + sell + sell <= threshold
    // both buys and sells have the same threshold
    struct IndividualTokenFeeThreshold has key {
        // current threshold for individual token fees; should not exceed MAX_INDIVIDUAL_TOKEN_FEE_THRESHOLD
        numenator: u64,
        denominator: u64,
    }

    // Stores data about whitelist addresses; should be managed by dex owner
    struct Whitelist has key {
        vec: vector<address>,
        // added_to_whitelist_event: event::EventHandle<AddedToWhitelistEvent>,
        // removed_from_whitelist_event: event::EventHandle<RemovedFromWhitelistEvent>
    }

    struct RewardsPoolUserInfo<phantom X, phantom Y, phantom StakeToken> has key, store {
        staked_tokens: coin::Coin<StakeToken>,
        reward_debt_x: u128,
        reward_debt_y: u128,
        withdrawn_x: u64,
        withdrawn_y: u64,
    }

    // TODO: some fees goes to treasury_addr. Each fee must have a distinct address.
    struct SwapInfo has key {
        signer_cap: account::SignerCapability,
        treasury_addr: address,
        // The BaptSwap treasury fee
        treasury_fee: u128,
        admin: address,
        pair_created: event::EventHandle<PairCreatedEvent>
    }

    struct PairCreatedEvent has drop, store {
        user: address,
        token_x: string::String,
        token_y: string::String
    }

    struct PairEventHolder<phantom X, phantom Y> has key {
        add_liquidity: event::EventHandle<AddLiquidityEvent<X, Y>>,
        remove_liquidity: event::EventHandle<RemoveLiquidityEvent<X, Y>>,
        swap: event::EventHandle<SwapEvent<X, Y>>,
        change_fee: event::EventHandle<FeeChangeEvent<X, Y>>
    }

    struct AddLiquidityEvent<phantom X, phantom Y> has drop, store {
        user: address,
        amount_x: u64,
        amount_y: u64,
        liquidity: u64,

    }

    struct RemoveLiquidityEvent<phantom X, phantom Y> has drop, store {
        user: address,
        liquidity: u64,
        amount_x: u64,
        amount_y: u64,

    }

    struct SwapEvent<phantom X, phantom Y> has drop, store {
        user: address,
        amount_x_in: u64,
        amount_y_in: u64,
        amount_x_out: u64,
        amount_y_out: u64
    }

    struct FeeChangeEvent<phantom X, phantom Y> has drop, store {
        user: address,
        liquidity_fee: u128,
        team_fee: u128,
        rewards_fee: u128
    }

    /*

     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     Please use swap_util::sort_token_type<X,Y>()
     before using any function
     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    */

    // --------------------
    // Initialize functions
    // --------------------

    fun init_module(sender: &signer) acquires SwapInfo {
        let signer_cap = resource_account::retrieve_resource_account_cap(sender, DEV);
        let resource_signer = account::create_signer_with_capability(&signer_cap);
        move_to(&resource_signer, SwapInfo {
            signer_cap,
            treasury_addr: @baptswap,   // TODO: set a treasury address
            treasury_fee: 0,    // TODO: set an initial treasury fee
            admin: DEFAULT_ADMIN,
            pair_created: account::new_event_handle<PairCreatedEvent>(&resource_signer),
        });
        // init thresholds
        init_threshold<DexFeeThreshold>(sender);
        init_threshold<IndividualTokenFeeThreshold>(sender);
    }

    // init threshold; callable only by dex owner
    fun init_threshold<FeeThreshold>(
        signer_ref: &signer
    ) acquires SwapInfo {
        let signer_addr = signer::address_of(signer_ref);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        // assert!(signer_addr == swap_info.admin, ERROR_ONLY_ADMIN);
        let resource_signer = account::create_signer_with_capability(&swap_info.signer_cap);
        if (type_info::type_of<FeeThreshold>() == type_info::type_of<DexFeeThreshold>()) {
            assert!(!exists<DexFeeThreshold>(RESOURCE_ACCOUNT), ERROR_ALREADY_INITIALIZED);
            move_to(&resource_signer, DexFeeThreshold {
                numenator: MAX_DEX_FEE_THRESHOLD_NUMERATOR,
                denominator: MAX_DEX_FEE_THRESHOLD_DENOMINATOR
            });
        } else if (type_info::type_of<FeeThreshold>() == type_info::type_of<IndividualTokenFeeThreshold>()) {
            assert!(!exists<IndividualTokenFeeThreshold>(RESOURCE_ACCOUNT), ERROR_ALREADY_INITIALIZED);
            move_to(&resource_signer, IndividualTokenFeeThreshold {
                numenator: MAX_INDIVIDUAL_TOKEN_FEE_THRESHOLD_NUMERATOR,
                denominator: MAX_INDIVIDUAL_TOKEN_FEE_THRESHOLD_DENOMINATOR
            });
        } else {
            assert!(false, 1);
        }
    }

    public(friend) fun init_rewards_pool<X, Y>(
        sender: &signer,
        is_x_staked: bool
    ) acquires SwapInfo, TokenPairMetadata {
        assert!(is_pair_created<X, Y>(), ERROR_PAIR_NOT_CREATED);
        assert!(!exists<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT), ERROR_ALREADY_INITIALIZED);

        let sender_addr = signer::address_of(sender);

        // Check the initializer is the owner of the traded pair
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);

        // Create the pool resource
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        let resource_signer = account::create_signer_with_capability(&swap_info.signer_cap);

        let precision_factor = math::pow(10u128, 12u8);

        move_to<TokenPairRewardsPool<X, Y>>(
            &resource_signer,
            TokenPairRewardsPool {
                staked_tokens: 0,
                balance_x: coin::zero<X>(),
                balance_y: coin::zero<Y>(),
                magnified_dividends_per_share_x: 0,
                magnified_dividends_per_share_y: 0,
                precision_factor,
                is_x_staked
            }
        );
    }

    ///////////////////////////////// ADDED //////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////
    
    // TODO: revisit whitelist, check notes
    // Whitelist

    // init whitelist; callable only by dex owner
    public entry fun init_whitelist(signer_ref: &signer) acquires SwapInfo {
        let signer_addr = signer::address_of(signer_ref);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        assert!(signer_addr == swap_info.admin, ERROR_ONLY_ADMIN);
        assert!(!exists<Whitelist>(RESOURCE_ACCOUNT), ERROR_ALREADY_INITIALIZED);
        let resource_signer = account::create_signer_with_capability(&swap_info.signer_cap);
        move_to(&resource_signer, Whitelist {
            vec: vector::empty<address>(),
        });
    }

    // add to whitelist; callable only by dex owner
    public entry fun add_to_whitelist(
        signer_ref: &signer, 
        addr_to_whitelist: address
    ) acquires SwapInfo, Whitelist {
        let signer_addr = signer::address_of(signer_ref);
        let whitelist = borrow_global_mut<Whitelist>(RESOURCE_ACCOUNT);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        assert!(signer_addr == swap_info.admin, ERROR_ONLY_ADMIN);
        vector::push_back(&mut whitelist.vec, addr_to_whitelist);
    }

    // remove from whitelist; callable only by dex owner
    public entry fun remove_from_whitelist(
        signer_ref: &signer, 
        addr_to_whitelist: address
    ) acquires SwapInfo, Whitelist {
        let signer_addr = signer::address_of(signer_ref);
        let whitelist = borrow_global_mut<Whitelist>(RESOURCE_ACCOUNT);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        assert!(signer_addr == swap_info.admin, ERROR_ONLY_ADMIN);
        let (found, index) = vector::index_of(&whitelist.vec, &addr_to_whitelist);
        assert!(found == true, 1);
        vector::remove(&mut whitelist.vec, index);  // removed address can be retrieved here 
    }

    // Threshold

    // Helper function to calculate fees given a numenator and a denominator
    inline fun calculate_fee(numenator: u64, denominator: u64): u64 {
        math64::mul_div(numenator, 1, denominator)
    }

    // TODO: assert individual token fees does not exceed threshold

    //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////

    

    // Calculate and adjust the maginified dividends per share
    fun update_pool<X, Y>(pool_info: &mut TokenPairRewardsPool<X, Y>, reward_x: u64, reward_y: u64) {
        if (pool_info.staked_tokens == 0) {
            return
        };

        let (new_x_magnified_dividends_per_share, new_y_magnified_dividends_per_share) = cal_acc_token_per_share(
            pool_info.magnified_dividends_per_share_x,
            pool_info.magnified_dividends_per_share_y,
            pool_info.staked_tokens,
            pool_info.precision_factor,
            reward_x,
            reward_y
        );

        // Update magnitude values
        pool_info.magnified_dividends_per_share_x = new_x_magnified_dividends_per_share;
        pool_info.magnified_dividends_per_share_y = new_y_magnified_dividends_per_share;
    }

    fun cal_acc_token_per_share(
        last_magnified_dividends_per_share_x: u128,
        last_magnified_dividends_per_share_y: u128,
        total_staked_token: u64, 
        precision_factor: u128, 
        reward_x: u64, 
        reward_y: u64
    ): (u128, u128) {
        if (reward_x == 0 && reward_y == 0) return (last_magnified_dividends_per_share_x, last_magnified_dividends_per_share_y);

        let x_token_per_share_u256 = u256::from_u64(0u64);
        let y_token_per_share_u256 = u256::from_u64(0u64);

        if (reward_x > 0) {
            // acc_token_per_share = acc_token_per_share + (reward * precision_factor) / total_stake;
            x_token_per_share_u256 = u256::add(
                u256::from_u128(last_magnified_dividends_per_share_x),
                u256::div(
                    u256::mul(u256::from_u64(reward_x), u256::from_u128(precision_factor)),
                    u256::from_u64(total_staked_token)
                )
            );
        } else {
            x_token_per_share_u256 = u256::from_u128(last_magnified_dividends_per_share_x);
        };

        if (reward_y > 0) {
            // acc_token_per_share = acc_token_per_share + (reward * precision_factor) / total_stake;
            y_token_per_share_u256 = u256::add(
                u256::from_u128(last_magnified_dividends_per_share_y),
                u256::div(
                    u256::mul(u256::from_u64(reward_y), u256::from_u128(precision_factor)),
                    u256::from_u64(total_staked_token)
                )
            );
        } else {
            y_token_per_share_u256 = u256::from_u128(last_magnified_dividends_per_share_y);
        };

        (u256::as_u128(x_token_per_share_u256), u256::as_u128(y_token_per_share_u256))
    }

    fun reward_debt(amount: u64, acc_token_per_share: u128, precision_factor: u128): u128 {
        // user.reward_debt = (user_info.amount * pool_info.acc_token_per_share) / pool_info.precision_factor;
        u256::as_u128(
            u256::div(
                u256::mul(
                    u256::from_u64(amount),
                    u256::from_u128(acc_token_per_share)
                ),
                u256::from_u128(precision_factor)
            )
        )
    }

    fun cal_pending_reward(amount: u64, reward_debt: u128, acc_token_per_share: u128, precision_factor: u128): u64 {
        // pending = (user_info::amount * pool_info.acc_token_per_share) / pool_info.precision_factor - user_info.reward_debt
        u256::as_u64(
            u256::sub(
                u256::div(
                    u256::mul(
                        u256::from_u64(amount),
                        u256::from_u128(acc_token_per_share)
                    ), u256::from_u128(precision_factor)
                ), u256::from_u128(reward_debt))
        )
    }

    public entry fun stake_tokens<X, Y>(
        sender: &signer,
        amount: u64
    ) acquires TokenPairRewardsPool, RewardsPoolUserInfo {
        let account_address = signer::address_of(sender);

        assert!(exists<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT), ERROR_POOL_NOT_CREATED);
        let pool_info = borrow_global_mut<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT);

        if (pool_info.is_x_staked) {
            if (!exists<RewardsPoolUserInfo<X, Y, X>>(account_address)) {
                move_to(sender, RewardsPoolUserInfo<X, Y, X> {
                    staked_tokens: coin::zero<X>(),
                    reward_debt_x: 0,
                    reward_debt_y: 0,
                    withdrawn_x: 0,
                    withdrawn_y: 0,
                })
            };

            let user_info = borrow_global_mut<RewardsPoolUserInfo<X, Y, X>>(account_address);

            if (coin::value(&mut user_info.staked_tokens) > 0) {
                // Calculate pending rewards
                let pending_reward_x = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_x, pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
                let pending_reward_y = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_y, pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);
                
                if (pending_reward_x > 0) {
                    // Check/register x and extract from pool
                    check_or_register_coin_store<X>(sender);
                    let x_out = coin::extract<X>(&mut pool_info.balance_x, pending_reward_x);
                    coin::deposit(signer::address_of(sender), x_out);
                };

                if (pending_reward_y > 0) {
                    // Check/register y and extract from pool
                    check_or_register_coin_store<Y>(sender);
                    let y_out = coin::extract<Y>(&mut pool_info.balance_y, pending_reward_y);
                    coin::deposit(signer::address_of(sender), y_out);
                };
            };

            if (amount > 0) {
                transfer_in<X>(&mut user_info.staked_tokens, sender, amount);
                pool_info.staked_tokens = pool_info.staked_tokens + amount;
            };

            //Calculate and update user corrections
            user_info.reward_debt_x = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            user_info.reward_debt_y = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);

        } else {
            if (!exists<RewardsPoolUserInfo<X, Y, Y>>(account_address)) {
                move_to(sender, RewardsPoolUserInfo<X, Y, Y> {
                    staked_tokens: coin::zero<Y>(),
                    reward_debt_x: 0,
                    reward_debt_y: 0,
                    withdrawn_x: 0,
                    withdrawn_y: 0,
                })
            };

            let user_info = borrow_global_mut<RewardsPoolUserInfo<X, Y, Y>>(account_address);

            if (coin::value(&mut user_info.staked_tokens) > 0) {
                // Calculate pending rewards
                let pending_reward_x = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_x, pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
                let pending_reward_y = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_y, pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);
                
                if (pending_reward_x > 0) {
                    // Check/register x and extract from pool
                    check_or_register_coin_store<X>(sender);
                    let x_out = coin::extract<X>(&mut pool_info.balance_x, pending_reward_x);
                    coin::deposit(signer::address_of(sender), x_out);
                };

                if (pending_reward_y > 0) {
                    // Check/register y and extract from pool
                    check_or_register_coin_store<Y>(sender);
                    let y_out = coin::extract<Y>(&mut pool_info.balance_y, pending_reward_y);
                    coin::deposit(signer::address_of(sender), y_out);
                };
            };

            if (amount > 0) {
                transfer_in<Y>(&mut user_info.staked_tokens, sender, amount);
                pool_info.staked_tokens = pool_info.staked_tokens + amount;
            };

            // Calculate and update user corrections
            user_info.reward_debt_x = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            user_info.reward_debt_y = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);

        };
    }

    public entry fun withdraw_tokens<X, Y>(
        sender: &signer,
        amount: u64
    ) acquires TokenPairRewardsPool, RewardsPoolUserInfo {
        let account_address = signer::address_of(sender);

        assert!(exists<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT), ERROR_POOL_NOT_CREATED);
        let pool_info = borrow_global_mut<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT);

        if (pool_info.is_x_staked) {
            assert!(exists<RewardsPoolUserInfo<X, Y, X>>(account_address), ERROR_NO_STAKE);
            let user_info = borrow_global_mut<RewardsPoolUserInfo<X, Y, X>>(account_address);
            assert!(coin::value<X>(&mut user_info.staked_tokens) >= amount, ERROR_INSUFFICIENT_BALANCE);

            // Calculate pending rewards
            let pending_reward_x = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_x, pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            let pending_reward_y = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_y, pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);
            
            if (pending_reward_x > 0) {
                // Check/register x and extract from pool
                check_or_register_coin_store<X>(sender);
                let x_out = coin::extract<X>(&mut pool_info.balance_x, pending_reward_x);
                coin::deposit(signer::address_of(sender), x_out);
            };

            if (pending_reward_y > 0) {
                // Check/register y and extract from pool
                check_or_register_coin_store<Y>(sender);
                let y_out = coin::extract<Y>(&mut pool_info.balance_y, pending_reward_y);
                coin::deposit(signer::address_of(sender), y_out);
            };

            // Tranfer staked tokens out
            if (amount > 0) {
                transfer_out<X>(&mut user_info.staked_tokens, sender, amount);
                pool_info.staked_tokens = pool_info.staked_tokens - amount;
            };

            //Calculate and update user corrections
            user_info.reward_debt_x = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            user_info.reward_debt_y = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);


        } else {
            assert!(exists<RewardsPoolUserInfo<X, Y, Y>>(account_address), ERROR_NO_STAKE);
            let user_info = borrow_global_mut<RewardsPoolUserInfo<X, Y, Y>>(account_address);
            assert!(coin::value<Y>(&mut user_info.staked_tokens) >= amount, ERROR_INSUFFICIENT_BALANCE);

            // Calculate pending rewards
            let pending_reward_x = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_x, pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            let pending_reward_y = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_y, pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);
            
            if (pending_reward_x > 0) {
                // Check/register x and extract from pool
                check_or_register_coin_store<X>(sender);
                let x_out = coin::extract<X>(&mut pool_info.balance_x, pending_reward_x);
                coin::deposit(signer::address_of(sender), x_out);
            };

            if (pending_reward_y > 0) {
                // Check/register y and extract from pool
                check_or_register_coin_store<Y>(sender);
                let y_out = coin::extract<Y>(&mut pool_info.balance_y, pending_reward_y);
                coin::deposit(signer::address_of(sender), y_out);
            };

            // Tranfer staked tokens out
            if (amount > 0) {
                transfer_out<Y>(&mut user_info.staked_tokens, sender, amount);
                pool_info.staked_tokens = pool_info.staked_tokens - amount;
            };

            //Calculate and update user corrections
            user_info.reward_debt_x = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            user_info.reward_debt_y = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);
        }
    }

    public entry fun claim_rewards<X, Y>(
        sender: &signer
    ) acquires TokenPairRewardsPool, RewardsPoolUserInfo {
        let account_address = signer::address_of(sender);

        assert!(exists<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT), ERROR_POOL_NOT_CREATED);
        let pool_info = borrow_global_mut<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT);

        if (pool_info.is_x_staked) {
            assert!(exists<RewardsPoolUserInfo<X, Y, X>>(account_address), ERROR_NO_STAKE);
            let user_info = borrow_global_mut<RewardsPoolUserInfo<X, Y, X>>(account_address);

            // Calculate pending rewards
            let pending_reward_x = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_x, pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            let pending_reward_y = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_y, pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);
            
            if (pending_reward_x > 0) {
                // Check/register x and extract from pool
                check_or_register_coin_store<X>(sender);
                let x_out = coin::extract<X>(&mut pool_info.balance_x, pending_reward_x);
                coin::deposit(signer::address_of(sender), x_out);
            };

            if (pending_reward_y > 0) {
                // Check/register y and extract from pool
                check_or_register_coin_store<Y>(sender);
                let y_out = coin::extract<Y>(&mut pool_info.balance_y, pending_reward_y);
                coin::deposit(signer::address_of(sender), y_out);
            };

            //Calculate and update user corrections
            user_info.reward_debt_x = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            user_info.reward_debt_y = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);
 
        } else {
            assert!(exists<RewardsPoolUserInfo<X, Y, Y>>(account_address), ERROR_NO_STAKE);
            let user_info = borrow_global_mut<RewardsPoolUserInfo<X, Y, Y>>(account_address);

            // Calculate pending rewards
            let pending_reward_x = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_x, pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            let pending_reward_y = cal_pending_reward(coin::value(&user_info.staked_tokens), user_info.reward_debt_y, pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);
            
            if (pending_reward_x > 0) {
                // Check/register x and extract from pool
                check_or_register_coin_store<X>(sender);
                let x_out = coin::extract<X>(&mut pool_info.balance_x, pending_reward_x);
                coin::deposit(signer::address_of(sender), x_out);
            };

            if (pending_reward_y > 0) {
                // Check/register y and extract from pool
                check_or_register_coin_store<Y>(sender);
                let y_out = coin::extract<Y>(&mut pool_info.balance_y, pending_reward_y);
                coin::deposit(signer::address_of(sender), y_out);
            };

            //Calculate and update user corrections
            user_info.reward_debt_x = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_x, pool_info.precision_factor);
            user_info.reward_debt_y = reward_debt(coin::value(&user_info.staked_tokens), pool_info.magnified_dividends_per_share_y, pool_info.precision_factor);
 
        };

   }

    fun transfer_in<CoinType>(own_coin: &mut coin::Coin<CoinType>, account: &signer, amount: u64) {
        let coin = coin::withdraw<CoinType>(account, amount);
        coin::merge(own_coin, coin);
    }

    fun transfer_out<CoinType>(own_coin: &mut coin::Coin<CoinType>, receiver: &signer, amount: u64) {
        check_or_register_coin_store<CoinType>(receiver);
        let extract_coin = coin::extract<CoinType>(own_coin, amount);
        coin::deposit<CoinType>(signer::address_of(receiver), extract_coin);
    }

    // Create the specified coin pair
    public(friend) fun create_pair<X, Y>(
        sender: &signer,
    ) acquires SwapInfo {
        assert!(!is_pair_created<X, Y>(), ERROR_ALREADY_INITIALIZED);

        let sender_addr = signer::address_of(sender);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        let resource_signer = account::create_signer_with_capability(&swap_info.signer_cap);

        let lp_name: string::String = string::utf8(b"BaptSwap-");
        let name_x = coin::symbol<X>();
        let name_y = coin::symbol<Y>();
        string::append(&mut lp_name, name_x);
        string::append_utf8(&mut lp_name, b"-");
        string::append(&mut lp_name, name_y);
        string::append_utf8(&mut lp_name, b"-LP");
        if (string::length(&lp_name) > MAX_COIN_NAME_LENGTH) {
            lp_name = string::utf8(b"BaptSwap LPs");
        };

        // now we init the LP token
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<LPToken<X, Y>>(
            &resource_signer,
            lp_name,
            string::utf8(b"BAPT-LP"),
            8,
            true
        );

        move_to<TokenPairReserve<X, Y>>(
            &resource_signer,
            TokenPairReserve {
                reserve_x: 0,
                reserve_y: 0,
                block_timestamp_last: 0
            }
        );

        move_to<TokenPairMetadata<X, Y>>(
            &resource_signer,
            TokenPairMetadata {
                creator: sender_addr,
                owner: ZERO_ACCOUNT,
                k_last: 0,
                liquidity_fee: 
                    LiquidityFee {
                        buy: 0,
                        sell: 0
                    },
                team_fee: 
                    TeamFee {
                        buy: 0,
                        sell: 0
                    },
                rewards_fee: 
                    RewardsFee {
                        buy: 0,
                        sell: 0
                    },
                balance_x: coin::zero<X>(),
                balance_y: coin::zero<Y>(),
                treasury_balance_x: coin::zero<X>(),
                treasury_balance_y: coin::zero<Y>(),
                team_balance_x: coin::zero<X>(),
                team_balance_y: coin::zero<Y>(),
                mint_cap,
                burn_cap,
                freeze_cap,
            }
        );

        move_to<PairEventHolder<X, Y>>(
            &resource_signer,
            PairEventHolder {
                add_liquidity: account::new_event_handle<AddLiquidityEvent<X, Y>>(&resource_signer),
                remove_liquidity: account::new_event_handle<RemoveLiquidityEvent<X, Y>>(&resource_signer),
                swap: account::new_event_handle<SwapEvent<X, Y>>(&resource_signer),
                change_fee: account::new_event_handle<FeeChangeEvent<X,Y>>(&resource_signer)
            }
        );

        // pair created event
        let token_x = type_info::type_name<X>();
        let token_y = type_info::type_name<Y>();

        event::emit_event<PairCreatedEvent>(
            &mut swap_info.pair_created,
            PairCreatedEvent {
                user: sender_addr,
                token_x,
                token_y
            }
        );


        // create LP CoinStore , which is needed as a lock for minimum_liquidity
        register_lp<X, Y>(&resource_signer);
    }

    public fun register_lp<X, Y>(sender: &signer) {
        coin::register<LPToken<X, Y>>(sender);
    }

    public fun is_pair_created<X, Y>(): bool {
        exists<TokenPairReserve<X, Y>>(RESOURCE_ACCOUNT)
    }

    public fun is_pool_created<X, Y>(): bool {
        exists<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT)
    }

    // Obtain the LP token balance of `addr`.
    // This method can only be used to check other users' balance.
    public fun lp_balance<X, Y>(addr: address): u64 {
        coin::balance<LPToken<X, Y>>(addr)
    }

    // Get the total supply of LP Tokens
    public fun total_lp_supply<X, Y>(): u128 {
        option::get_with_default(
            &coin::supply<LPToken<X, Y>>(),
            0u128
        )
    }

    // Get the current buy fees for a token pair
    public fun buy_token_fees<X, Y>(): (u128) acquires SwapInfo, TokenPairMetadata {
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        (
            metadata.liquidity_fee.buy + swap_info.treasury_fee + metadata.team_fee.buy + metadata.rewards_fee.buy
        )
    }

    // Get the current fees for a token pair
    public fun sell_token_fees<X, Y>(): (u128) acquires SwapInfo, TokenPairMetadata {
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        (
            metadata.liquidity_fee.sell + swap_info.treasury_fee + metadata.team_fee.sell + metadata.rewards_fee.sell
        )
    }

    // Get current accumulated fees for a token pair
    public fun token_fees_accumulated<X, Y>(): (u64, u64, u64, u64, u64, u64) acquires TokenPairMetadata, TokenPairRewardsPool {
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);

        let treasury_balance_x = coin::value<X>(&metadata.treasury_balance_x);
        let treasury_balance_y = coin::value<Y>(&metadata.treasury_balance_y);
        let team_balance_x = coin::value<X>(&metadata.team_balance_x);
        let team_balance_y = coin::value<Y>(&metadata.team_balance_y);
        let pool_balance_x = 0;
        let pool_balance_y = 0;

        if (is_pool_created<X, Y>()) {
            let pool = borrow_global_mut<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT);

            pool_balance_x = coin::value<X>(&pool.balance_x);
            pool_balance_y = coin::value<Y>(&pool.balance_y);
        };

        (treasury_balance_x, treasury_balance_y, team_balance_x, team_balance_y, pool_balance_x, pool_balance_y)
    }

    public fun token_rewards_pool_info<X, Y>(): (u64, u64, u64, u128, u128, u128, bool) acquires TokenPairRewardsPool {
        assert!(is_pool_created<X, Y>(), ERROR_POOL_NOT_CREATED);

        let pool = borrow_global_mut<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT);

        (pool.staked_tokens, coin::value(&pool.balance_x), coin::value(&pool.balance_y),
         pool.magnified_dividends_per_share_x, pool.magnified_dividends_per_share_y,
         pool.precision_factor, pool.is_x_staked)
    }

    // Get the current reserves of T0 and T1 with the latest updated timestamp
    public fun token_reserves<X, Y>(): (u64, u64, u64) acquires TokenPairReserve {
        let reserve = borrow_global<TokenPairReserve<X, Y>>(RESOURCE_ACCOUNT);
        (
            reserve.reserve_x,
            reserve.reserve_y,
            reserve.block_timestamp_last
        )
    }

    // The amount of balance currently in pools of the liquidity pair
    public fun token_balances<X, Y>(): (u64, u64) acquires TokenPairMetadata {
        let meta =
            borrow_global<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        (
            coin::value(&meta.balance_x),
            coin::value(&meta.balance_y)
        )
    }

    public fun check_or_register_coin_store<X>(sender: &signer) {
        if (!coin::is_account_registered<X>(signer::address_of(sender))) {
            coin::register<X>(sender);
        };
    }

    public fun admin(): address acquires SwapInfo {
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        swap_info.admin
    }

    public fun treasury_addr(): address acquires SwapInfo {
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        swap_info.treasury_addr
    }

    // ===================== Update functions ======================
    // Add more liquidity to token types. This method explicitly assumes the
    // min of both tokens are 0.
    public(friend) fun add_liquidity<X, Y>(
        sender: &signer,
        amount_x: u64,
        amount_y: u64
    ): (u64, u64, u64) acquires TokenPairReserve, TokenPairMetadata, PairEventHolder {
        let (a_x, a_y, coin_lp, coin_left_x, coin_left_y) = add_liquidity_direct(coin::withdraw<X>(sender, amount_x), coin::withdraw<Y>(sender, amount_y));
        let sender_addr = signer::address_of(sender);
        let lp_amount = coin::value(&coin_lp);
        assert!(lp_amount > 0, ERROR_INSUFFICIENT_LIQUIDITY);
        check_or_register_coin_store<LPToken<X, Y>>(sender);
        coin::deposit(sender_addr, coin_lp);
        coin::deposit(sender_addr, coin_left_x);
        coin::deposit(sender_addr, coin_left_y);

        let pair_event_holder = borrow_global_mut<PairEventHolder<X, Y>>(RESOURCE_ACCOUNT);
        event::emit_event<AddLiquidityEvent<X, Y>>(
            &mut pair_event_holder.add_liquidity,
            AddLiquidityEvent<X, Y> {
                user: sender_addr,
                amount_x: a_x,
                amount_y: a_y,
                liquidity: lp_amount,
            }
        );

        (a_x, a_y, lp_amount)
    }

    public(friend) fun add_swap_event<X, Y>(
        sender: &signer,
        amount_x_in: u64,
        amount_y_in: u64,
        amount_x_out: u64,
        amount_y_out: u64
    ) acquires PairEventHolder {
        let sender_addr = signer::address_of(sender);
        let pair_event_holder = borrow_global_mut<PairEventHolder<X, Y>>(RESOURCE_ACCOUNT);
        event::emit_event<SwapEvent<X, Y>>(
            &mut pair_event_holder.swap,
            SwapEvent<X, Y> {
                user: sender_addr,
                amount_x_in,
                amount_y_in,
                amount_x_out,
                amount_y_out
            }
        );
    }

    public(friend) fun add_swap_event_with_address<X, Y>(
        sender_addr: address,
        amount_x_in: u64,
        amount_y_in: u64,
        amount_x_out: u64,
        amount_y_out: u64
    ) acquires PairEventHolder {
        let pair_event_holder = borrow_global_mut<PairEventHolder<X, Y>>(RESOURCE_ACCOUNT);
        event::emit_event<SwapEvent<X, Y>>(
            &mut pair_event_holder.swap,
            SwapEvent<X, Y> {
                user: sender_addr,
                amount_x_in,
                amount_y_in,
                amount_x_out,
                amount_y_out
            }
        );
    }

    // Add more liquidity to token types. This method explicitly assumes the
    // min of both tokens are 0.
    fun add_liquidity_direct<X, Y>(
        x: coin::Coin<X>,
        y: coin::Coin<Y>,
    ): (u64, u64, coin::Coin<LPToken<X, Y>>, coin::Coin<X>, coin::Coin<Y>) acquires TokenPairReserve, TokenPairMetadata {
        let amount_x = coin::value(&x);
        let amount_y = coin::value(&y);
        let (reserve_x, reserve_y, _) = token_reserves<X, Y>();
        let (a_x, a_y) = if (reserve_x == 0 && reserve_y == 0) {
            (amount_x, amount_y)
        } else {
            let amount_y_optimal = swap_utils::quote(amount_x, reserve_x, reserve_y);
            if (amount_y_optimal <= amount_y) {
                (amount_x, amount_y_optimal)
            } else {
                let amount_x_optimal = swap_utils::quote(amount_y, reserve_y, reserve_x);
                assert!(amount_x_optimal <= amount_x, ERROR_INVALID_AMOUNT);
                (amount_x_optimal, amount_y)
            }
        };

        assert!(a_x <= amount_x, ERROR_INSUFFICIENT_AMOUNT);
        assert!(a_y <= amount_y, ERROR_INSUFFICIENT_AMOUNT);

        let left_x = coin::extract(&mut x, amount_x - a_x);
        let left_y = coin::extract(&mut y, amount_y - a_y);
        deposit_x<X, Y>(x);
        deposit_y<X, Y>(y);
        let (lp) = mint<X, Y>();
        (a_x, a_y, lp, left_x, left_y)
    }

    // Remove liquidity to token types.
    public(friend) fun remove_liquidity<X, Y>(
        sender: &signer,
        liquidity: u64,
    ): (u64, u64) acquires TokenPairMetadata, TokenPairReserve, PairEventHolder {
        let coins = coin::withdraw<LPToken<X, Y>>(sender, liquidity);
        let (coins_x, coins_y) = remove_liquidity_direct<X, Y>(coins);
        let amount_x = coin::value(&coins_x);
        let amount_y = coin::value(&coins_y);
        check_or_register_coin_store<X>(sender);
        check_or_register_coin_store<Y>(sender);
        let sender_addr = signer::address_of(sender);
        coin::deposit<X>(sender_addr, coins_x);
        coin::deposit<Y>(sender_addr, coins_y);
        // event
        let pair_event_holder = borrow_global_mut<PairEventHolder<X, Y>>(RESOURCE_ACCOUNT);
        event::emit_event<RemoveLiquidityEvent<X, Y>>(
            &mut pair_event_holder.remove_liquidity,
            RemoveLiquidityEvent<X, Y> {
                user: sender_addr,
                amount_x,
                amount_y,
                liquidity,
            }
        );
        (amount_x, amount_y)
    }

    // Remove liquidity to token types.
    fun remove_liquidity_direct<X, Y>(
        liquidity: coin::Coin<LPToken<X, Y>>,
    ): (coin::Coin<X>, coin::Coin<Y>) acquires TokenPairMetadata, TokenPairReserve {
        burn<X, Y>(liquidity)
    }

    // Swap X to Y, X is in and Y is out. This method assumes amount_out_min is 0
    public(friend) fun swap_exact_x_to_y<X, Y>(
        sender: &signer,
        amount_in: u64,
        to: address
    ): u64 acquires SwapInfo, TokenPairReserve, TokenPairMetadata, TokenPairRewardsPool {
        let coins = coin::withdraw<X>(sender, amount_in);
        let (coins_x_out, coins_y_out) = swap_exact_x_to_y_direct<X, Y>(coins);
        let amount_out = coin::value(&coins_y_out);
        check_or_register_coin_store<Y>(sender);
        coin::destroy_zero(coins_x_out); // or others ways to drop `coins_x_out`
        coin::deposit(to, coins_y_out);
        amount_out
    }

    // Swap Y to X, Y is in and X is out. This method assumes amount_out_min is 0
    public(friend) fun swap_exact_y_to_x<X, Y>(
        sender: &signer,
        amount_in: u64,
        to: address
    ): u64 acquires SwapInfo, TokenPairReserve, TokenPairMetadata, TokenPairRewardsPool {
        let coins = coin::withdraw<Y>(sender, amount_in);
        let (coins_x_out, coins_y_out) = swap_exact_y_to_x_direct<X, Y>(coins);
        let amount_out = coin::value(&coins_x_out);
        check_or_register_coin_store<X>(sender);
        coin::destroy_zero(coins_y_out); // or others ways to drop `coins_y_out`
        coin::deposit(to, coins_x_out);
        amount_out
    }

    // Swap X to Y, X is in and Y is out. This method assumes amount_out_min is 0
    public(friend) fun swap_exact_x_to_y_direct<X, Y>(
        coins_in: coin::Coin<X>
    ): (coin::Coin<X>, coin::Coin<Y>) acquires SwapInfo, TokenPairReserve, TokenPairMetadata, TokenPairRewardsPool {
        // Grab token pair metadata and swap info
        let total_fees = buy_token_fees<X, Y>() + sell_token_fees<X, Y>();
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);

        let amount_in = coin::value<X>(&coins_in);

        // Calculate extracted fees 
        // (buy liquidity, sell liquidity, buy team, sell team, buy rewards, sell rewards)
        
        // treasury
        let amount_to_treasury = swap_info.treasury_fee * (amount_in as u128);

        // Buy fees
        let buy_amount_to_team = metadata.team_fee.buy * (amount_in as u128);
        let buy_amount_to_rewards = metadata.rewards_fee.buy * (amount_in as u128);
        let buy_amount_to_liquidity = metadata.liquidity_fee.buy * (amount_in as u128);

        // Deposit into <X> balance
        coin::merge(&mut metadata.balance_x, coins_in);

        // Calculate amount out before fees
        let (rin, rout, _) = token_reserves<X, Y>();  
        let amount_out_before_sell_fee = swap_utils::get_amount_out(amount_in, rin, rout, total_fees);

        // Sell fees
        let sell_amount_to_team = metadata.team_fee.sell * (amount_out_before_sell_fee as u128);
        let sell_amount_to_rewards = metadata.rewards_fee.sell * (amount_out_before_sell_fee as u128);
        let sell_amount_to_liquidity = metadata.liquidity_fee.sell * (amount_out_before_sell_fee as u128);

        // Calculate amount out after fees
        let amount_out_after_sell_fees = (amount_out_before_sell_fee as u128) - sell_amount_to_team - sell_amount_to_rewards - sell_amount_to_liquidity; 
        // assert amount_out_after_sell_fees > 0
        assert!(amount_out_after_sell_fees > 0, 1);
        let (coins_x_out, coins_y_out) = internal_swap<X, Y>(0, (amount_out_after_sell_fees as u64));

        // Grab token pair metadata
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);

        // Extract treasury fee <X> and deposit to treasury
        let treasury_coins = coin::extract(&mut metadata.balance_x, (amount_to_treasury as u64));
        coin::merge(&mut metadata.treasury_balance_x, treasury_coins);
        // TODO: add func that if it reaches a value it will swap to apt?

        // Extract buy team fees and deposit to team balanace <X>
        if (metadata.team_fee.buy > 0) {     
            let team_coins = coin::extract(&mut metadata.balance_x, (buy_amount_to_team as u64));
            coin::merge(&mut metadata.team_balance_x, team_coins);
        };

        // Extract buy rewards fee and deposit to rewards pool <X>
        if (metadata.rewards_fee.buy > 0) {
            let rewards_pool = borrow_global_mut<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT);
            let rewards_coins = coin::extract(&mut metadata.balance_x, (buy_amount_to_rewards as u64));

            update_pool<X,Y>(rewards_pool, coin::value(&rewards_coins), 0);

            coin::merge(&mut rewards_pool.balance_x, rewards_coins);
        };

        // Extract buy liquidity fee and deposit to liquidity pool <X> owner
        if (metadata.liquidity_fee.buy > 0) {
            let liquidity_coins = coin::extract(&mut metadata.balance_x, (buy_amount_to_liquidity as u64));
            coin::merge(&mut metadata.balance_x, liquidity_coins);
        };

        // Extract sell team fees and deposit to team balanace <Y>
        if (metadata.team_fee.sell > 0) {
            let team_coins = coin::extract(&mut metadata.balance_y, (sell_amount_to_team as u64));
            coin::merge(&mut metadata.team_balance_y, team_coins);
        };

        // Extract sell rewards fee and deposit to rewards pool <Y>
        if (metadata.rewards_fee.sell > 0) {
            let rewards_pool = borrow_global_mut<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT);
            let rewards_coins = coin::extract(&mut metadata.balance_y, (sell_amount_to_rewards as u64));

            update_pool<X,Y>(rewards_pool, 0, coin::value(&rewards_coins));

            coin::merge(&mut rewards_pool.balance_y, rewards_coins);
        };

        // Extract sell liquidity fee and deposit to liquidity pool <Y> owner
        if (metadata.liquidity_fee.sell > 0) {
            let liquidity_coins = coin::extract(&mut metadata.balance_y, (sell_amount_to_liquidity as u64));
            coin::merge(&mut metadata.balance_y, liquidity_coins);
        };

        // TODO
        // Update reserves
        let reserves = borrow_global_mut<TokenPairReserve<X, Y>>(RESOURCE_ACCOUNT);
        let (balance_x, balance_y) = token_balances<X, Y>();
        update(balance_x, balance_y, reserves);

        assert!(coin::value<X>(&coins_x_out) == 0, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
        (coins_x_out, coins_y_out)
    }

    // Swap Y to X, Y is in and X is out. This method assumes amount_out_min is 0
    fun swap_exact_y_to_x_direct<X, Y>(
        coins_in: coin::Coin<Y>
    ): (coin::Coin<X>, coin::Coin<Y>) acquires SwapInfo, TokenPairReserve, TokenPairMetadata, TokenPairRewardsPool {
        // Grab token pair metadata and swap info
        let total_fees = buy_token_fees<X, Y>() + sell_token_fees<X, Y>();
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);

        let amount_in = coin::value<Y>(&coins_in);

        // Calculate extracted fees
        // (buy liquidity, sell liquidity, buy team, sell team, buy rewards, sell rewards)

        // treasury
        let amount_to_treasury = swap_info.treasury_fee * (amount_in as u128);

        // Buy fees
        let buy_amount_to_team = metadata.team_fee.buy * (amount_in as u128);
        let buy_amount_to_rewards = metadata.rewards_fee.buy * (amount_in as u128);
        let buy_amount_to_liquidity = metadata.liquidity_fee.buy * (amount_in as u128);

        // Deposit into <Y> balance
        coin::merge(&mut metadata.balance_y, coins_in);

        // Calculate amount out before fees
        let (rin, rout, _) = token_reserves<X, Y>();
        let amount_out_before_sell_fee = swap_utils::get_amount_out(amount_in, rout, rin, total_fees);

        // Sell fees
        let sell_amount_to_team = metadata.team_fee.sell * (amount_out_before_sell_fee as u128);
        let sell_amount_to_rewards = metadata.rewards_fee.sell * (amount_out_before_sell_fee as u128);
        let sell_amount_to_liquidity = metadata.liquidity_fee.sell * (amount_out_before_sell_fee as u128);

        // Calculate amount out after fees
        let amount_out_after_sell_fees = (amount_out_before_sell_fee as u128) - sell_amount_to_team - sell_amount_to_rewards - sell_amount_to_liquidity;
        // assert amount_out_after_sell_fees > 0
        assert!(amount_out_after_sell_fees > 0, 1);
        let (coins_x_out, coins_y_out) = internal_swap<X, Y>((amount_out_after_sell_fees as u64), 0);

        // Grab token pair metadata
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);

        // Extract treasury fee <Y> and deposit to treasury
        let treasury_coins = coin::extract(&mut metadata.balance_y, (amount_to_treasury as u64));
        coin::merge(&mut metadata.treasury_balance_y, treasury_coins);

        // Extract buy team fees and deposit to team balanace <Y>
        if (metadata.team_fee.buy > 0) {
            let team_coins = coin::extract(&mut metadata.balance_y, (buy_amount_to_team as u64));
            coin::merge(&mut metadata.team_balance_y, team_coins);
        };

        // Extract buy rewards fee and deposit to rewards pool <Y>
        if (metadata.rewards_fee.buy > 0) {
            let rewards_pool = borrow_global_mut<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT);
            let rewards_coins = coin::extract(&mut metadata.balance_y, (buy_amount_to_rewards as u64));

            update_pool<X,Y>(rewards_pool, 0, coin::value(&rewards_coins));

            coin::merge(&mut rewards_pool.balance_y, rewards_coins);
        };

        // Extract buy liquidity fee and deposit to liquidity pool <Y> owner
        if (metadata.liquidity_fee.buy > 0) {
            let liquidity_coins = coin::extract(&mut metadata.balance_y, (buy_amount_to_liquidity as u64));
            coin::merge(&mut metadata.balance_y, liquidity_coins);
        };

        // Extract sell team fees and deposit to team balanace <X>
        if (metadata.team_fee.sell > 0) {
            let team_coins = coin::extract(&mut metadata.balance_x, (sell_amount_to_team as u64));
            coin::merge(&mut metadata.team_balance_x, team_coins);
        };

        // Extract sell rewards fee and deposit to rewards pool <X>
        if (metadata.rewards_fee.sell > 0) {
            let rewards_pool = borrow_global_mut<TokenPairRewardsPool<X, Y>>(RESOURCE_ACCOUNT);
            let rewards_coins = coin::extract(&mut metadata.balance_x, (sell_amount_to_rewards as u64));

            update_pool<X,Y>(rewards_pool, coin::value(&rewards_coins), 0);

            coin::merge(&mut rewards_pool.balance_x, rewards_coins);
        };

        // Extract sell liquidity fee and deposit to liquidity pool <X> owner
        if (metadata.liquidity_fee.sell > 0) {
            let liquidity_coins = coin::extract(&mut metadata.balance_x, (sell_amount_to_liquidity as u64));
            coin::merge(&mut metadata.balance_x, liquidity_coins);
        };

        // TODO
        // Update reserves
        let reserves = borrow_global_mut<TokenPairReserve<X, Y>>(RESOURCE_ACCOUNT);
        let (balance_x, balance_y) = token_balances<X, Y>();
        update(balance_x, balance_y, reserves);

        assert!(coin::value<Y>(&coins_y_out) == 0, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
        (coins_x_out, coins_y_out)
    }

    // TODO: swap_x_to_exact_y
    
    // TODO: swap_y_to_exact_x

    // TODO: swap_x_to_exact_y_direct

    // TODO: swap_y_to_exact_x_direct

    // --------------
    // View Functions
    // --------------

    #[view]
    // get threshold; callable by anyone
    public fun get_threshold<FeeThreshold>(): u64 acquires DexFeeThreshold, IndividualTokenFeeThreshold {
        if (type_info::type_of<FeeThreshold>() == type_info::type_of<DexFeeThreshold>()) {
            let threshold = borrow_global_mut<DexFeeThreshold>(RESOURCE_ACCOUNT);
            (calculate_fee(threshold.numenator, threshold.denominator))
        } else if (type_info::type_of<FeeThreshold>() == type_info::type_of<IndividualTokenFeeThreshold>()) {
            let threshold = borrow_global_mut<IndividualTokenFeeThreshold>(RESOURCE_ACCOUNT);
            (calculate_fee(threshold.numenator, threshold.denominator))
        } else {
           0
        }
    }

    #[view]
    // get threshold as u128; callable by anyone
    public fun get_threshold_as_u128<FeeThreshold>(): u128 acquires DexFeeThreshold, IndividualTokenFeeThreshold {
        (get_threshold<FeeThreshold>() as u128)
    }
    
    // ------------------
    // Internal functions
    // ------------------

    // fees free swap, used in treasury
    fun internal_swap<X, Y>(
        amount_x_out: u64,
        amount_y_out: u64
    ): (coin::Coin<X>, coin::Coin<Y>) acquires TokenPairReserve, TokenPairMetadata {
        assert!(amount_x_out > 0 || amount_y_out > 0, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);

        let reserves = borrow_global_mut<TokenPairReserve<X, Y>>(RESOURCE_ACCOUNT);
        assert!(amount_x_out < reserves.reserve_x && amount_y_out < reserves.reserve_y, ERROR_INSUFFICIENT_LIQUIDITY);

        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);

        let coins_x_out = coin::zero<X>();
        let coins_y_out = coin::zero<Y>();
        if (amount_x_out > 0) coin::merge(&mut coins_x_out, extract_x(amount_x_out, metadata));
        if (amount_y_out > 0) coin::merge(&mut coins_y_out, extract_y(amount_y_out, metadata));
        let (balance_x, balance_y) = token_balances<X, Y>();

        let amount_x_in = if (balance_x > reserves.reserve_x - amount_x_out) {
        balance_x - (reserves.reserve_x - amount_x_out)
        } else { 0 };
        let amount_y_in = if (balance_y > reserves.reserve_y - amount_y_out) {
        balance_y - (reserves.reserve_y - amount_y_out)
        } else { 0 };

        assert!(amount_x_in > 0 || amount_y_in > 0, ERROR_INSUFFICIENT_INPUT_AMOUNT);

        update(balance_x, balance_y, reserves);

        (coins_x_out, coins_y_out)
    }

    // Mint LP Token.
    // This low-level function should be called from a contract which performs important safety checks
    fun mint<X, Y>(): (coin::Coin<LPToken<X, Y>>) acquires TokenPairReserve, TokenPairMetadata {
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        let (balance_x, balance_y) = (coin::value(&metadata.balance_x), coin::value(&metadata.balance_y));
        let reserves = borrow_global_mut<TokenPairReserve<X, Y>>(RESOURCE_ACCOUNT);
        let amount_x = (balance_x as u128) - (reserves.reserve_x as u128);
        let amount_y = (balance_y as u128) - (reserves.reserve_y as u128);

        //let fee_amount = mint_fee<X, Y>(reserves.reserve_x, reserves.reserve_y, metadata);

        //Need to add fee amount which have not been mint.
        let total_supply = total_lp_supply<X, Y>();
        let liquidity = if (total_supply == 0u128) {
            let sqrt = math::sqrt(amount_x * amount_y);
            assert!(sqrt > MINIMUM_LIQUIDITY, ERROR_INSUFFICIENT_LIQUIDITY_MINTED);
            let l = sqrt - MINIMUM_LIQUIDITY;
            // permanently lock the first MINIMUM_LIQUIDITY tokens
            mint_lp_to<X, Y>(RESOURCE_ACCOUNT, (MINIMUM_LIQUIDITY as u64), &metadata.mint_cap);
            l
        } else {
            let liquidity = math::min(amount_x * total_supply / (reserves.reserve_x as u128), amount_y * total_supply / (reserves.reserve_y as u128));
            assert!(liquidity > 0u128, ERROR_INSUFFICIENT_LIQUIDITY_MINTED);
            liquidity
        };


        let lp = mint_lp<X, Y>((liquidity as u64), &metadata.mint_cap);

        update<X, Y>(balance_x, balance_y, reserves);

        metadata.k_last = (reserves.reserve_x as u128) * (reserves.reserve_y as u128);

        (lp)
    }

    fun burn<X, Y>(lp_tokens: coin::Coin<LPToken<X, Y>>): (coin::Coin<X>, coin::Coin<Y>) acquires TokenPairMetadata, TokenPairReserve {
        let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        let (balance_x, balance_y) = (coin::value(&metadata.balance_x), coin::value(&metadata.balance_y));
        let reserves = borrow_global_mut<TokenPairReserve<X, Y>>(RESOURCE_ACCOUNT);
        let liquidity = coin::value(&lp_tokens);

        //let fee_amount = mint_fee<X, Y>(reserves.reserve_x, reserves.reserve_y, metadata);

        //Need to add fee amount which have not been mint.
        let total_lp_supply = total_lp_supply<X, Y>();
        let amount_x = ((balance_x as u128) * (liquidity as u128) / (total_lp_supply as u128) as u64);
        let amount_y = ((balance_y as u128) * (liquidity as u128) / (total_lp_supply as u128) as u64);
        assert!(amount_x > 0 && amount_y > 0, ERROR_INSUFFICIENT_LIQUIDITY_BURNED);

        coin::burn<LPToken<X, Y>>(lp_tokens, &metadata.burn_cap);

        let w_x = extract_x((amount_x as u64), metadata);
        let w_y = extract_y((amount_y as u64), metadata);

        update(coin::value(&metadata.balance_x), coin::value(&metadata.balance_y), reserves);

        metadata.k_last = (reserves.reserve_x as u128) * (reserves.reserve_y as u128);

        (w_x, w_y)
    }

    fun update<X, Y>(balance_x: u64, balance_y: u64, reserve: &mut TokenPairReserve<X, Y>) {
        let block_timestamp = timestamp::now_seconds();

        reserve.reserve_x = balance_x;
        reserve.reserve_y = balance_y;
        reserve.block_timestamp_last = block_timestamp;
    }

    // Mint LP Tokens to account
    fun mint_lp_to<X, Y>(
        to: address,
        amount: u64,
        mint_cap: &coin::MintCapability<LPToken<X, Y>>
    ) {
        let coins = coin::mint<LPToken<X, Y>>(amount, mint_cap);
        coin::deposit(to, coins);
    }

    // Mint LP Tokens to account
    fun mint_lp<X, Y>(amount: u64, mint_cap: &coin::MintCapability<LPToken<X, Y>>): coin::Coin<LPToken<X, Y>> {
        coin::mint<LPToken<X, Y>>(amount, mint_cap)
    }

    fun deposit_x<X, Y>(amount: coin::Coin<X>) acquires TokenPairMetadata {
        let metadata =
            borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        
        coin::merge(&mut metadata.balance_x, amount);
    }

    fun deposit_y<X, Y>(amount: coin::Coin<Y>) acquires TokenPairMetadata {
        let metadata =
            borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);

        coin::merge(&mut metadata.balance_y, amount);
    }

    // Extract `amount` from this contract
    fun extract_x<X, Y>(amount: u64, metadata: &mut TokenPairMetadata<X, Y>): coin::Coin<X> {
        assert!(coin::value<X>(&metadata.balance_x) > amount, ERROR_INSUFFICIENT_AMOUNT);
        coin::extract(&mut metadata.balance_x, amount)
    }

    // Extract `amount` from this contract
    fun extract_y<X, Y>(amount: u64, metadata: &mut TokenPairMetadata<X, Y>): coin::Coin<Y> {
        assert!(coin::value<Y>(&metadata.balance_y) > amount, ERROR_INSUFFICIENT_AMOUNT);
        coin::extract(&mut metadata.balance_y, amount)
    }

    // --------
    // Mutators
    // --------

    // Thresholds

    // change threshold; callable only by dex owner
    public entry fun set_fee_threshold<FeeThreshold>(
        signer_ref: &signer,
        new_numenator: u64,
        new_denominator: u64
    ) acquires DexFeeThreshold, IndividualTokenFeeThreshold, SwapInfo {
        let signer_addr = signer::address_of(signer_ref);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        assert!(signer_addr == swap_info.admin, ERROR_ONLY_ADMIN);
        let resource_signer = account::create_signer_with_capability(&swap_info.signer_cap);
        // based on fee threshold type, set new threshold
        if (type_info::type_of<FeeThreshold>() == type_info::type_of<DexFeeThreshold>()) {
            // borrow DexFeeThreshold resource and set new fee
            let dex_threshold = borrow_global_mut<DexFeeThreshold>(RESOURCE_ACCOUNT);
            // assert new fees does not exceed the limit
            assert!(
                calculate_fee(MAX_DEX_FEE_THRESHOLD_NUMERATOR, MAX_DEX_FEE_THRESHOLD_DENOMINATOR)
                >= calculate_fee(new_numenator, new_denominator),
                1
            );
            // set new fees
            dex_threshold.numenator = new_numenator;
            dex_threshold.denominator = new_denominator;
        } else if (type_info::type_of<FeeThreshold>() == type_info::type_of<IndividualTokenFeeThreshold>()) {
            // borrow IndividualTokenFeeThreshold resource and set new fee
            let individual_threshold = borrow_global_mut<IndividualTokenFeeThreshold>(RESOURCE_ACCOUNT);
            // assert new fees does not exceed the limit
            assert!(
                calculate_fee(MAX_INDIVIDUAL_TOKEN_FEE_THRESHOLD_NUMERATOR, MAX_INDIVIDUAL_TOKEN_FEE_THRESHOLD_DENOMINATOR)
                >= calculate_fee(new_numenator, new_denominator),
                1
            );
            // set new fees
            individual_threshold.numenator = new_numenator;
            individual_threshold.denominator = new_denominator;
        } else {
            assert!(false, 1);
        }
    }

    // Swap Info

    // Change treasury address; callable only by dex owner.
    public entry fun set_treasury_address<CoinType>(signer_ref: &signer, new_treasury_address: address) acquires SwapInfo {
        let signer_addr = signer::address_of(signer_ref);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        assert!(signer_addr == swap_info.admin, ERROR_ONLY_ADMIN);
        // assert the new treasury address have CoinType registered 
        assert!(coin::is_account_registered<CoinType>(new_treasury_address), 1);
        swap_info.treasury_addr = new_treasury_address;
    }

    // Change admin address; callable only by dex owner.
    public entry fun set_admin_address(signer_ref: &signer, new_admin_address: address) acquires SwapInfo {
        let signer_addr = signer::address_of(signer_ref);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        assert!(signer_addr == swap_info.admin, ERROR_ONLY_ADMIN);
        swap_info.admin = new_admin_address;
    }

    // change treasury fee; callable by admin
    public entry fun set_treasury_fee(signer_ref: &signer, new_treasury_fee: u128) acquires SwapInfo, DexFeeThreshold, IndividualTokenFeeThreshold {
        let signer_addr = signer::address_of(signer_ref);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        assert!(signer_addr == swap_info.admin, ERROR_ONLY_ADMIN);
        // assert treasury fee does not exceed dex threshold
        assert!(new_treasury_fee <= get_threshold_as_u128<DexFeeThreshold>(), ERROR_EXCESSIVE_FEE);
        swap_info.treasury_fee = new_treasury_fee;
    }

    // Token Pair

    // Change token pair owner; callable only by LP owner.
    public entry fun set_token_pair_owner<X, Y>(sender: &signer, new_owner: address) acquires TokenPairMetadata {
        if (swap_utils::sort_token_type<X, Y>()) {
            let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);            
            // Set new owner
            metadata.owner = new_owner;
        } else {
            let metadata = borrow_global_mut<TokenPairMetadata<Y, X>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.creator, ERROR_NOT_OWNER);
            // Set new owner
            metadata.owner = new_owner;
        }
    }

    // Change buy liquidity fee; callable by LP owner
    public entry fun set_buy_liquidity_fee<X, Y>(sender: &signer, new_buy_liquidity_fee: u128) acquires TokenPairMetadata, IndividualTokenFeeThreshold, DexFeeThreshold {
        if (swap_utils::sort_token_type<X, Y>()) {
            let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_buy_liquidity_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.liquidity_fee.buy = new_buy_liquidity_fee;
        } else {
            let metadata = borrow_global_mut<TokenPairMetadata<Y, X>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_buy_liquidity_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.liquidity_fee.buy = new_buy_liquidity_fee;
        }
    }

    // Change sell liquidity fee; callable by LP owner
    public entry fun set_sell_liquidity_fee<X, Y>(sender: &signer, new_sell_liquidity_fee: u128) acquires TokenPairMetadata, IndividualTokenFeeThreshold, DexFeeThreshold {
        if (swap_utils::sort_token_type<X, Y>()) {
            let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_sell_liquidity_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.liquidity_fee.sell = new_sell_liquidity_fee;
        } else {
            let metadata = borrow_global_mut<TokenPairMetadata<Y, X>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_sell_liquidity_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.liquidity_fee.sell = new_sell_liquidity_fee;
        }
    }

    // Change buy team fee; callable by LP owner
    public entry fun set_buy_team_fee<X, Y>(sender: &signer, new_buy_team_fee: u128) acquires TokenPairMetadata, IndividualTokenFeeThreshold, DexFeeThreshold {
        if (swap_utils::sort_token_type<X, Y>()) {
            let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_buy_team_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.team_fee.buy = new_buy_team_fee;
        } else {
            let metadata = borrow_global_mut<TokenPairMetadata<Y, X>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_buy_team_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.team_fee.buy = new_buy_team_fee;
        }
    }

    // Change sell team fee; callable by LP owner
    public entry fun set_sell_team_fee<X, Y>(sender: &signer, new_sell_team_fee: u128) acquires TokenPairMetadata, IndividualTokenFeeThreshold, DexFeeThreshold {
        if (swap_utils::sort_token_type<X, Y>()) {
            let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_sell_team_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.team_fee.sell = new_sell_team_fee;
        } else {
            let metadata = borrow_global_mut<TokenPairMetadata<Y, X>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_sell_team_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.team_fee.sell = new_sell_team_fee;
        }
    }

    // Change buy rewards fee; callable by LP owner
    public entry fun set_buy_rewards_fee<X, Y>(sender: &signer, new_buy_rewards_fee: u128) acquires TokenPairMetadata, IndividualTokenFeeThreshold, DexFeeThreshold {
        if (swap_utils::sort_token_type<X, Y>()) {
            let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_buy_rewards_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.rewards_fee.buy = new_buy_rewards_fee;
        } else {
            let metadata = borrow_global_mut<TokenPairMetadata<Y, X>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_buy_rewards_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.rewards_fee.buy = new_buy_rewards_fee;
        }
    }

    // Change sell rewards fee; callable by LP owner
    public entry fun set_sell_rewards_fee<X, Y>(sender: &signer, new_sell_rewards_fee: u128) acquires TokenPairMetadata, IndividualTokenFeeThreshold, DexFeeThreshold {
        if (swap_utils::sort_token_type<X, Y>()) {
            let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_sell_rewards_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.rewards_fee.sell = new_sell_rewards_fee;
        } else {
            let metadata = borrow_global_mut<TokenPairMetadata<Y, X>>(RESOURCE_ACCOUNT);
            let sender_addr = signer::address_of(sender);
            assert!(sender_addr == metadata.owner, ERROR_NOT_OWNER);
            // assert new fees does not exceed the limit
            assert!(new_sell_rewards_fee <= get_threshold_as_u128<IndividualTokenFeeThreshold>(), ERROR_EXCESSIVE_FEE);
            // Set new fees
            metadata.rewards_fee.sell = new_sell_rewards_fee;
        }
    }

    // ------------
    // Unit testing
    // ------------

    #[test_only]
    public fun initialize(sender: &signer) acquires SwapInfo {
        init_module(sender);
    }
}
