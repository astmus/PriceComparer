create proc IsPerfumeryOrCosmetics
as
begin
		
	begin try

	    declare @IsParforCosm bit
	    set  @IsParforCosm=0
		declare @CosmParfIds table
		(	
			Id	uniqueidentifier	not null,
			Name nvarchar(1024)
			primary key (Id)
        )

		insert @CosmParfIds(Id,Name) exec _perfumCategories
		insert @CosmParfIds(Id,Name) exec _cosmeticsCategories_v2

		if exists (
			select 1
			from #ProductIds p
				join CategoriesProductsLinks cl on p.Id = cl.ProductId
				join @CosmParfIds cf on cf.Id = cl.CategoryId
		)
		set @IsParforCosm = 1

    select @IsParforCosm as 'IsParforCosm'

 	return 0

	end try
	begin catch		
		return 1
	end catch

end
