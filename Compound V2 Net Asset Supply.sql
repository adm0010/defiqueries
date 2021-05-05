SELECT
day,
token,
sum(sum(supply)) over (partition by token order by day)*avg(p.price) as outstanding
FROM
(
SELECT
date_trunc('day', block_time) as day,
token_symbol as token,
sum(mint_amount) as supply
FROM compound."view_mint"
WHERE block_time > now() - interval '30 days'
GROUP BY 1,2
UNION 
SELECT
date_trunc('day', block_time) as day,
token_symbol as token,
sum(-redeem_amount) as supply
FROM compound."view_redeem"
WHERE block_time > now() - interval '30 days'
GROUP BY 1,2
) net
LEFT JOIN prices.usd p ON net.day = p.minute
WHERE p.symbol = net.token 
GROUP BY 1,2
ORDER BY 1 desc
