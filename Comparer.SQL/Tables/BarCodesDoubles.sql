CREATE TABLE [dbo].[BarCodesDoubles] (
    [SessionID]  BIGINT        NOT NULL,
    [BatchNo1РЎ] NCHAR (10)    DEFAULT ('') NOT NULL,
    [BarCode]    NVARCHAR (39) NOT NULL,
    [SKU]        INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([SessionID] ASC, [BatchNo1РЎ] ASC, [BarCode] ASC, [SKU] ASC)
);

