CREATE TABLE [dbo].[UtPrices] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [DocId]       INT              NOT NULL,
    [ProductId]   UNIQUEIDENTIFIER NOT NULL,
    [Price]       FLOAT (53)       NOT NULL,
    [PriceTypeId] INT              NOT NULL,
    [CurrencyId]  INT              NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_UtPrices_DocNumber]
    ON [dbo].[UtPrices]([ProductId] ASC)
    INCLUDE([PriceTypeId], [CurrencyId]);


GO
CREATE NONCLUSTERED INDEX [ix_UtPrices_DocId]
    ON [dbo].[UtPrices]([DocId] ASC, [PriceTypeId] ASC);


GO
create trigger trUtPrices_Update on UtPrices after UPDATE as
begin

	begin try  

		set nocount on			-- отключает вывод сообщения о количестве обработанных строк
		set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)

		-- Архивируем запись
		insert UtPricesArchive
			(DocId, ProductId, Price, PriceTypeId, CurrencyId)
		select
			DocId, ProductId, Price, PriceTypeId, CurrencyId
		from
			DELETED

	end try
	begin catch  
		raiserror (54001, 11, 1)		
	end catch
	
end

GO
create trigger trUtPrices_Delete on UtPrices after DELETE as
begin

	begin try  

		set nocount on			-- отключает вывод сообщения о количестве обработанных строк
		set ansi_warnings off	-- отключает вывод массы сообщений (https://msdn.microsoft.com/ru-ru/library/ms190368(v=sql.120).aspx)

		-- Архивируем запись
		insert UtPricesArchive
			(DocId, ProductId, Price, PriceTypeId, CurrencyId)
		select
			DocId, ProductId, Price, PriceTypeId, CurrencyId
		from
			DELETED

	end try
	begin catch  
		--raiserror (54002, 11, 1)		
	end catch
	
end
