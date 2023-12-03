CREATE TABLE [dbo].[ApiDeliveryServicesAccounts] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [ServiceId]      INT             NOT NULL,
    [Name]           NVARCHAR (255)  NOT NULL,
    [Host]           NVARCHAR (255)  NOT NULL,
    [AuthUser]       NVARCHAR (100)  DEFAULT ('') NOT NULL,
    [AuthPassword]   NVARCHAR (100)  DEFAULT ('') NOT NULL,
    [AuthType]       INT             DEFAULT ((0)) NOT NULL,
    [Token]          NVARCHAR (255)  NULL,
    [TokenExpiry]    DATETIME        NULL,
    [TokenLifeTime]  INT             DEFAULT ((0)) NOT NULL,
    [StatusSyncDate] DATETIME        NULL,
    [ApiVresion]     INT             DEFAULT ((1)) NOT NULL,
    [IsDefault]      BIT             DEFAULT ((0)) NOT NULL,
    [DopParams]      NVARCHAR (1000) NULL,
    [IsActive]       BIT             DEFAULT ((1)) NOT NULL,
    [Selector]       NVARCHAR (255)  DEFAULT ('') NOT NULL,
    [UseAggregator]  BIT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServicesAccounts_Id]
    ON [dbo].[ApiDeliveryServicesAccounts]([Id] ASC);

