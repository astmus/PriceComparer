CREATE TABLE [dbo].[_UTOrderHistory] (
    [OrderId]               UNIQUEIDENTIFIER NOT NULL,
    [IsCalc]                BIT              DEFAULT ((0)) NOT NULL,
    [IsWMSDocumentUpdate]   BIT              DEFAULT ((0)) NOT NULL,
    [IsPutToUTExportOrders] BIT              DEFAULT ((0)) NOT NULL
);

