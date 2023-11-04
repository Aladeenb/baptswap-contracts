
<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2"></a>

# Module `0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096::swap_v2`



-  [Resource `TokenInfo`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenInfo)
-  [Resource `LPToken`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_LPToken)
-  [Resource `TokenPairMetadata`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairMetadata)
-  [Resource `TokenPairReserve`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairReserve)
-  [Resource `TokenPairRewardsPool`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairRewardsPool)
-  [Resource `RewardsPoolUserInfo`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_RewardsPoolUserInfo)
-  [Resource `SwapInfo`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_SwapInfo)
-  [Struct `PairCreatedEvent`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_PairCreatedEvent)
-  [Resource `PairEventHolder`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_PairEventHolder)
-  [Struct `AddLiquidityEvent`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_AddLiquidityEvent)
-  [Struct `RemoveLiquidityEvent`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_RemoveLiquidityEvent)
-  [Struct `SwapEvent`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_SwapEvent)
-  [Struct `FeeChangeEvent`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_FeeChangeEvent)
-  [Constants](#@Constants_0)
-  [Function `init_individual_token`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_init_individual_token)
-  [Function `init_rewards_pool`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_init_rewards_pool)
-  [Function `add_liquidity`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_add_liquidity)
-  [Function `remove_liquidity`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_remove_liquidity)
-  [Function `add_swap_event`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_add_swap_event)
-  [Function `add_swap_event_with_address`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_add_swap_event_with_address)
-  [Function `stake_tokens`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_stake_tokens)
-  [Function `withdraw_tokens`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_withdraw_tokens)
-  [Function `claim_rewards`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_claim_rewards)
-  [Function `set_admin`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_admin)
-  [Function `set_fee_to`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_fee_to)
-  [Function `set_token_pair_owner`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_token_pair_owner)
-  [Function `withdraw_team_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_withdraw_team_fee)
-  [Function `register_pair`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_register_pair)
-  [Function `toggle_all_individual_token_fees`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_all_individual_token_fees)
-  [Function `toggle_individual_token_liquidity_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_individual_token_liquidity_fee)
-  [Function `toggle_individual_token_team_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_individual_token_team_fee)
-  [Function `toggle_individual_token_rewards_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_individual_token_rewards_fee)
-  [Function `create_pair`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_create_pair)
-  [Function `swap_exact_x_to_y`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_x_to_y)
-  [Function `swap_exact_x_to_y_direct`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_x_to_y_direct)
-  [Function `swap_x_to_exact_y`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_x_to_exact_y)
-  [Function `swap_x_to_exact_y_direct`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_x_to_exact_y_direct)
-  [Function `swap_exact_y_to_x`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_y_to_x)
-  [Function `swap_y_to_exact_x`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_y_to_exact_x)
-  [Function `swap_y_to_exact_x_direct`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_y_to_exact_x_direct)
-  [Function `swap_exact_y_to_x_direct`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_y_to_x_direct)
-  [Function `get_dex_liquidity_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_dex_liquidity_fee)
-  [Function `get_dex_treasury_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_dex_treasury_fee)
-  [Function `get_individual_token_liquidity_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_individual_token_liquidity_fee)
-  [Function `get_individual_token_team_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_individual_token_team_fee)
-  [Function `get_individual_token_rewards_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_individual_token_rewards_fee)
-  [Function `is_pair_created`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_is_pair_created)
-  [Function `is_pool_created`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_is_pool_created)
-  [Function `total_lp_supply`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_total_lp_supply)
-  [Function `token_fees`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_fees)
-  [Function `token_rewards_pool_info`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_rewards_pool_info)
-  [Function `token_reserves`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_reserves)
-  [Function `token_balances`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_balances)
-  [Function `admin`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_admin)
-  [Function `fee_to`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_fee_to)
-  [Function `lp_balance`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_lp_balance)
-  [Function `check_or_register_coin_store`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_check_or_register_coin_store)
-  [Function `set_dex_liquidity_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_dex_liquidity_fee)
-  [Function `ser_dex_treasury_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ser_dex_treasury_fee)
-  [Function `set_individual_token_liquidity_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_individual_token_liquidity_fee)
-  [Function `set_individual_token_team_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_individual_token_team_fee)
-  [Function `set_individual_token_rewards_fee`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_individual_token_rewards_fee)
-  [Function `get_reserve`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_reserve)
-  [Function `register_lp`](#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_register_lp)


<pre><code><b>use</b> <a href="">0x1::account</a>;
<b>use</b> <a href="">0x1::aptos_coin</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::resource_account</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="">0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096::math</a>;
<b>use</b> <a href="">0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096::swap_utils</a>;
<b>use</b> <a href="">0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096::u256</a>;
<b>use</b> <a href="">0x97c8aca6082f2ef7a0046c72eb81ebf203ca23086baf15557579570c86a89fd3::Deployer</a>;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenInfo"></a>

## Resource `TokenInfo`

-------
Structs
-------
used to store the token owner and the token fee; needed for Individual token fees


<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenInfo">TokenInfo</a>&lt;CoinType&gt; <b>has</b> <b>copy</b>, drop, store, key
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_LPToken"></a>

## Resource `LPToken`

The LP Token type


<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_LPToken">LPToken</a>&lt;X, Y&gt; <b>has</b> key
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairMetadata"></a>

## Resource `TokenPairMetadata`

Stores the metadata required for the token pairs


<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt; <b>has</b> key
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairReserve"></a>

## Resource `TokenPairReserve`

Stores the reservation info required for the token pairs


<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairReserve">TokenPairReserve</a>&lt;X, Y&gt; <b>has</b> key
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairRewardsPool"></a>

## Resource `TokenPairRewardsPool`

Stores the rewards pool info for token pairs


<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairRewardsPool">TokenPairRewardsPool</a>&lt;X, Y&gt; <b>has</b> key
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_RewardsPoolUserInfo"></a>

## Resource `RewardsPoolUserInfo`



<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_RewardsPoolUserInfo">RewardsPoolUserInfo</a>&lt;X, Y, StakeToken&gt; <b>has</b> store, key
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_SwapInfo"></a>

## Resource `SwapInfo`

Global storage for swap info


<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_SwapInfo">SwapInfo</a> <b>has</b> key
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_PairCreatedEvent"></a>

## Struct `PairCreatedEvent`

------
Events
------


<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_PairCreatedEvent">PairCreatedEvent</a> <b>has</b> drop, store
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_PairEventHolder"></a>

## Resource `PairEventHolder`



<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_PairEventHolder">PairEventHolder</a>&lt;X, Y&gt; <b>has</b> key
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_AddLiquidityEvent"></a>

## Struct `AddLiquidityEvent`



<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_AddLiquidityEvent">AddLiquidityEvent</a>&lt;X, Y&gt; <b>has</b> drop, store
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_RemoveLiquidityEvent"></a>

## Struct `RemoveLiquidityEvent`



<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_RemoveLiquidityEvent">RemoveLiquidityEvent</a>&lt;X, Y&gt; <b>has</b> drop, store
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_SwapEvent"></a>

## Struct `SwapEvent`



<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_SwapEvent">SwapEvent</a>&lt;X, Y&gt; <b>has</b> drop, store
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_FeeChangeEvent"></a>

## Struct `FeeChangeEvent`



<pre><code><b>struct</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_FeeChangeEvent">FeeChangeEvent</a>&lt;X, Y&gt; <b>has</b> drop, store
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_MAX_U128"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_MAX_U128">MAX_U128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_MAX_COIN_NAME_LENGTH"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_MAX_COIN_NAME_LENGTH">MAX_COIN_NAME_LENGTH</a>: u64 = 32;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_AMOUNT"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_AMOUNT">ERROR_INSUFFICIENT_AMOUNT</a>: u64 = 6;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_INPUT_AMOUNT"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_INPUT_AMOUNT">ERROR_INSUFFICIENT_INPUT_AMOUNT</a>: u64 = 14;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_LIQUIDITY"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_LIQUIDITY">ERROR_INSUFFICIENT_LIQUIDITY</a>: u64 = 7;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_DEFAULT_ADMIN"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_DEFAULT_ADMIN">DEFAULT_ADMIN</a>: <b>address</b> = 0xefb4da60354e5b2f419ee71fb277677a7c1b8cb1a3d4bbf0455d561ebf199eef;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_DEV"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_DEV">DEV</a>: <b>address</b> = 0x97c8aca6082f2ef7a0046c72eb81ebf203ca23086baf15557579570c86a89fd3;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_DEX_FEE_THRESHOLD_NUMERATOR"></a>

Max DEX fee: 0.9%; (90 / (100*100))


<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_DEX_FEE_THRESHOLD_NUMERATOR">DEX_FEE_THRESHOLD_NUMERATOR</a>: u128 = 90;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_ALREADY_INITIALIZED"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_ALREADY_INITIALIZED">ERROR_ALREADY_INITIALIZED</a>: u64 = 1;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_EXCESSIVE_FEE"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_EXCESSIVE_FEE">ERROR_EXCESSIVE_FEE</a>: u64 = 22;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_BALANCE"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>: u64 = 27;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_LIQUIDITY_BURNED"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_LIQUIDITY_BURNED">ERROR_INSUFFICIENT_LIQUIDITY_BURNED</a>: u64 = 10;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_LIQUIDITY_MINTED"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_LIQUIDITY_MINTED">ERROR_INSUFFICIENT_LIQUIDITY_MINTED</a>: u64 = 4;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_OUTPUT_AMOUNT"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INSUFFICIENT_OUTPUT_AMOUNT">ERROR_INSUFFICIENT_OUTPUT_AMOUNT</a>: u64 = 13;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INVALID_AMOUNT"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_INVALID_AMOUNT">ERROR_INVALID_AMOUNT</a>: u64 = 8;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_K"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_K">ERROR_K</a>: u64 = 15;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_MUST_BE_INFERIOR_TO_TWENTY"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_MUST_BE_INFERIOR_TO_TWENTY">ERROR_MUST_BE_INFERIOR_TO_TWENTY</a>: u64 = 24;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_ADMIN"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>: u64 = 17;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_CREATOR"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_CREATOR">ERROR_NOT_CREATOR</a>: u64 = 2;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_EQUAL_EXACT_AMOUNT"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_EQUAL_EXACT_AMOUNT">ERROR_NOT_EQUAL_EXACT_AMOUNT</a>: u64 = 19;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_FEE_TO"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_FEE_TO">ERROR_NOT_FEE_TO</a>: u64 = 18;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_OWNER"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_OWNER">ERROR_NOT_OWNER</a>: u64 = 29;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_RESOURCE_ACCOUNT"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NOT_RESOURCE_ACCOUNT">ERROR_NOT_RESOURCE_ACCOUNT</a>: u64 = 20;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NO_FEE_WITHDRAW"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NO_FEE_WITHDRAW">ERROR_NO_FEE_WITHDRAW</a>: u64 = 21;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NO_REWARDS"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NO_REWARDS">ERROR_NO_REWARDS</a>: u64 = 28;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NO_STAKE"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_NO_STAKE">ERROR_NO_STAKE</a>: u64 = 26;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_ONLY_ADMIN"></a>

------
Errors
------


<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_ONLY_ADMIN">ERROR_ONLY_ADMIN</a>: u64 = 0;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_PAIR_NOT_CREATED"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_PAIR_NOT_CREATED">ERROR_PAIR_NOT_CREATED</a>: u64 = 23;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_POOL_NOT_CREATED"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_POOL_NOT_CREATED">ERROR_POOL_NOT_CREATED</a>: u64 = 25;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_TOKENS_NOT_SORTED"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_TOKENS_NOT_SORTED">ERROR_TOKENS_NOT_SORTED</a>: u64 = 9;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_X_NOT_REGISTERED"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_X_NOT_REGISTERED">ERROR_X_NOT_REGISTERED</a>: u64 = 16;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_Y_NOT_REGISTERED"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ERROR_Y_NOT_REGISTERED">ERROR_Y_NOT_REGISTERED</a>: u64 = 16;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_INDIVIDUAL_TOKEN_FEE_THRESHOLD_NUMERATOR"></a>

Max individual token fee: 15%; (1500 / (100*100))


<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_INDIVIDUAL_TOKEN_FEE_THRESHOLD_NUMERATOR">INDIVIDUAL_TOKEN_FEE_THRESHOLD_NUMERATOR</a>: u128 = 1500;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_MINIMUM_LIQUIDITY"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_MINIMUM_LIQUIDITY">MINIMUM_LIQUIDITY</a>: u128 = 1000;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_PRECISION"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_PRECISION">PRECISION</a>: u64 = 10000;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_RESOURCE_ACCOUNT"></a>



<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_RESOURCE_ACCOUNT">RESOURCE_ACCOUNT</a>: <b>address</b> = 0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ZERO_ACCOUNT"></a>

---------
Constants
---------
addresses


<pre><code><b>const</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ZERO_ACCOUNT">ZERO_ACCOUNT</a>: <b>address</b> = 0x0;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_init_individual_token"></a>

## Function `init_individual_token`

Initialize individual token fees;
token owners will to specify the cointype and input the fees.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_init_individual_token">init_individual_token</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, liquidity_fee: u128, rewards_fee: u128, team_fee: u128)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_init_rewards_pool"></a>

## Function `init_rewards_pool`

Initialize rewards pool in a token pair


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_init_rewards_pool">init_rewards_pool</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, is_x_staked: bool)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_add_liquidity"></a>

## Function `add_liquidity`

---------------
Entry Functions
---------------
Add more liquidity to token types. This method explicitly assumes the
min of both tokens are 0.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_add_liquidity">add_liquidity</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, amount_x: u64, amount_y: u64): (u64, u64, u64)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_remove_liquidity"></a>

## Function `remove_liquidity`

Remove liquidity to token types.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_remove_liquidity">remove_liquidity</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, liquidity: u64): (u64, u64)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_add_swap_event"></a>

## Function `add_swap_event`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_add_swap_event">add_swap_event</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, amount_x_in: u64, amount_y_in: u64, amount_x_out: u64, amount_y_out: u64)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_add_swap_event_with_address"></a>

## Function `add_swap_event_with_address`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_add_swap_event_with_address">add_swap_event_with_address</a>&lt;X, Y&gt;(sender_addr: <b>address</b>, amount_x_in: u64, amount_y_in: u64, amount_x_out: u64, amount_y_out: u64)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_stake_tokens"></a>

## Function `stake_tokens`

stake tokens in a token pair given an amount and a token pair


<pre><code><b>public</b> entry <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_stake_tokens">stake_tokens</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, amount: u64)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_withdraw_tokens"></a>

## Function `withdraw_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_withdraw_tokens">withdraw_tokens</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, amount: u64)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_claim_rewards"></a>

## Function `claim_rewards`

claim rewards from a token pair


<pre><code><b>public</b> entry <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_claim_rewards">claim_rewards</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_admin"></a>

## Function `set_admin`



<pre><code><b>public</b> entry <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_admin">set_admin</a>(sender: &<a href="">signer</a>, new_admin: <b>address</b>)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_fee_to"></a>

## Function `set_fee_to`



<pre><code><b>public</b> entry <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_fee_to">set_fee_to</a>(sender: &<a href="">signer</a>, new_fee_to: <b>address</b>)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_token_pair_owner"></a>

## Function `set_token_pair_owner`



<pre><code><b>public</b> entry <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_token_pair_owner">set_token_pair_owner</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, owner: <b>address</b>)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_withdraw_team_fee"></a>

## Function `withdraw_team_fee`

Withdraw team fee from pool; team x should get y and vice versa


<pre><code><b>public</b> entry <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_withdraw_team_fee">withdraw_team_fee</a>&lt;CoinType, X, Y&gt;(sender: &<a href="">signer</a>)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_register_pair"></a>

## Function `register_pair`

------------------
Internal Functions
------------------
Register a pair; callable only by token owners
TODO: explore better naming


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_register_pair">register_pair</a>&lt;CoinType, X, Y&gt;(sender: &<a href="">signer</a>)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_all_individual_token_fees"></a>

## Function `toggle_all_individual_token_fees`

Toggle fees
toggle all individual token fees in a token pair; given CoinType, and a Token Pair


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_all_individual_token_fees">toggle_all_individual_token_fees</a>&lt;CoinType, X, Y&gt;(sender: &<a href="">signer</a>, activate: bool)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_individual_token_liquidity_fee"></a>

## Function `toggle_individual_token_liquidity_fee`

Toggle liquidity fee


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_individual_token_liquidity_fee">toggle_individual_token_liquidity_fee</a>&lt;CoinType, X, Y&gt;(sender: &<a href="">signer</a>, activate: bool)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_individual_token_team_fee"></a>

## Function `toggle_individual_token_team_fee`

toggle team fee


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_individual_token_team_fee">toggle_individual_token_team_fee</a>&lt;CoinType, X, Y&gt;(sender: &<a href="">signer</a>, activate: bool)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_individual_token_rewards_fee"></a>

## Function `toggle_individual_token_rewards_fee`

toggle liquidity fee


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_toggle_individual_token_rewards_fee">toggle_individual_token_rewards_fee</a>&lt;CoinType, X, Y&gt;(sender: &<a href="">signer</a>, activate: bool)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_create_pair"></a>

## Function `create_pair`

Create the specified coin pair; all fees are toggled off


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_create_pair">create_pair</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_x_to_y"></a>

## Function `swap_exact_x_to_y`

Swap X to Y, X is in and Y is out. This method assumes amount_out_min is 0


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_x_to_y">swap_exact_x_to_y</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, amount_in: u64, <b>to</b>: <b>address</b>): u64
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_x_to_y_direct"></a>

## Function `swap_exact_x_to_y_direct`

Swap X to Y, X is in and Y is out. This method assumes amount_out_min is 0


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_x_to_y_direct">swap_exact_x_to_y_direct</a>&lt;X, Y&gt;(coins_in: <a href="_Coin">coin::Coin</a>&lt;X&gt;): (<a href="_Coin">coin::Coin</a>&lt;X&gt;, <a href="_Coin">coin::Coin</a>&lt;Y&gt;)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_x_to_exact_y"></a>

## Function `swap_x_to_exact_y`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_x_to_exact_y">swap_x_to_exact_y</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, amount_in: u64, amount_out: u64, <b>to</b>: <b>address</b>): u64
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_x_to_exact_y_direct"></a>

## Function `swap_x_to_exact_y_direct`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_x_to_exact_y_direct">swap_x_to_exact_y_direct</a>&lt;X, Y&gt;(coins_in: <a href="_Coin">coin::Coin</a>&lt;X&gt;, amount_out: u64): (<a href="_Coin">coin::Coin</a>&lt;X&gt;, <a href="_Coin">coin::Coin</a>&lt;Y&gt;)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_y_to_x"></a>

## Function `swap_exact_y_to_x`

Swap Y to X, Y is in and X is out. This method assumes amount_out_min is 0


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_y_to_x">swap_exact_y_to_x</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, amount_in: u64, <b>to</b>: <b>address</b>): u64
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_y_to_exact_x"></a>

## Function `swap_y_to_exact_x`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_y_to_exact_x">swap_y_to_exact_x</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>, amount_in: u64, amount_out: u64, <b>to</b>: <b>address</b>): u64
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_y_to_exact_x_direct"></a>

## Function `swap_y_to_exact_x_direct`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_y_to_exact_x_direct">swap_y_to_exact_x_direct</a>&lt;X, Y&gt;(coins_in: <a href="_Coin">coin::Coin</a>&lt;Y&gt;, amount_out: u64): (<a href="_Coin">coin::Coin</a>&lt;X&gt;, <a href="_Coin">coin::Coin</a>&lt;Y&gt;)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_y_to_x_direct"></a>

## Function `swap_exact_y_to_x_direct`

Swap Y to X, Y is in and X is out. This method assumes amount_out_min is 0


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_swap_exact_y_to_x_direct">swap_exact_y_to_x_direct</a>&lt;X, Y&gt;(coins_in: <a href="_Coin">coin::Coin</a>&lt;Y&gt;): (<a href="_Coin">coin::Coin</a>&lt;X&gt;, <a href="_Coin">coin::Coin</a>&lt;Y&gt;)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_dex_liquidity_fee"></a>

## Function `get_dex_liquidity_fee`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_dex_liquidity_fee">get_dex_liquidity_fee</a>(): u128
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_dex_treasury_fee"></a>

## Function `get_dex_treasury_fee`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_dex_treasury_fee">get_dex_treasury_fee</a>(): u128
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_individual_token_liquidity_fee"></a>

## Function `get_individual_token_liquidity_fee`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_individual_token_liquidity_fee">get_individual_token_liquidity_fee</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>): u128
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_individual_token_team_fee"></a>

## Function `get_individual_token_team_fee`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_individual_token_team_fee">get_individual_token_team_fee</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>): u128
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_individual_token_rewards_fee"></a>

## Function `get_individual_token_rewards_fee`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_individual_token_rewards_fee">get_individual_token_rewards_fee</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>): u128
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_is_pair_created"></a>

## Function `is_pair_created`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_is_pair_created">is_pair_created</a>&lt;X, Y&gt;(): bool
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_is_pool_created"></a>

## Function `is_pool_created`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_is_pool_created">is_pool_created</a>&lt;X, Y&gt;(): bool
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_total_lp_supply"></a>

## Function `total_lp_supply`

Get the total supply of LP Tokens


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_total_lp_supply">total_lp_supply</a>&lt;X, Y&gt;(): u128
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_fees"></a>

## Function `token_fees`

Get the current fees for a token pair


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_fees">token_fees</a>&lt;X, Y&gt;(): u128
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_rewards_pool_info"></a>

## Function `token_rewards_pool_info`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_rewards_pool_info">token_rewards_pool_info</a>&lt;X, Y&gt;(): (u64, u64, u64, u128, u128, u128, bool)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_reserves"></a>

## Function `token_reserves`

Get the current reserves of T0 and T1 with the latest updated timestamp


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_reserves">token_reserves</a>&lt;X, Y&gt;(): (u64, u64, u64)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_balances"></a>

## Function `token_balances`

The amount of balance currently in pools of the liquidity pair


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_token_balances">token_balances</a>&lt;X, Y&gt;(): (u64, u64)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_admin"></a>

## Function `admin`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_admin">admin</a>(): <b>address</b>
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_fee_to"></a>

## Function `fee_to`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_fee_to">fee_to</a>(): <b>address</b>
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_lp_balance"></a>

## Function `lp_balance`

Obtain the LP token balance of <code>addr</code>.
This method can only be used to check other users' balance.


<pre><code><b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_lp_balance">lp_balance</a>&lt;X, Y&gt;(addr: <b>address</b>): u64
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_check_or_register_coin_store"></a>

## Function `check_or_register_coin_store`



<pre><code><b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_check_or_register_coin_store">check_or_register_coin_store</a>&lt;X&gt;(sender: &<a href="">signer</a>)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_dex_liquidity_fee"></a>

## Function `set_dex_liquidity_fee`

--------
Mutators
--------
Callable only by DEX Owner
set dex liquidity fee


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_dex_liquidity_fee">set_dex_liquidity_fee</a>(sender: &<a href="">signer</a>, new_fee: u128)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ser_dex_treasury_fee"></a>

## Function `ser_dex_treasury_fee`

set dex treasury fee


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_ser_dex_treasury_fee">ser_dex_treasury_fee</a>(sender: &<a href="">signer</a>, new_fee: u128)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_individual_token_liquidity_fee"></a>

## Function `set_individual_token_liquidity_fee`

Callable only by token owners
update individual token liquidity fee


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_individual_token_liquidity_fee">set_individual_token_liquidity_fee</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, new_fee: u128)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_individual_token_team_fee"></a>

## Function `set_individual_token_team_fee`

set individual token team fee


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_individual_token_team_fee">set_individual_token_team_fee</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, new_fee: u128)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_individual_token_rewards_fee"></a>

## Function `set_individual_token_rewards_fee`

set individual token rewards fee


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_set_individual_token_rewards_fee">set_individual_token_rewards_fee</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, new_fee: u128)
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_reserve"></a>

## Function `get_reserve`

return pair reserve if it's created


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_get_reserve">get_reserve</a>&lt;X, Y&gt;(): <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_TokenPairReserve">swap_v2::TokenPairReserve</a>&lt;X, Y&gt;
</code></pre>



<a name="0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_register_lp"></a>

## Function `register_lp`



<pre><code><b>public</b> <b>fun</b> <a href="swap_v2.md#0x90fdf0b1ef78d8dc098e1e7cd3b6fe1f084c808484bc243a1da2a24e7ef06096_swap_v2_register_lp">register_lp</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>)
</code></pre>
