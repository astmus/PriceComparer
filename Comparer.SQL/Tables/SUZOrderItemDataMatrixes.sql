CREATE TABLE [dbo].[SUZOrderItemDataMatrixes] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [ItemId]      INT            NOT NULL,
    [DataMatrix]  NVARCHAR (128) NOT NULL,
    [IsPrinted]   BIT            DEFAULT ((0)) NOT NULL,
    [PrintedDate] DATETIME       NULL,
    [CreatedDate] DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_SUZOrderItemDataMatrixes_ItemId]
    ON [dbo].[SUZOrderItemDataMatrixes]([IsPrinted] ASC)
    INCLUDE([DataMatrix]) WHERE ([IsPrinted]=(1));


GO
CREATE NONCLUSTERED INDEX [ix_SUZOrderItemDataMatrixes_DataMatrix]
    ON [dbo].[SUZOrderItemDataMatrixes]([DataMatrix] ASC);


GO
create trigger tr_SUZOrderItemDataMatrixes_Printed_Update on SUZOrderItemDataMatrixes after update as
begin

	begin try

	set nocount on			-- отключает вывод сообщения о количестве обработанных строк
	set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)

	 --1.0 Добавляем в очередь на вывод распечатанные маркировки

	if exists 
	(
		select 1 
		from INSERTED i 
			join DELETED d on i.Id = d.Id
		where 
			i.IsPrinted = 1 and
			d.IsPrinted = 0
	) begin

	 	insert DataMatrixCRPTPuttingQueue (DataMatrix)
	 	select i.DataMatrix
	 		from INSERTED i
	 			join DELETED d on i.Id = d.Id and i.IsPrinted = 1 and d.IsPrinted = 0
	 			 
	 end


	end try
	begin catch
		raiserror(60001, 11, 1)
	end catch

end
