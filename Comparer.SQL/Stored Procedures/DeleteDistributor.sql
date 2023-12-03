create proc DeleteDistributor (@DistId uniqueidentifier, @ErrorMes nvarchar(255) out) as
begin

	set nocount on
	declare @trancount int
	set @ErrorMes = ''

	begin try
		if @trancount = 0
			begin transaction

		-- Проверяем, проходил ли данный поставщик в закупке
		if exists (select 1 from PurchasesTasks t where t.DISTRIBUTORID = @DistId) or
			exists (select 1 from PurchasesTasksArchive t where t.DISTRIBUTORID = @DistId) begin
			
			-- Возвращаем отказ в удалении, указав причину
			set @ErrorMes = 'Вы не можете удалить данного поставщика, так как он есть в истории закупки!\r\n' +
							'На данный момент Вы можете его только скрыть, указав причину скрытия в комментарии.'
			return 2;

		end

		-- Проверяем, есть ли у поставщика прайс-листы
		if exists (select 1 from PRICES where DISID = @DistId) begin					

			-- Проверяем, есть ли "живые" связи записей прайс-листов с товарами из каталога
			if exists (select 1 
					from PRICES pr 
						join PRICESRECORDS rec on pr.ID = rec.PRICEID and pr.DISID = @DistId and rec.DELETED = 0 and rec.USED = 1 and rec.PRICE > 0
						join LINKS l on l.PRICERECORDINDEX = rec.RECORDINDEX
						join PRODUCTS p on p.ID = l.CATALOGPRODUCTID and p.DELETED = 0
					) begin
			
				-- Возвращаем отказ в удалении, указав причину
				set @ErrorMes = 'У этого поставщика есть прайс-листы, записи которых связаны с товарами из каталога!\r\n' +
								'Чтобы удалить поставщика, необходимо удалить все его прайс-листы.'
				return 2;

			end

		end

		-- Выполняем удаление
		-- Разрываем связи с товарами из каталога
		delete l from PRICES pr 
			join PRICESRECORDS rec on pr.ID = rec.PRICEID and pr.DISID = @DistId
			join LINKS l on l.PRICERECORDINDEX = rec.RECORDINDEX
		-- Удаляем записи прайс-листов
		delete rec from PRICES pr join PRICESRECORDS rec on pr.ID = rec.PRICEID and pr.DISID = @DistId
		-- Удаляем прайс-листы
		delete from PRICES where DISID = @DistId
		-- Удаляем поставщика
		delete from DISTRIBUTORS where ID = @DistId
				
		if @trancount = 0
			commit transaction
			
		return 0
	end try 
	begin catch 
		if @trancount = 0
			rollback transaction

		return 1
	end catch 
	
end
