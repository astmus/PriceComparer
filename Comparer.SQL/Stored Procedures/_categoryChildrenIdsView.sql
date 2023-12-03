create proc _categoryChildrenIdsView (
	@Id		uniqueidentifier	--	Идентификатор родительской категории
)as
begin

	begin try
	 
		-- Итоговая таблица для идентификаторов подкатегорий
		declare @resultIds table
		(	
			Id		uniqueidentifier	not null,
			primary key (Id)
		)

		-- Таблица для идентификаторов подкатегорий
		declare @ChildrenIds table
		(	
			Id		uniqueidentifier	not null,
			primary key (Id)
		)

		-- Таблица для идентификаторов родительских категорий
		declare @ParentIds table
		(	
			Id		uniqueidentifier	not null,
			primary key (Id)
		)

		-- Добавляем родительскую категорию
		insert @ChildrenIds (Id) values (@Id)
		
		-- Добавляем родительскую категорию в итоговую таблицу
		insert @resultIds (Id) select Id from @ChildrenIds

		while 1 > 0 begin

			insert @ParentIds (Id)
			select B.CATEGORYID 
			from @ChildrenIds A
				join CATEGORIES B on B.PARENTID=A.Id
		
			if @@rowcount = 0 begin
				select Id from @resultIds
				return 0
			end

			delete @ChildrenIds

			insert @ChildrenIds (Id) 
			select Id 
			from @ParentIds

			delete @ParentIds

			insert @resultIds (Id) 
			select A.Id 
			from @ChildrenIds A
				left join @resultIds B on B.Id=A.Id
			where B.Id is null

		end

		select Id from @resultIds

		return 0
	end try 
	begin catch 
		return 1
	end catch

end
