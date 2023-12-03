CREATE TABLE [dbo].[SUZPurchaseTasks] (
    [Id]           INT      IDENTITY (1, 1) NOT NULL,
    [TaskId]       INT      NOT NULL,
    [OrderNum]     INT      NOT NULL,
    [ExpectedDate] DATE     NOT NULL,
    [CreatedDate]  DATETIME DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_SUZPurchaseTasks_TaskId]
    ON [dbo].[SUZPurchaseTasks]([ExpectedDate] ASC)
    INCLUDE([TaskId]);


GO
create trigger tr_SUZPurchaseTasks_Delete on SUZPurchaseTasks after delete as
begin

	begin try

		set nocount on			-- отключает вывод сообщения о количестве обработанных строк
		set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)

		insert SUZPurchaseTasksArchive (TaskId, ExpectedDate, OrderNum, CreatedDate)
		select TaskId, ExpectedDate, OrderNum, CreatedDate
		from DELETED d 
	
	end try
	begin catch
		raiserror(60002, 11, 1)
	end catch

end
