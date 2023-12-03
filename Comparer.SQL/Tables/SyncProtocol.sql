CREATE TABLE [dbo].[SyncProtocol] (
    [Id]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [SiteId]         UNIQUEIDENTIFIER NOT NULL,
    [ApiPoint]       NVARCHAR (255)   NOT NULL,
    [ObjectId]       NVARCHAR (36)    NOT NULL,
    [ObjectTypeId]   INT              NOT NULL,
    [MethodId]       INT              NOT NULL,
    [Content]        NVARCHAR (MAX)   NULL,
    [ResponseAnswer] NVARCHAR (MAX)   NOT NULL,
    [ResponseCode]   INT              NOT NULL,
    [TryCount]       TINYINT          DEFAULT ((1)) NOT NULL,
    [AuthorId]       UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]    DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_SyncProtocol] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXSyncProtocolResponseCode]
    ON [dbo].[SyncProtocol]([ResponseCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IXSyncProtocolSiteObjectId]
    ON [dbo].[SyncProtocol]([SiteId] ASC, [ObjectId] ASC, [CreatedDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IXSyncProtocolComplex]
    ON [dbo].[SyncProtocol]([SiteId] ASC, [ObjectId] ASC, [MethodId] ASC, [ResponseCode] ASC, [CreatedDate] ASC);

