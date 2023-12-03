CREATE TABLE [dbo].[DataMatrixCRPTPuttingDocuments] (
    [Id]                    INT              IDENTITY (1, 1) NOT NULL,
    [PublicId]              NVARCHAR (128)   NULL,
    [ActionId]              INT              NOT NULL,
    [ActionDate]            DATETIME         NULL,
    [ContractorId]          INT              NOT NULL,
    [StatusId]              INT              NOT NULL,
    [CRPTStatus]            VARCHAR (128)    NULL,
    [CRPTStatusId]          INT              DEFAULT ((0)) NOT NULL,
    [CRPTType]              VARCHAR (128)    NULL,
    [WMSDocumentId]         BIGINT           NULL,
    [PrimaryDocumentName]   NVARCHAR (128)   NULL,
    [PrimaryDocumentNumber] NVARCHAR (128)   NULL,
    [PrimaryDocumentDate]   DATETIME         NULL,
    [PrimaryDocumentTypeId] INT              DEFAULT ((0)) NOT NULL,
    [Comments]              NVARCHAR (255)   NULL,
    [Error]                 NVARCHAR (4000)  NULL,
    [RegTryCount]           INT              DEFAULT ((0)) NOT NULL,
    [NextTryDate]           DATETIME         NULL,
    [AuthorId]              UNIQUEIDENTIFIER NULL,
    [CreatedDate]           DATETIME         DEFAULT (getdate()) NOT NULL,
    [ChangedDate]           DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_DataMatrixCRPTPuttingDocuments_PublicId]
    ON [dbo].[DataMatrixCRPTPuttingDocuments]([PublicId] ASC) WHERE ([PublicId] IS NOT NULL);


GO
create trigger tr_DataMatrixCRPTPuttingDocuments_Update_Delete on DataMatrixCRPTPuttingDocuments after update, delete as
begin

	begin try

	set nocount on			-- отключает вывод сообщения о количестве обработанных строк
	set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)

	insert DataMatrixCRPTPuttingDocumentsArchive (
				DocId, PublicId, 
				ActionId, ActionDate, 
				ContractorId,
				StatusId, CRPTStatus, CRPTStatusId,
				CRPTType, WMSDocumentId,
				PrimaryDocumentName,PrimaryDocumentNumber, PrimaryDocumentDate,PrimaryDocumentTypeId,
				Comments, Error,
				RegTryCount, NextTryDate,
				AuthorId, CreatedDate, ChangedDate
				)
		select 
				d.Id, d.PublicId, 
				d.ActionId, d.ActionDate, 
				d.ContractorId,
				d.StatusId, d.CRPTStatus, d.CRPTStatusId,
				CRPTType, WMSDocumentId,
				PrimaryDocumentName,PrimaryDocumentNumber, PrimaryDocumentDate,PrimaryDocumentTypeId,
				d.Comments, d.Error,
				d.RegTryCount, d.NextTryDate,
				d.AuthorId, d.CreatedDate, d.ChangedDate
				
		from DELETED d

	end try
	begin catch
		raiserror(61101, 11, 1)
	end catch

end
