CREATE TABLE [dbo].[ApiDeliveryServiceTrackers] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [AccountId]          INT             DEFAULT ((0)) NOT NULL,
    [StateId]            INT             DEFAULT ((0)) NOT NULL,
    [StartTrackingDate]  DATETIME        NULL,
    [OrderCountLimit]    INT             NULL,
    [DelayBetweenStages] INT             NULL,
    [Errors]             NVARCHAR (4000) NULL,
    [IsActive]           BIT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

