create proc _fillCategoryIdsForTechnique as
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
		values 	('8794d585-d740-4e5a-b982-8f92bd362e59'),
				('20eb1b1d-2e9d-4b80-b62c-38a1cb21f203'),
				('159131e0-430a-44a7-9407-6c7f18fb2019'),
				('7660e450-4252-4099-b2ea-0ba8e152da75'),
				('4bb6ec4c-e031-48d3-9aa5-eef7ab3ca7e7'),
				('63afe63e-712d-4966-9af9-70f9ce67af55'),
				('cf0559d6-e609-4885-9bcb-6b5ba2cb76b6'),
				('369d5033-e103-4385-bdfd-a1ddf0a91403'),
				('3c4b19c4-8629-4f46-9674-4dceda68c669')

		insert #techniqueCategoriesId (CATEGORYID) select CategoryId from @parentIds

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

			insert #techniqueCategoriesId (CategoryId) 
			select A.CategoryId
			from @parentIds A
			left join #techniqueCategoriesId B on B.CategoryId = A.CategoryId
			where B.CategoryId is null
		end
		return 0
	end try 
	begin catch 
		return 1
	end catch

end
