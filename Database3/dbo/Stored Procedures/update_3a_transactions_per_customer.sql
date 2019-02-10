

-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-03
-- Description:	Aggregates daily sales per customer
-- =============================================
CREATE PROCEDURE [dbo].[update_3a_transactions_per_customer]
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30',
    @countX int = 1,
    @countY int = 50000
AS
BEGIN
INSERT INTO dbo.PG_transactions_per_customer_update
SELECT	  tt.HouseholdID,
		  tt.TransactionDate,
		  CAST(SUM(CASE WHEN ISNULL(Quantity,0) > 0 THEN ISNULL(tt.NetSaleNoVAT,0) ELSE 0 END) AS DECIMAL(10,2)),
		  CAST(SUM(CASE WHEN ISNULL(Quantity,0) > 0 AND ppi.Promo_ind = 1 THEN ISNULL(tt.NetSaleNoVAT,0) ELSE 0 END) AS DECIMAL(10,2)),
		  CAST(SUM(CASE WHEN ISNULL(Quantity,0) > 0 THEN ISNULL(tt.Quantity,0) ELSE 0 END) AS DECIMAL(10,2)),
		  CAST(SUM(CASE WHEN ISNULL(Quantity,0) > 0 AND ppi.Promo_ind = 1 THEN ISNULL(tt.Quantity,0) ELSE 0 END) AS DECIMAL(10,2)),
		  CAST(SUM(CASE WHEN ISNULL(Quantity,0) > 0 THEN ISNULL(tt.Range_Amtttt,0) ELSE 0 END) AS DECIMAL(10,2)),
		  CAST(SUM(CASE WHEN ISNULL(Quantity,0) > 0 AND ppi.Promo_ind = 1 THEN ISNULL(tt.Range_Amtttt,0) ELSE 0 END) AS DECIMAL(10,2)),
		  ISNULL(mv.Max_visit_index,0) + ROW_NUMBER() OVER(PARTITION BY tt.HouseholdID ORDER BY tt.TransactionDate)
FROM		  dbo.Staging_transactions_total_update tt
INNER JOIN  dbo.Staging_branches br
ON		  tt.StoreFormatCode = br.Branch_ID
	   AND br.Branch_name_EN NOT LIKE 'Other'
LEFT JOIN   dbo.PG_promo_product_ind_update ppi
ON		  ppi.Branch_name_EN = br.Branch_name_EN
	   AND ppi.ProductNumber = tt.ProductNumber
	   AND ppi.SourceInd = tt.SourceInd
	   AND ppi.TransactionDate = tt.TransactionDate
LEFT JOIN	  dbo.PG_transactions_per_customer_max_visit mv
ON		  tt.HouseholdID = mv.HouseholdID
WHERE	  tt.HouseholdID IN (SELECT HouseholdID FROM dbo.PG_customers WHERE Ind BETWEEN @countX AND @countY)
	   AND tt.TransactionDate BETWEEN @start_date AND @end_date
GROUP BY	  tt.HouseholdID,
		  tt.TransactionDate,
		  mv.Max_visit_index
END

