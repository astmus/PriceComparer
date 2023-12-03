create proc _cosmeticsCategories_v2

as
begin
begin try 

		declare @cosmeticsCategoriesId table
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
		values 	
		('F9ADC5D3-5947-4C25-8EE3-1068D83699F0'),
		('3D6CE00B-066F-4505-81E6-2701F6DF096F'),
		('D441717E-806B-4236-86B9-365665726402'),
		('DE1E0269-6CB0-4284-B747-43E1BEE6F8B7'),
		('8A5FCD0C-4FEB-426B-AD39-80E86278491D'),
		('184872EB-82F9-4DCF-953C-8346A94B8D40'),
		('EEF8BBD9-49A7-4EBE-9900-95B9D5E3D09F'),
		('D22FE207-41A5-4D63-83AD-A8AE84F42733'),
		('05A8EA80-6D9E-4A6E-823A-B915C9244118'),
		('4AB72C18-32DA-43A5-A347-F297ED762D31')

		insert @cosmeticsCategoriesId (Id) select Id from @parentIds

		while 1 > 0 begin

			insert @childIds (Id)
			select B.CATEGORYID 
			from @parentIds A
				join CATEGORIES B on B.PARENTID = A.Id
		
			if @@rowcount = 0
			begin
			select a.Id, b.C_Name
			from @cosmeticsCategoriesId a
			join CATEGORIES B on B.CategoryID = A.Id
			return 0
			end

			delete @parentIds

			insert @parentIds (Id)
			select Id
			from @childIds

			delete @childIds

			insert @cosmeticsCategoriesId (Id)
			select A.Id 
			from @parentIds A
			left join @cosmeticsCategoriesId B on B.Id = A.ID
			where B.ID is null
		end

		return 0

	end try 
	begin catch 
		return 1
	end catch


end

-- exec _cosmeticsCategories_v2
