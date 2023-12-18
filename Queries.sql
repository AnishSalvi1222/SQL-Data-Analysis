1. Calculate descriptive Statistics for Monthly Revenue by Products

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


2. Explore the variable Distribution

WITH count_clicks_by_group AS(
SELECT
    UserID,
    Count(ed.EventID) AS NUM_LINK_CLICKS,
FROM 
    FrontendEventDefinitions ed
JOIN 
    FrontendEventLog ee ON ed.EventID = ee.EventID
Where
    ed.EventID=5
Group BY
    UserID
)

Select 
    NUM_LINK_CLICKS, 
    Count(NUM_LINK_CLICKS) AS NUM_USERS 
FROM 
    count_clicks_by_group
Group BY 
    NUM_LINK_CLICKS


3. Payment Funnel Analysis

With MaxStatusperSubscription AS (
Select
    subscriptionID,
    MAX(StatusID) AS maxstatus
FROM
    paymentstatuslog p 
GROUP BY 
    subscriptionID
)
,
PaymentFunnelStage AS (
SELECT
    subscriptions.subscriptionID,
    case when maxstatus = 1 then 'PaymentWidgetOpened'
		when maxstatus = 2 then 'PaymentEntered'
		when maxstatus = 3 and subscriptions.currentstatus = 0 then 'User Error with Payment Submission'
		when maxstatus = 3 and subscriptions.currentstatus != 0 then 'Payment Submitted'
		when maxstatus = 4 and subscriptions.currentstatus = 0 then 'Payment Processing Error with Vendor'
		when maxstatus = 4 and subscriptions.currentstatus != 0 then 'Payment Success'
		when maxstatus = 5 then 'Complete'
		when maxstatus is null then 'User did not start payment process'
		end as paymentfunnelstage

FROM
    subscriptions
LEFT JOIN 
    MaxStatusperSubscription ON  subscriptions.subscriptionID = MaxStatusperSubscription.subscriptionID
)

SELECT
    paymentfunnelstage,
    COUNT(paymentfunnelstage) Subscriptions from PaymentFunnelStage
GROUP BY  paymentfunnelstage
