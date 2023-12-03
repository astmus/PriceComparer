create proc SetDefaultCategory (
	@IdCategory		uniqueidentifier	--	Идентификатор категории
)as
begin

	declare @trancount int				-- Кол-во открытых транзакций
	select @trancount = @@TRANCOUNT

	begin try

    if @trancount = 0
			begin transaction

   -- убираем старую категорию по умолчанию
	update CategoriesProductsLinks
	set
	CP_Default=0
	from #IdsProduct  p
	where CategoriesProductsLinks.ProductId=p.Id
   
   -- устанавливаем новую категорию по умолчанию
	update CategoriesProductsLinks
	set
	CP_Default=1
	from #IdsProduct p 
	where CategoriesProductsLinks.ProductId=p.Id and CategoriesProductsLinks.CATEGORYID=@IdCategory

-- Вставляем новые записи
	insert into CategoriesProductsLinks (CategoryId, ProductId,CP_Default)
	select @IdCategory, p.Id,1 
	from #IdsProduct p 
		left join CategoriesProductsLinks cpl  on cpl.ProductID=p.Id and cpl.CATEGORYID=@IdCategory
	where cpl.ProductId is  null

-- Отмечаем изиенения
	update  Products set ChangeDate=GetDate()
	from  #IdsProduct p
	where Products.Id=p.Id

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


-- Тестировние

/*
truncate table #IdsProduct
insert #IdsProduct
values
('d7f2dde0-c94f-46d6-8ab8-04144a640188')

select * from #IdsProduct

 exec  SetDefaultCategory '7bf2c258-a38d-491f-a938-93731d27be0c'

*/
