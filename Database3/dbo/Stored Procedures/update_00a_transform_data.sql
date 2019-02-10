
-- =============================================
-- Author:		Matan Marudi 
-- Create date:	2019-01-30
-- Description:	Transform data from ND tables to dbo
-- =============================================
CREATE PROCEDURE [dbo].[update_00a_transform_data]
    @run_nr INT = 1,
    @step INT = 1,
    @run_date DATE = '2017-10-10'
AS
BEGIN

INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Start of [update_00a_transform_data]',
			SYSDATETIME()
		)

INSERT INTO dbo.Staging_transactions_import 
select [#BasketID]
      ,[HouseholdID]
      ,[SourceInd]
      ,[StoreFormatCode]
      ,[LocationID]
      ,[TransactionDate]
      ,[ProductNumber]
      ,[NetSaleNoVAT]
      ,[Quantity]
      ,[ItemQuantity]
      ,[Price_Kg]
      ,[Range_Amtttt] 
from ND.Staging_transactions_import

INSERT INTO dbo.Staging_stores_update 
select [#LocationID]
      ,[StoreName]
      ,[StoreFormatCode]
from ND.Staging_stores_update

INSERT INTO dbo.Staging_promotions_import 
select [CampaignNumberPromo]
      ,[CampaignDesc]
      ,[PromotionNumber]
      ,[PromotionNumberUnv]
      ,[PromotionDesc]
      ,[PromotionStartDate]
      ,[PromotionEndDate]
      ,[ProductNumber]
      ,[DiscountType]
      ,[Multibuy]
      ,[DisplayType]
      ,[Folder]
      ,[PromotionCharacteristicsType]
from ND.Staging_promotions_import

INSERT INTO dbo.Staging_promotions_stores_update 
select [#PromotionNumber]
      ,[PromotionCharacteristicsType]
      ,[LocationID]
from ND.Staging_promotions_stores_update

INSERT INTO dbo.Staging_assortment_product_update 
select [Department]
      ,[Department_name_HE]
      ,[Subdepartment]
      ,[Subdepartment_name_HE]
      ,[Category]
      ,[Category_name_HE]
      ,[Group]
      ,[Group_name_HE]
      ,[Subgroup]
      ,[Subgroup_name_HE]
      ,[Product_ID]
      ,[Product_name_HE]
      ,[Grouping]
      ,[Brand]
      ,[Brand_HE]
      ,[Category_Manager]
      ,[Category_Manager_name_HE]
from ND.Staging_assortment_product_update

INSERT INTO dbo.Staging_promotions_display_import 
select [Promotion_ID]
      ,[Date_from]
      ,[Date_to]
      ,[Display_ID]
      ,[Display_name_HE]
      ,[Display_name_EN]
      ,[Display_number]
      ,[Media_ID]
      ,[Newspaper_chapter]
      ,[Newspaper_page]
      ,[Newspaper_unit]
      ,[Newspaper_location]
      ,[Newspaper_nr_cubes]
from ND.Staging_promotions_display_import

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'all data move to dbo and ready to run update ',
			SYSDATETIME()
		)


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'End of [update_00a_transform_data]',
			SYSDATETIME()
		)

END

