CREATE TABLE [dbo].[DeliveryServicePrinterConfigurations] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [WorkplaceName] NVARCHAR (255)  NOT NULL,
    [A4Printer]     NVARCHAR (500)  NOT NULL,
    [LabelPrinters] NVARCHAR (4000) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

