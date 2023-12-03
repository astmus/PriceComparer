CREATE TABLE [dbo].[WhatsAppTemplateMessages] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [ExternalId]       VARCHAR (36)   NOT NULL,
    [PhoneNumber]      VARCHAR (50)   NOT NULL,
    [Message]          VARCHAR (4000) NULL,
    [StatusId]         INT            NOT NULL,
    [ErrorCode]        INT            NULL,
    [ErrorDescription] VARCHAR (MAX)  NULL,
    [TemplateId]       INT            NOT NULL,
    [CreatedDate]      DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

