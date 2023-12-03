create function GetTypeCategoryOfProduct(@ProductId uniqueidentifier)
				returns varchar(50)
as
begin
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
				break
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
		  
		if exists (
			select 1
			from CategoriesProductsLinks cl 
				join @perfumCategoriesId cf on cf.Id = cl.CategoryId
			where cl.PRODUCTID = @ProductId
		)
			return 'Парфюмерия'
			
		delete @childIds;
		delete @parentIds;

		declare @cosmeticsCategoriesId table
		(	
			Id	uniqueidentifier	not null
			primary key (Id))
       
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
				break

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
		 
		if exists (
			select 1
			from CategoriesProductsLinks cl 
				join @cosmeticsCategoriesId cf on cf.Id = cl.CategoryId
			where cl.PRODUCTID = @ProductId
		)
			return 'Косметика'
		return 'Другое'
end


/*
 select dbo.GetTypeCategoryOfProduct('638F94FE-DCDF-4AC5-94E8-E59565DDA4FF')
 */
