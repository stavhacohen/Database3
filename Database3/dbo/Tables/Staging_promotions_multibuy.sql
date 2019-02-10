CREATE TABLE [dbo].[Staging_promotions_multibuy] (
    [promotion#]                                                 FLOAT (53)     NULL,
    [desc]                                                       NVARCHAR (255) NULL,
    [from date]                                                  FLOAT (53)     NULL,
    [to date]                                                    FLOAT (53)     NULL,
    [sell by weight?]                                            FLOAT (53)     NULL,
    [number of purchase allowed (for weight promo divide by 10)] FLOAT (53)     NULL,
    [% discount]                                                 FLOAT (53)     NULL,
    [amount discount]                                            FLOAT (53)     NULL,
    [min purchase sum for promo]                                 FLOAT (53)     NULL,
    [number of gift products]                                    FLOAT (53)     NULL,
    [multibuy (divide by 10 for weight promo)]                   FLOAT (53)     NULL,
    [promo price]                                                FLOAT (53)     NULL
);

