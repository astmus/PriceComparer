create proc DistributorApiOrdersView (	
	@OrderId			int,					-- РРґРµРЅС‚С‚С„С‚РєР°С‚РѕСЂ Р·Р°РєР°Р·Р°	
	@PublicNumber		nvarchar(50),			-- РќРѕРјРµСЂ Р·Р°РєР°Р·Р° РєР»РёРµРЅС‚Р°
	@DistributorId		uniqueidentifier,		-- РРґРµРЅС‚С‚С„С‚РєР°С‚РѕСЂ РїРѕСЃС‚Р°РІС‰РёРєР°	
	@ApiOrderId			nvarchar(50),			-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р·Р°СЏРІРєРё РїРѕСЃС‚Р°РІС‰РёРєСѓ РЅР° API-СЃРµСЂРІРёСЃРµ	
	@Status				int,					-- РЎС‚Р°С‚СѓСЃ Р·Р°СЏРІРєРё: 0 - РЅРµ РѕРїСЂРµРґРµР»РµРЅ, 1 - СЃРѕР·РґР°РЅР°, 2 - РІ СЂР°Р±РѕС‚Рµ, 3 - Р·Р°РєСЂС‹С‚Р°, 4 - РѕС‚РјРµРЅРµРЅР°	
	@CreateDateFrom		datetime,				-- Р”Р°С‚Р° СЃРѕР·РґР°РЅРёСЏ СЃ
	@CreateDateTo		datetime,				-- Р”Р°С‚Р° СЃРѕР·РґР°РЅРёСЏ РґРѕ	
	@ProductName		nvarchar(255),			-- РќР°РёРјРµРЅРѕРІР°РЅРёРµ С‚РѕРІР°СЂР°
	@ProductSku			int,					-- РђСЂС‚РёРєСѓР» С‚РѕРІР°СЂР°
	@OutSku				nvarchar(255),			-- РђСЂС‚РёРєСѓР» С‚РѕРІР°СЂР° РїРѕСЃС‚Р°РІС‰РёРєР°
	@Archived			bit						-- РђСЂС…РёРІРЅС‹Рµ
) as
begin

insert _Param (OrderId, PublicNumber, DistributorId, ApiOrderId, Status, CreateDateFrom, CreateDateTo, ProductName, ProductSku, OutSku, Archived)
values (@OrderId, @PublicNumber, @DistributorId, @ApiOrderId, @Status, @CreateDateFrom, @CreateDateTo, @ProductName, @ProductSku, @OutSku, @Archived)

	declare @selectSQL varchar(2800), @fromSQL varchar(1080), @whereSQL varchar(1030)

	set @selectSQL= 'select A.Id, A.Status, A.OrderId, A.PurchaseCode, B.PUBLICNUMBER, A.ApiOrderId, A.ApiStatus, C.ID as DistributorId, C.NAME as DistributorName, A.CreatedDate, A.CloseDate '
	set @fromSQL = 	'from DistributorsApiOrders A ' +
					'join CLIENTORDERS B on B.ID=A.OrderId ' +
					'join DISTRIBUTORS C on C.ID=A.DistributorId '
	if @Archived=1
		set @fromSQL = replace(@fromSQL, 'DistributorsApiOrders', 'DistributorsApiOrdersArchive')
	
	set @whereSQL = ''
	if @OrderId is not null
		set @whereSQL = dbo.addWhere(@whereSQL, 'A.Id='+cast(@OrderId as varchar(15)))
	if isnull(@PublicNumber,'') <> ''
		set @whereSQL = dbo.addWhere(@whereSQL, 'B.PUBLICNUMBER='''+@PublicNumber+'''')
	if @DistributorId is not null
		set @whereSQL = dbo.addWhere(@whereSQL, 'A.DistributorId='''+cast(@DistributorID as varchar(36))+'''')
	if isnull(@ApiOrderId,'') <> ''
		set @whereSQL = dbo.addWhere(@whereSQL, 'A.ApiOrderId='''+@ApiOrderId+'''')
	if @Status is not null
		set @whereSQL = dbo.addWhere(@whereSQL, 'A.Status='+cast(@Status as varchar(15)))
	if @CreateDateFrom is not null
		set @whereSQL = dbo.addWhere(@whereSQL, 'A.CreatedDate>='''+cast(@CreateDateFrom as varchar(30))+'''')
	if @CreateDateTo is not null
		set @whereSQL = dbo.addWhere(@whereSQL, 'A.CreatedDate<'''+cast(@CreateDateTo as varchar(30))+'''')
		
	if isnull(@ProductName,'')<>'' or @ProductSku is not null or isnull(@OutSku,'')<>''
	begin
		if isnull(@OutSku,'')<>'' and isnull(@ProductName,'')='' and @ProductSku is null
			set @whereSQL = dbo.addWhere(@whereSQL, 'exists(select 1 from DistributorsApiOrdersContent D where D.OrderId=A.Id')
		if isnull(@ProductName,'')<>'' or @ProductSku is not null
			set @whereSQL = dbo.addWhere(@whereSQL, 'exists(select 1 from DistributorsApiOrdersContent D join PRODUCTS E on E.ID=D.ProductId where D.OrderId=A.Id')

		if isnull(@OutSku,'')<>''
			set @whereSQL = dbo.addWhere(@whereSQL, 'D.OutSku='''+cast(@OutSku as varchar(15))+'''')
		if @ProductSku is not null
			set @whereSQL = dbo.addWhere(@whereSQL, 'E.SKU='+cast(@ProductSku as varchar(15)))
		if isnull(@ProductName,'')<>''
			set @whereSQL = dbo.addWhere(@whereSQL, 'replace(E.NAME+E.CHILDNAME, '' '', '''') like ''%'+replace(@ProductName, ' ', '') + '%''')
		set @whereSQL = @whereSQL + ')'
	end

	if @Archived=1
		set @whereSQL = replace(@whereSQL, 'DistributorsApiOrdersContent', 'DistributorsApiOrdersContentArchive')

	if @whereSQL<>''
			set @whereSQL='where '+@whereSQL
	
--	select @selectSQL + @fromSQL + @whereSQL
	exec (@selectSQL + @fromSQL + @whereSQL)
	
end
