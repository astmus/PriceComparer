create proc _fillCategoryIdsForMasks as
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
		values 	('fe2feca2-fb48-44a7-b720-b8c0c9475905'),
				('22377266-adac-47bb-a882-6b696e328311')

		insert #masksCategoriesId (CATEGORYID) select CategoryId from @parentIds

		while 1>0
		begin
			insert @childIds (CategoryId)
			select B.CATEGORYID 
			from @parentIds A
			join CATEGORIES B on B.PARENTID = A.CategoryId
		
			if @@rowcount=0
				return 0

			delete @parentIds

			insert @parentIds (CategoryId) 
			select CategoryId 
			from @childIds

			delete @childIds

			insert #masksCategoriesId (CategoryId) 
			select A.CategoryId
			from @parentIds A
			left join #masksCategoriesId B on B.CategoryId = A.CategoryId
			where B.CategoryId is null
		end
		return 0
	end try 
	begin catch 
		return 1
	end catch

end
