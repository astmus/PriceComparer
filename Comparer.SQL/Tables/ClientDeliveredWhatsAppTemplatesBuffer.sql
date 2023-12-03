CREATE TABLE [dbo].[ClientDeliveredWhatsAppTemplatesBuffer] (
    [Id]          INT          IDENTITY (1, 1) NOT NULL,
    [MessageId]   INT          NOT NULL,
    [PhoneNumber] VARCHAR (50) NOT NULL,
    [CreatedDate] DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

