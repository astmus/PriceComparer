CREATE TABLE [dbo].[SyncQueueOut] (
    [Id]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [PublicId]    NVARCHAR (50)   DEFAULT (CONVERT([nvarchar](50),newid(),0)) NOT NULL,
    [ClassId]     INT             NOT NULL,
    [Receivers]   NVARCHAR (255)  NOT NULL,
    [Body]        NVARCHAR (MAX)  NOT NULL,
    [CreatedDate] DATETIME        DEFAULT (getdate()) NOT NULL,
    [Error]       NVARCHAR (4000) NULL,
    [ErrorStatus] INT             DEFAULT ((0)) NOT NULL,
    [TryCount]    INT             DEFAULT ((0)) NOT NULL,
    [NextTryDate] DATETIME        NULL,
    CONSTRAINT [PK_SyncQueueOut] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSyncQueueOutPublicId]
    ON [dbo].[SyncQueueOut]([PublicId] ASC);


GO
CREATE NONCLUSTERED INDEX [ixSyncQueueOutClassId]
    ON [dbo].[SyncQueueOut]([ClassId] ASC);


GO
create trigger trSyncQueueOut_Delete on SyncQueueOut after delete as
begin

	begin try  

		set nocount on			-- отключает вывод сообщения о количестве обработанных строк
		set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)

		insert SyncQueueOutArchive(id, PublicId, ClassId, Receivers, Body, CreatedDate, Error, ErrorStatus)
		select Id, PublicId, ClassId, Receivers, Body, CreatedDate, Error, ErrorStatus
		from DELETED 
		
	end try
	begin catch  
		raiserror (54002, 11, 1)		
	end catch
	
end
