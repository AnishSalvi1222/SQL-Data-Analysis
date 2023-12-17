Calculate descriptive Statistics for Monthly Revenue by Products

WITH monthly_rev AS(
SELECT
    date_trunc('month', s.orderdate) AS ordermonth,
    p.productname,
    sum(s.revenue) AS revenue
FROM
    subscriptions s
JOIN
    products p ON s.productid = p.productid
WHERE 
    s.orderdate BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY 
    date_trunc('month', s.orderdate), p.productname
)

SELECT
    productname,
    MIN(revenue) AS MIN_REV,
    MAX(revenue) AS MAX_REV,
    AVG(revenue) AS AVG_REV,
    STDDEV(revenue) AS STD_DEV_REV
FROM monthly_rev
GROUP BY
    productname
