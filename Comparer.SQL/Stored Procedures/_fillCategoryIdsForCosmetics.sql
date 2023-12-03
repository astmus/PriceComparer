create proc _fillCategoryIdsForCosmetics as
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
		values 	('8A5FCD0C-4FEB-426B-AD39-80E86278491D'),
				('EEF8BBD9-49A7-4EBE-9900-95B9D5E3D09F'),
				('4AB72C18-32DA-43A5-A347-F297ED762D31'),
				('eddbedca-35c6-45ba-8402-8830055267a8'),
				('ddb82fc5-12b7-483c-ba74-69d4a732882d'),
				('09498a43-49f0-4f4a-8878-203876427d49'),
				('4839ae4b-ad3c-4f82-8f1b-238372d12a48'),
				('c0543858-cba7-47c1-91c0-b978d116d7ec'),
				('ef684de2-11a3-4560-b865-370026a52f7e'),
				('fd748b4c-8ad6-40ce-8243-01a401f34b1f'),
				('ed610289-c211-4154-b6f6-1fa2337490f3'),
				('9ea00266-0f07-400d-9e13-dd9e79271036'),
				('41c20d50-84e6-434b-809a-88c451c24937'),
				('67b5fb60-dcc6-468a-86d2-cff145eda082'),
				('d9435edd-2948-43b6-9800-b927d33a8986'),
				('0708a38f-81f4-406c-a334-8528cdb70fe5'),
				('f4f3bfce-018d-4af3-af16-23735c041823')

		insert #cosmeticsCategoriesId (CategoryId) select CategoryId from @parentIds

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

			insert #cosmeticsCategoriesId (CategoryId)
			select A.CategoryId 
			from @parentIds A
			left join #cosmeticsCategoriesId B on B.CategoryId = A.CATEGORYID
			where B.CATEGORYID is null
		end

		return 0

	end try 
	begin catch 
		return 1
	end catch

end
