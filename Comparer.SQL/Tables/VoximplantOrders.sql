CREATE TABLE [dbo].[VoximplantOrders] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]     UNIQUEIDENTIFIER NOT NULL,
    [StatusId]    INT              NOT NULL,
    [ScenarioId]  INT              DEFAULT ((0)) NOT NULL,
    [Error]       NVARCHAR (4000)  NULL,
    [ChangedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PM_VoximplantOrders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_VoximplantOrders_Id]
    ON [dbo].[VoximplantOrders]([OrderId] ASC);


GO
create trigger tr_VoximplantOrders_Insert_Update on VoximplantOrders after insert, update as
begin

	begin try  

		set nocount on			-- отключает вывод сообщения о количестве обработанных строк
		set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)

		-- Если запись обновляется
		if exists (select 1 from DELETED) begin
			
			insert VoximplantOrdersArchive (OrderId, StatusId, Error, ChangedDate, ScenarioId)
			select d.OrderId, d.StatusId, d.Error, d.ChangedDate, d.ScenarioId
			from DELETED d
			
		end

	end try
	begin catch  
		raiserror (53010, 11, 1)		
	end catch
	
end
