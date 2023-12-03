CREATE TABLE [dbo].[CRPTWithEDODocumentLinks] (
    [CRPTDocId] INT NOT NULL,
    [EDODocId]  INT NOT NULL,
    PRIMARY KEY CLUSTERED ([CRPTDocId] ASC, [EDODocId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_CRPTWithEDODocumentLinks_Id]
    ON [dbo].[CRPTWithEDODocumentLinks]([CRPTDocId] ASC, [EDODocId] ASC);

