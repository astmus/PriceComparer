CREATE TABLE [dbo].[SiteApiRequests] (
    [Id]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [IsSuccess]    BIT              NOT NULL,
    [Direction]    INT              NOT NULL,
    [ObjectTypeId] INT              NOT NULL,
    [SiteName]     NVARCHAR (50)    NOT NULL,
    [Method]       INT              NOT NULL,
    [Url]          NVARCHAR (1000)  NOT NULL,
    [Body]         NVARCHAR (MAX)   NOT NULL,
    [RequestDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    [AnswerCode]   INT              NOT NULL,
    [AnswerBody]   NVARCHAR (MAX)   NOT NULL,
    [AuthorId]     UNIQUEIDENTIFIER NOT NULL,
    [Comment]      NVARCHAR (255)   NULL,
    CONSTRAINT [PK_SiteApiRequests] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXSiteApiRequestsIsSuccess]
    ON [dbo].[SiteApiRequests]([IsSuccess] ASC);


GO
CREATE NONCLUSTERED INDEX [IXSiteApiRequestsObjectType]
    ON [dbo].[SiteApiRequests]([ObjectTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IXSiteApiRequestsRequest]
    ON [dbo].[SiteApiRequests]([IsSuccess] ASC, [Direction] ASC, [RequestDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IXSiteApiRequestsAuthor]
    ON [dbo].[SiteApiRequests]([AuthorId] ASC);

