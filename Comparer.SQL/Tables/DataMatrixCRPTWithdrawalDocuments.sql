CREATE TABLE [dbo].[DataMatrixCRPTWithdrawalDocuments] (
    [Id]                    INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]               UNIQUEIDENTIFIER NULL,
    [PublicId]              NVARCHAR (128)   NULL,
    [ActionId]              INT              NOT NULL,
    [ActionDate]            DATETIME         NULL,
    [PrimaryDocumentDate]   DATETIME         NOT NULL,
    [PrimaryDocumentNumber] NVARCHAR (128)   NOT NULL,
    [PrimaryDocumentTypeId] INT              NOT NULL,
    [PrimaryDocumentName]   NVARCHAR (255)   NULL,
    [PdfFile]               NVARCHAR (MAX)   NULL,
    [ContractorId]          INT              NOT NULL,
    [KKTId]                 INT              NULL,
    [CRPTStatus]            VARCHAR (128)    NOT NULL,
    [CRPTStatusId]          INT              DEFAULT ((0)) NOT NULL,
    [StatusId]              INT              DEFAULT ((0)) NOT NULL,
    [Comments]              NVARCHAR (255)   NULL,
    [Error]                 NVARCHAR (1000)  NULL,
    [RegTryCount]           INT              DEFAULT ((0)) NOT NULL,
    [NextTryDate]           DATETIME         NULL,
    [AuthorId]              UNIQUEIDENTIFIER NULL,
    [SourceId]              INT              DEFAULT ((1)) NOT NULL,
    [CreatedDate]           DATETIME         DEFAULT (getdate()) NOT NULL,
    [ChangedDate]           DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_DataMatrixCRPTWithdrawalDocuments_PublicId]
    ON [dbo].[DataMatrixCRPTWithdrawalDocuments]([PublicId] ASC) WHERE ([PublicId] IS NOT NULL);


GO
create trigger tr_DataMatrixCRPTWithdrawalDocuments_Update_Delete on DataMatrixCRPTWithdrawalDocuments after update, delete as
begin

	begin try

	set nocount on			-- отключает вывод сообщения о количестве обработанных строк
	set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)

	insert DataMatrixCRPTWithdrawalDocumentsArchive(
				DocId, OrderId, PublicId, 
				ActionId, ActionDate, 
				PrimaryDocumentDate, PrimaryDocumentNumber, PrimaryDocumentTypeId, PrimaryDocumentName, 
				PdfFile,
				ContractorId, KKTId, 
				CRPTStatus, CRPTStatusId, StatusId, 
				Comments, Error,
				RegTryCount, NextTryDate,
				AuthorId, CreatedDate, ChangedDate
				)
	select 
				d.Id, d.OrderId, d.PublicId, 
				d.ActionId, d.ActionDate, 
				d.PrimaryDocumentDate, d.PrimaryDocumentNumber, d.PrimaryDocumentTypeId, d.PrimaryDocumentName, 
				d.PdfFile,
				d.ContractorId, d.KKTId, 
				d.CRPTStatus, d.CRPTStatusId, d.StatusId, 
				d.Comments, d.Error,
				d.RegTryCount, d.NextTryDate,
				d.AuthorId, d.CreatedDate, d.ChangedDate
	from DELETED d

	end try
	begin catch
		raiserror(61001, 11, 1)
	end catch

end
