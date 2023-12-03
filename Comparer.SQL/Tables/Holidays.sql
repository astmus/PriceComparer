CREATE TABLE [dbo].[Holidays] (
    [Date] DATE NOT NULL,
    PRIMARY KEY CLUSTERED ([Date] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_Holidays]
    ON [dbo].[Holidays]([Date] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_DeliveryHolydays]
    ON [dbo].[Holidays]([Date] ASC);

