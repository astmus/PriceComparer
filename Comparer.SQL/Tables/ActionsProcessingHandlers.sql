CREATE TABLE [dbo].[ActionsProcessingHandlers] (
    [Id]               INT           IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50) NOT NULL,
    [RegistrationDate] DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ActionsProcessingHandlers_Name]
    ON [dbo].[ActionsProcessingHandlers]([Name] ASC)
    INCLUDE([Id]);

