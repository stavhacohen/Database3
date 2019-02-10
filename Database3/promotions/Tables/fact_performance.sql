CREATE TABLE [promotions].[fact_performance] (
    [measure_kpi_adopting_customers]                 INT             NULL,
    [measure_kpi_bruto_uplift_margin]                NUMERIC (18, 2) NULL,
    [measure_kpi_bruto_uplift_revenue]               NUMERIC (18, 2) NULL,
    [measure_kpi_discount]                           NUMERIC (18, 2) NULL,
    [measure_kpi_netto_uplift_margin]                NUMERIC (18, 2) NULL,
    [measure_kpi_netto_uplift_revenue]               NUMERIC (18, 2) NULL,
    [measure_kpi_new_customers]                      INT             NULL,
    [measure_kpi_number_customers]                   INT             NULL,
    [measure_kpi_promotion_customers]                INT             NULL,
    [measure_kpi_promotion_margin_per_product]       NUMERIC (18, 2) NULL,
    [measure_kpi_promotion_price_per_product]        NUMERIC (18, 2) NULL,
    [measure_kpi_regular_margin_per_product]         NUMERIC (18, 2) NULL,
    [measure_kpi_regular_price_per_product]          NUMERIC (18, 2) NULL,
    [measure_kpi_selling_price]                      NUMERIC (18, 2) NULL,
    [measure_kpi_supplier_participation_per_product] INT             NULL,
    [measure_kpi_total_supplier_participation]       INT             NULL,
    [measure_length]                                 INT             NULL,
    [measure_m1_promotion]                           NUMERIC (18, 2) NULL,
    [measure_m2_subs_promo]                          NUMERIC (18, 2) NULL,
    [measure_m3_subs_group]                          NUMERIC (18, 2) NULL,
    [measure_m4_promobuyer_existing]                 NUMERIC (18, 2) NULL,
    [measure_m5_promobuyer_new]                      NUMERIC (18, 2) NULL,
    [measure_m6_new_customer]                        NUMERIC (18, 2) NULL,
    [measure_m7_product_adoption]                    NUMERIC (18, 2) NULL,
    [measure_m8_hoarding]                            NUMERIC (18, 2) NULL,
    [measure_margin_value_effect]                    NUMERIC (18, 2) NULL,
    [measure_quantity_baseline]                      NUMERIC (18, 2) NULL,
    [measure_quantity_real]                          NUMERIC (18, 2) NULL,
    [measure_r1_promotion]                           NUMERIC (18, 2) NULL,
    [measure_r2_subs_promo]                          NUMERIC (18, 2) NULL,
    [measure_r3_subs_group]                          NUMERIC (18, 2) NULL,
    [measure_r4_promobuyer_existing]                 NUMERIC (18, 2) NULL,
    [measure_r5_promobuyer_new]                      NUMERIC (18, 2) NULL,
    [measure_r6_new_customer]                        NUMERIC (18, 2) NULL,
    [measure_r7_product_adoption]                    NUMERIC (18, 2) NULL,
    [measure_r8_hoarding]                            NUMERIC (18, 2) NULL,
    [measure_revenue_value_effect]                   NUMERIC (18, 2) NULL,
    [measure_m9_discarded_products]                  NUMERIC (18, 2) NULL,
    [measure_r9_discarded_products]                  NUMERIC (18, 2) NULL,
    [id_campaign]                                    INT             NOT NULL,
    [id_date]                                        INT             NOT NULL,
    [id_date_next_year]                              INT             NOT NULL,
    [id_date_last_year]                              INT             NOT NULL,
    [id_format]                                      INT             NOT NULL,
    [id_kpi_promotion_segment]                       INT             NOT NULL,
    [id_place_in_store]                              INT             NOT NULL,
    [id_product]                                     INT             NOT NULL,
    [id_product_category]                            INT             NOT NULL,
    [id_promotion]                                   INT             NOT NULL,
    [id_promotion_end]                               INT             NOT NULL,
    [id_promotion_start]                             INT             NOT NULL,
    [id_promotion_type]                              INT             NOT NULL,
    [id_meta_load_date]                              INT             NOT NULL,
    CONSTRAINT [PK_factperformance] PRIMARY KEY CLUSTERED ([id_date] ASC, [id_promotion] ASC, [id_product] ASC, [id_format] ASC, [id_promotion_start] ASC, [id_promotion_end] ASC),
    CONSTRAINT [FK_performance__id_campaign] FOREIGN KEY ([id_campaign]) REFERENCES [promotions].[dim_campaign] ([id_campaign]),
    CONSTRAINT [FK_performance__id_date] FOREIGN KEY ([id_date]) REFERENCES [promotions].[dim_date] ([id_date]),
    CONSTRAINT [FK_performance__id_date_last_year] FOREIGN KEY ([id_date_last_year]) REFERENCES [promotions].[dim_date] ([id_date]),
    CONSTRAINT [FK_performance__id_date_next_year] FOREIGN KEY ([id_date_next_year]) REFERENCES [promotions].[dim_date] ([id_date]),
    CONSTRAINT [FK_performance__id_format] FOREIGN KEY ([id_format]) REFERENCES [promotions].[dim_format] ([id_format]),
    CONSTRAINT [FK_performance__id_kpi_promotion_segment] FOREIGN KEY ([id_kpi_promotion_segment]) REFERENCES [promotions].[dim_promotion_segment] ([id_promotion_segment]),
    CONSTRAINT [FK_performance__id_meta_load_date] FOREIGN KEY ([id_meta_load_date]) REFERENCES [promotions].[dim_date] ([id_date]),
    CONSTRAINT [FK_performance__id_place_in_store] FOREIGN KEY ([id_place_in_store]) REFERENCES [promotions].[dim_place_in_store] ([id_place_in_store]),
    CONSTRAINT [FK_performance__id_product] FOREIGN KEY ([id_product]) REFERENCES [promotions].[dim_product] ([id_product]),
    CONSTRAINT [FK_performance__id_product_category] FOREIGN KEY ([id_product_category]) REFERENCES [promotions].[dim_product_category] ([id_product_category]),
    CONSTRAINT [FK_performance__id_promotion] FOREIGN KEY ([id_promotion]) REFERENCES [promotions].[dim_promotion] ([id_promotion]),
    CONSTRAINT [FK_performance__id_promotion_end] FOREIGN KEY ([id_promotion_end]) REFERENCES [promotions].[dim_date] ([id_date]),
    CONSTRAINT [FK_performance__id_promotion_start] FOREIGN KEY ([id_promotion_start]) REFERENCES [promotions].[dim_date] ([id_date]),
    CONSTRAINT [FK_performance__id_promotion_type] FOREIGN KEY ([id_promotion_type]) REFERENCES [promotions].[dim_promotion_type] ([id_promotion_type])
);


GO
CREATE NONCLUSTERED INDEX [IX_factperformance_id_date_id_promotion_type]
    ON [promotions].[fact_performance]([id_date] ASC, [id_promotion_type] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_factperformance_id_date_id_product_category]
    ON [promotions].[fact_performance]([id_date] ASC, [id_product_category] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_factperformance_id_date_id_place_in_store]
    ON [promotions].[fact_performance]([id_date] ASC, [id_place_in_store] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_factperformance_id_date_id_kpi_promotion_segment]
    ON [promotions].[fact_performance]([id_date] ASC, [id_kpi_promotion_segment] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_factperformance_id_date_id_date_last_year]
    ON [promotions].[fact_performance]([id_date] ASC, [id_date_last_year] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_factperformance_id_date_id_date_next_year]
    ON [promotions].[fact_performance]([id_date] ASC, [id_date_next_year] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_factperformance_id_date_id_campaign]
    ON [promotions].[fact_performance]([id_date] ASC, [id_campaign] ASC);

