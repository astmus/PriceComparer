create proc _fillCategoryIdsForVirus as
begin

	begin try 

		declare @parentIds table
		(	
			CategoryId	uniqueidentifier	not null,
			primary key (CategoryId))

		declare @childIds table
		(	
			CategoryId	uniqueidentifier	not null,
			primary key (CategoryId)
		)

		insert @parentIds (CategoryId) 
		values 	('b70c86e3-fa3b-4b7b-957f-ca3f97753c9d'),	-- Гели
				('676e2309-3e62-444b-aa83-27414f6c4728'),	-- Салфетки
				('748a7695-00c0-449a-a642-9af61fbb58d5'),	-- Спреи
				('05bec6c0-92fa-4cfd-a16b-94e7672a0f7d'),	-- Защитные маски
				('857bfa35-f01a-42fc-aae2-8bb4283132b7')	-- Перчатки

		insert #virusCategoriesId (CategoryId) select CategoryId from @parentIds

		while 1 > 0 begin

			insert @childIds (CategoryId)
			select B.CATEGORYID 
			from @parentIds A
				join CATEGORIES B on B.PARENTID = A.CategoryId
		
			if @@rowcount = 0
				return 0

			delete @parentIds

			insert @parentIds (CategoryId)
			select CategoryId
			from @childIds

			delete @childIds

			insert #virusCategoriesId (CategoryId)
			select A.CategoryId 
			from @parentIds A
			left join #virusCategoriesId B on B.CategoryId = A.CATEGORYID
			where B.CATEGORYID is null
		end

		return 0

	end try 
	begin catch 
		return 1
	end catch

end
