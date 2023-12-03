CREATE TABLE [dbo].[TracingPackages] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [SourceService] VARCHAR (128) NOT NULL,
    [Operation]     VARCHAR (128) NOT NULL,
    [EntityTypeId]  INT           NOT NULL,
    [EntityId]      VARCHAR (36)  NOT NULL,
    [CreatedDate]   DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

