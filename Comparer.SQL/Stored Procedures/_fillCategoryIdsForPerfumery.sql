create proc _fillCategoryIdsForPerfumery as
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
		values 	('DD2059F6-D1EE-4B5E-8D54-E4A178E844C4')

		insert #perfumeryCategoriesId (CATEGORYID) select CategoryId from @parentIds

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

			insert #perfumeryCategoriesId (CategoryId) 
			select A.CategoryId
			from @parentIds A
			left join #perfumeryCategoriesId B on B.CategoryId = A.CategoryId
			where B.CategoryId is null
		end
		return 0
	end try 
	begin catch 
		return 1
	end catch

end
