create proc _perfumCategories

as
begin
begin try 

		declare @perfumCategoriesId table
		(	
			Id	uniqueidentifier	not null
			primary key (Id))
       

		declare @parentIds table
		(	
			Id	uniqueidentifier	not null,
			primary key (Id))

		declare @childIds table
		(	
			Id	uniqueidentifier	not null,
			primary key (Id)
		)

		insert @parentIds (Id) 
		values 	('4AE8494F-8C29-4919-94A7-47CD8F43116F'),
				('7BF2C258-A38D-491F-A938-93731D27BE0C'),
				('DD2059F6-D1EE-4B5E-8D54-E4A178E844C4')

		insert @perfumCategoriesId (Id) select Id from @parentIds

		while 1 > 0 begin

			insert @childIds (Id)
			select B.CATEGORYID 
			from @parentIds A
				join CATEGORIES B on B.PARENTID = A.Id
		
			if @@rowcount = 0
			begin
			select a.Id, b.C_Name
			from @perfumCategoriesId a
			join CATEGORIES B on B.CategoryID = A.Id
			return 0
			end

			delete @parentIds

			insert @parentIds (Id)
			select Id
			from @childIds

			delete @childIds

			insert @perfumCategoriesId (Id)
			select A.Id 
			from @parentIds A
			left join @perfumCategoriesId B on B.Id = A.ID
			where B.ID is null
		end

		return 0

	end try 
	begin catch 
		return 1
	end catch


end

-- exec _perfumCategories
