CREATE TABLE [dbo].[GN_totalTransactions_supplier_dist] (
    [SUPPLIER_ID]             INT              NULL,
    [SourceInd]               SMALLINT         NULL,
    [Branch_name_EN]          VARCHAR (7)      NULL,
    [cnt_products]            INT              NULL,
    [tot_rev_BranchSource]    DECIMAL (38, 13) NULL,
    [tot_CatRev_BranchSource] NUMERIC (38, 6)  NULL,
    [perc_rev]                DECIMAL (38, 6)  NULL,
    [perc_CatRev]             NUMERIC (38, 6)  NULL
);

