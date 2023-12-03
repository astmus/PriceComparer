CREATE TABLE [dbo].[DistributorsApiSettings] (
    [DistributorId]    UNIQUEIDENTIFIER NOT NULL,
    [ApiHost]          NVARCHAR (255)   NULL,
    [ApiUser]          NVARCHAR (100)   NULL,
    [ApiPassword]      NVARCHAR (100)   NULL,
    [ApiSecretToken]   NVARCHAR (100)   NULL,
    [AnswerDataFormat] INT              NULL,
    CONSTRAINT [PKDistributorsApiData] PRIMARY KEY CLUSTERED ([DistributorId] ASC)
);

