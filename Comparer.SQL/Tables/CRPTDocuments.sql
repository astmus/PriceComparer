CREATE TABLE [dbo].[CRPTDocuments] (
    [Id]                       INT              IDENTITY (1, 1) NOT NULL,
    [CRPTNumber]               NVARCHAR (500)   NULL,
    [CRPTInput]                BIT              NOT NULL,
    [CRPTCreatedDate]          DATETIME         NULL,
    [CRPTType]                 VARCHAR (128)    NULL,
    [CRPTStatus]               VARCHAR (128)    NULL,
    [SenderInn]                VARCHAR (20)     NOT NULL,
    [ReceiverInn]              VARCHAR (20)     NOT NULL,
    [DocNumber]                NVARCHAR (128)   NOT NULL,
    [DocDate]                  DATE             NOT NULL,
    [DocAction]                NVARCHAR (128)   NULL,
    [DocActionDate]            DATETIME         NULL,
    [DocPrimaryType]           NVARCHAR (64)    NULL,
    [DocTypeName]              NVARCHAR (255)   NULL,
    [SenderId]                 INT              NULL,
    [ReceiverId]               INT              NULL,
    [StatusId]                 INT              DEFAULT ((0)) NOT NULL,
    [IsCRPTCancelled]          AS               (CONVERT([bit],case when [CRPTStatus]='CANCELLED' then (1) else (0) end,0)),
    [CancellationCRPTNumber]   NVARCHAR (500)   NULL,
    [CancellationDocDate]      DATETIME         NULL,
    [CancellationRecevingDate] DATETIME         NULL,
    [Comments]                 NVARCHAR (255)   NULL,
    [Error]                    NVARCHAR (4000)  NULL,
    [AuthorId]                 UNIQUEIDENTIFIER NULL,
    [CreatedDate]              DATETIME         DEFAULT (getdate()) NOT NULL,
    [ChangedDate]              DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_CRPTDocuments_DocDate]
    ON [dbo].[CRPTDocuments]([DocDate] ASC)
    INCLUDE([CRPTInput], [StatusId]);

