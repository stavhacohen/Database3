
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-03
-- Description:	Calculates information about customer based on previous shopping behavior
-- =============================================
CREATE PROCEDURE [dbo].[update_3b_customer_information_table]
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30',
    @countX int = 1,
    @countY int = 50000,
    @customer_days int = 42, -- A customer is considered a promotion customer according to his sales in the previous 6 weeks
    @new_customer_days int = 91, -- A customer is considered a new customer after 13 weeks without a visit
    @promo_perc float = 0.6
AS
BEGIN

INSERT INTO dbo.PG_customer_information_table_update
SELECT	  t1.HouseholdID,
		  t1.TransactionDate,
		  t1.Visit_index,
		  t2.TransactionDate,
		  CASE WHEN DATEDIFF(day,t2.TransactionDate,t1.TransactionDate) >= @customer_days OR t2.TransactionDate IS NULL
			  THEN 1 ELSE 0 END,
		  CASE WHEN DATEDIFF(day,t2.TransactionDate,t1.TransactionDate) >= @new_customer_days OR t2.TransactionDate IS NULL
			  THEN 1 ELSE 0 END,
		  t1.Promo_revenue,
		  t1.Total_revenue-t1.Promo_revenue,
		  t1.Promo_margin,
		  t1.Total_margin-t1.Promo_margin,
		  t1.Promo_quantity,
		  t1.Total_quantity-t1.Promo_quantity,
		  CAST(CASE WHEN SUM(t3.Total_revenue) = 0 THEN 0
				  WHEN ABS(SUM(t3.Promo_revenue)/SUM(t3.Total_revenue)) >= 1 THEN 1
		       ELSE SUM(t3.Promo_revenue)/SUM(t3.Total_revenue) END AS DECIMAL(3,2)),
		  CASE WHEN SUM(t3.Total_revenue) = 0 OR SUM(t3.Promo_revenue)/SUM(t3.Total_revenue) < @promo_perc
			  THEN 0 ELSE 1 END
FROM		  dbo.PG_transactions_per_customer_update t1
LEFT JOIN	  dbo.PG_transactions_per_customer t2
ON		  t1.HouseholdID = t2.HouseholdID
	   AND t1.Visit_index = t2.Visit_index + 1
LEFT JOIN	  dbo.PG_transactions_per_customer t3
ON		  t1.HouseholdID = t3.HouseholdID
	   AND t3.TransactionDate BETWEEN DATEADD(day,-@customer_days+1,t1.TransactionDate) AND t1.TransactionDate
WHERE	  t1.HouseholdID IN (SELECT HouseholdID FROM dbo.PG_customers WHERE Ind BETWEEN	@countX AND @countY)
	   AND t1.TransactionDate BETWEEN @start_date AND @end_date
GROUP BY	  t1.HouseholdID,
		  t1.TransactionDate,
		  t2.TransactionDate,
		  t1.Promo_margin,
		  t1.Promo_quantity,
		  t1.Promo_revenue,
		  t1.Total_margin,
		  t1.Total_quantity,
		  t1.Total_revenue,
		  t1.Visit_index
END

