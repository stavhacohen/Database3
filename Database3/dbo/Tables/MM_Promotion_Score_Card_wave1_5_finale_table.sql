CREATE TABLE [dbo].[MM_Promotion_Score_Card_wave1_5_finale_table] (
    [Group_name_HE]                          NVARCHAR (255)  NULL,
    [Category_name_HE]                       NVARCHAR (255)  NULL,
    [cat_id]                                 BIGINT          NULL,
    [Subdepartment_name_HE]                  NVARCHAR (255)  NULL,
    [department_name_HE]                     NVARCHAR (255)  NULL,
    [EndDate]                                DATE            NULL,
    [Category_Manager_name_HE]               NVARCHAR (255)  NULL,
    [Group_num]                              INT             NULL,
    [Revenue_target]                         INT             NULL,
    [Revenue_target_groth]                   REAL            NULL,
    [Margin_target]                          INT             NULL,
    [Margin_target_groth]                    REAL            NULL,
    [Revenue_value_effect_LastYear_fullyear] DECIMAL (38, 2) NULL,
    [Margin_value_effect_LastYear_full_year] DECIMAL (38, 2) NULL,
    [r1_promotion]                           DECIMAL (38, 2) NULL,
    [Revenue_value_effect]                   DECIMAL (38, 2) NULL,
    [m1_promotion]                           DECIMAL (38, 2) NULL,
    [Margin_value_effect]                    DECIMAL (38, 2) NULL,
    [Revenue_value_effect_LY]                DECIMAL (38, 2) NULL,
    [Margin_value_effect_LY]                 DECIMAL (38, 2) NULL,
    [time]                                   VARCHAR (15)    NOT NULL
);

