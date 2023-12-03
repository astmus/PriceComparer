CREATE TABLE [dbo].[ExportProductReservesChangesDates] (
    [ExportTime] DATETIME NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IXExportProductReservesChangesDatesTime]
    ON [dbo].[ExportProductReservesChangesDates]([ExportTime] ASC);

