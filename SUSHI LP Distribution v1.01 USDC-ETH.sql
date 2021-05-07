with daily as  
        (select
            the_day, 
            (eth * 2 * a.price / 1e17) as val
        from 
            (select
            avg(reserve1) / 1e1 as eth,
            date_trunc('day', evt_block_time) as the_day,
            CASE
                WHEN contract_address = '\xb4e16d0168e52d35cacd2c6185b44281ec28c9dc' THEN 'eth-usdc'
            END as pool
            from uniswap_v2."Pair_evt_Sync"
            where contract_address in ('\xbb2b8038a1640196fbe3e38816f3e67cba72d940','\x0d4a11d5eeaac28ec3f61d100daf4d40471f1852','\xa478c2975ab1ea89e8196811f51a7b7ade33eb11','\xb4e16d0168e52d35cacd2c6185b44281ec28c9dc')
            group by contract_address,the_day) 
        x
        JOIN 
            (SELECT  
            date_trunc('day', minute) as day,                                                         
            AVG(price) as price                                                                                
            FROM prices.layer1_usd
            WHERE symbol = 'ETH'
            GROUP BY day)
        a ON x.the_day = a.day)
    SELECT 
    POWER(2, FLOOR(LOG(2, (("output_liquidity"/1.05994e18) * daily.val::integer)))) as liquidity,
    COUNT(*) AS trades 
    FROM 
    sushi."Router02_call_addLiquidity" slp
    left join daily on date_trunc('day',slp.call_block_time) = daily.the_day
    WHERE ("output_liquidity"/1.05994e18) * dailey.val > 10
    AND (("tokenA" = '\xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' AND "tokenB" = '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2') OR
   ("tokenB" = '\xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' AND "tokenA" = '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'))
    AND call_success = 'true' 
    AND call_block_time > now() - interval '1000 days' 
    GROUP BY liquidity
    
