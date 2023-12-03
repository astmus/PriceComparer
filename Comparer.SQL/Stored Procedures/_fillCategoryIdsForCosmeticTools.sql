create proc _fillCategoryIdsForCosmeticTools as
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
		values 	('74df12ef-f15f-4e4e-8400-11dbcc1bc24a'),
				('0a8c87ac-403c-47dc-a23d-c0bc9e9c1b6a'),
				('3de9e8a4-9aa2-4df4-8351-9e2ae8fa088b'),
				('e35d461d-1a99-4764-b105-5854f47573aa'),
				('8c9ac5d2-ca52-46d6-989a-44279dd6d269'),
				('5004b044-acc6-440c-9dfc-6deee495f239'),
				('369d5033-e103-4385-bdfd-a1ddf0a91403'),
				('21519878-ade5-4425-a0fb-6ec71888e732'),
				('41c20d50-84e6-434b-809a-88c451c24937')

		insert #cosmeticToolsCategoriesId (CATEGORYID) select CategoryId from @parentIds

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

			insert #cosmeticToolsCategoriesId (CategoryId) 
			select A.CategoryId
			from @parentIds A
			left join #cosmeticToolsCategoriesId B on B.CategoryId = A.CategoryId
			where B.CategoryId is null
		end
		return 0
	end try 
	begin catch 
		return 1
	end catch

end
