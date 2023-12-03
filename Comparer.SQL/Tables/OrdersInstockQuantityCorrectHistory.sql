CREATE TABLE [dbo].[OrdersInstockQuantityCorrectHistory] (
    [CorrectId]  BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreateDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_OrdersInstockQuantityCorrectHistory] PRIMARY KEY CLUSTERED ([CorrectId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXOrdersInstockQuantityCorrectHistoryId]
    ON [dbo].[OrdersInstockQuantityCorrectHistory]([CorrectId] ASC);

