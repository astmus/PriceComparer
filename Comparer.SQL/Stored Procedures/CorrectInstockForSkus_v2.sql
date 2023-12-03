create proc CorrectInstockForSkus_v2 (	
	@DocType		int			-- Тип документа:
								-- 1 - Поступление
								-- 2 - Отгрузка
								-- 3 - Изменение качества
) as
begin

	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT

	declare @factor int = 1
	if @DocType = 1 set @factor = -1

	begin try 

		if @trancount = 0
			begin transaction
		
		-- Если изменение качества
		if @DocType = 3 begin

			-- Вставляем новые
			insert ProductsQualityInstock (ProductId, QualityId, Quantity)
			select c.ProductId, c.QualityId, c.Quantity
			from (
					select ProductId, QualityId, sum(Quantity) as 'Quantity'
					from #skusForInstockCorrect
					group by ProductId, QualityId
				) c
				left join ProductsQualityInstock i on i.ProductId = c.ProductId and i.QualityId = c.QualityId
			where i.ProductId is null

			-- Обновляем существующие (увеличиваем те качества, в которые перешли товары)
			update i
			set i.Quantity = i.Quantity + c.Quantity
			from (
					select ProductId, QualityId, sum(Quantity) as 'Quantity'
					from #skusForInstockCorrect
					group by ProductId, QualityId
				) c
				join ProductsQualityInstock i on i.ProductId = c.ProductId and i.QualityId = c.QualityId
			
			-- Обновляем существующие (ументшаем те качества, из которых перешли товары)
			update i
			set i.Quantity = i.Quantity - c.Quantity
			from (
					select ProductId, OldQualityId, sum(Quantity) as 'Quantity'
					from #skusForInstockCorrect
					group by ProductId, OldQualityId
				) c
				join ProductsQualityInstock i on i.ProductId = c.ProductId and i.QualityId = c.OldQualityId
								
			-- Удаляем нулевые
			delete c
			from (select distinct ProductId from #skusForInstockCorrect) i 
				join ProductsQualityInstock c on c.ProductId = i.ProductId
			where c.Quantity <= 0

		end else begin

			-- Записываем в историю текущие остатки и новые
			insert ProductInstockCorrectHistory (Sku, OldQuantity, NewQuantity)
			select p.Sku, p.INSTOCK, p.INSTOCK - (i.Quantity * @factor)			
			from PRODUCTS p 
				join (
					select ProductId, sum(Quantity) as 'Quantity' 
					from #skusForInstockCorrect 
					group by ProductId
				) i on p.Id = i.ProductId

			-- Выполняем корректировку остатков в таблице Товаров
			update p
			set p.INSTOCK = p.INSTOCK - (i.Quantity * @factor)
			from PRODUCTS p 
				join (
					select ProductId, sum(Quantity) as 'Quantity' 
					from #skusForInstockCorrect 
					group by ProductId
				) i on p.Id = i.ProductId

			-- Корректируем остатки в таблице Остатки в разрезе качества
			-- Если приемка
			if @DocType = 1 begin

				-- Обновляем существующие
				update i
				set i.Quantity = i.Quantity + c.Quantity
				from #skusForInstockCorrect c
					join ProductsQualityInstock i on i.ProductId = c.ProductId and i.QualityId = c.QualityId

				-- Создаем новые
				insert ProductsQualityInstock (ProductId, QualityId, Quantity)
				select c.ProductId, c.QualityId, c.Quantity
				from #skusForInstockCorrect c
					left join ProductsQualityInstock i on i.ProductId = c.ProductId and i.QualityId = c.QualityId
				where i.ProductId is null

			end else
			if @DocType = 2 begin

				-- Обновляем существующие
				update i
				set i.Quantity = i.Quantity - c.Quantity
				from #skusForInstockCorrect c
					join ProductsQualityInstock i on i.ProductId = c.ProductId and i.QualityId = c.QualityId

				-- Удаляем нулевые
				delete c
				from #skusForInstockCorrect i 
					join ProductsQualityInstock c on c.ProductId = i.ProductId
				where c.Quantity <= 0
				
			end

		end

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
