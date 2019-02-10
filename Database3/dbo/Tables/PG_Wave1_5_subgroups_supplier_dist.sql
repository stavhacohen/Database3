CREATE TABLE [dbo].[PG_Wave1_5_subgroups_supplier_dist] (
    [SUPPLIER_ID]                    INT              NULL,
    [SourceInd]                      SMALLINT         NULL,
    [Branch_name_EN]                 VARCHAR (7)      NULL,
    [level_ID]                       INT              NULL,
    [cnt_products_supplier_in_level] INT              NULL,
    [cnt_products_tot_in_level]      INT              NULL,
    [tot_rev_BranchSourceLevel]      DECIMAL (38, 13) NULL,
    [tot_CatRev_BranchSourceLevel]   DECIMAL (38, 6)  NULL,
    [perc_rev]                       DECIMAL (38, 6)  NULL,
    [perc_CatRev]                    DECIMAL (38, 6)  NULL
);

