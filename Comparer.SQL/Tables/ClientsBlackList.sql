CREATE TABLE [dbo].[ClientsBlackList] (
    [ClientId] UNIQUEIDENTIFIER NOT NULL,
    [StatusId] INT              NULL,
    PRIMARY KEY CLUSTERED ([ClientId] ASC)
);

