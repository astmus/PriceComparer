CREATE TABLE [dbo].[SyncQueueIn] (
    [Id]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [PublicId]    NVARCHAR (50)   NOT NULL,
    [ClassId]     INT             NOT NULL,
    [TypeId]      INT             NOT NULL,
    [Sender]      NVARCHAR (255)  NOT NULL,
    [Body]        NVARCHAR (MAX)  NOT NULL,
    [CreatedDate] DATETIME        DEFAULT (getdate()) NOT NULL,
    [Error]       NVARCHAR (4000) NULL,
    [ErrorStatus] INT             DEFAULT ((0)) NOT NULL,
    [TryCount]    INT             DEFAULT ((0)) NOT NULL,
    [NextTryDate] DATETIME        NULL,
    CONSTRAINT [pkQueueIn] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSyncQueueInId]
    ON [dbo].[SyncQueueIn]([Id] ASC);


GO
create trigger trSyncQueueIn_Delete on SyncQueueIn after delete as
begin

	begin try  

		set nocount on			-- отключает вывод сообщения о количестве обработанных строк
		set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)
		
		insert SyncQueueInArchive (Id, PublicId, ClassId, TypeId, Sender, Body, CreatedDate, Error, ErrorStatus, TryCount)
		select Id, PublicId, ClassId, TypeId, Sender, Body, CreatedDate, Error, ErrorStatus, TryCount
		from DELETED 
		
	end try
	begin catch  
		raiserror (54001, 11, 1)		
	end catch
	
end
