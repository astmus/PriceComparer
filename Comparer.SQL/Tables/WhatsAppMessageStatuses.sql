CREATE TABLE [dbo].[WhatsAppMessageStatuses] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [StatusName] VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

