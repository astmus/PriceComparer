CREATE TABLE [dbo].[SUZPurchaseTaskOrders] (
    [TaskId]  INT NOT NULL,
    [OrderId] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([TaskId] ASC, [OrderId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_SUZPurchaseTasks_TaskId]
    ON [dbo].[SUZPurchaseTaskOrders]([TaskId] ASC, [OrderId] ASC);


GO
create trigger tr_SUZPurchaseTaskOrders_Delete on SUZPurchaseTaskOrders after delete as
begin

	begin try

		set nocount on			-- отключает вывод сообщения о количестве обработанных строк
		set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)

		insert SUZPurchaseTaskOrdersArchive(TaskId, OrderId)
		select TaskId, OrderId
		from DELETED
	
	end try
	begin catch
		raiserror(60003, 11, 1)
	end catch

end
