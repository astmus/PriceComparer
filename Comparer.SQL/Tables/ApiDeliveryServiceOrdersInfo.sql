CREATE TABLE [dbo].[ApiDeliveryServiceOrdersInfo] (
    [InnerId]                UNIQUEIDENTIFIER NOT NULL,
    [LabelDowloadCount]      TINYINT          DEFAULT ((0)) NOT NULL,
    [IKNId]                  INT              NULL,
    [LabelId]                VARCHAR (100)    NULL,
    [OuterDopId]             VARCHAR (100)    NULL,
    [CreatedDate]            DATETIME         DEFAULT (getdate()) NOT NULL,
    [ChangedDate]            DATETIME         DEFAULT (getdate()) NOT NULL,
    [CompensationNumber]     NVARCHAR (20)    NULL,
    [CompensationDate]       DATETIME         NULL,
    [CompensationUpdateDate] DATETIME         NULL,
    [CompensationSum]        FLOAT (53)       NULL,
    [CompensationFail]       BIT              NULL,
    [DisabledForTracking]    BIT              DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([InnerId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceOrdersInfo_InnerId]
    ON [dbo].[ApiDeliveryServiceOrdersInfo]([InnerId] ASC);

