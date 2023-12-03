CREATE TABLE [dbo].[CRPTDocumentWithPurchaseTaskLinks] (
    [CRPTDocId] INT NOT NULL,
    [TaskId]    INT NOT NULL,
    PRIMARY KEY CLUSTERED ([CRPTDocId] ASC, [TaskId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_CRPTDocumentWithPurchaseTaskLinks_Id]
    ON [dbo].[CRPTDocumentWithPurchaseTaskLinks]([CRPTDocId] ASC)
    INCLUDE([TaskId]);

