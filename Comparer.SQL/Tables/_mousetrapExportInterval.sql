CREATE TABLE [dbo].[_mousetrapExportInterval] (
    [Id]          INT IDENTITY (1, 1) NOT NULL,
    [WmsHourFrom] INT NOT NULL,
    [WmsHourTo]   INT NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

