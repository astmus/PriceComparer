create proc CRPTDocsWithdrawalDataMatrixesView
(
	@DocNumber				nvarchar(128),			-- РќРѕРјРµСЂ РґРѕРєСѓРјРµРЅС‚Р°
	@OrderPublicNumber		nvarchar(16),			-- РџСѓР±Р»РёС‡РЅС‹Р№ РЅРѕРјРµСЂ Р·Р°РєР°Р·Р°
	@StatusId				int,					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ СЃС‚Р°С‚СѓСЃР°
	@DateFrom				DateTime,				-- РџРµСЂРёРѕРґ СЃ 
	@DateTo					DateTime				-- РџРµСЂРёРѕРґ РґРѕ
)
as
begin

	if @DateFrom is null
		select @DateFrom = '20210401'

	if @DateTo is null
		select @DateTo = '99991212'

	-- РЈСЃС‚Р°РЅРѕРІРєР° РґР°С‚ РЅР° РЅР°С‡Р°Р»Рѕ РґРЅСЏ
		select	
			@DateFrom = cast(cast(@DateFrom as date) as datetime),
			@DateTo = cast(cast(dateadd(d, 1, @DateTo) as date) as datetime)

	/*
	declare @Limit int
	select @Limit = 1000
	   
	select t.*
	from 
	(*/
		select
			d.Id						as 'DocumentId',
			d.PublicId					as 'PublicId',
			d.CreatedDate				as 'CreatedDate',

			d.OrderId					as 'OrderId',
			co.PUBLICNUMBER				as 'OrderPublicNumber',

			d.StatusId					as 'StatusId',
			d.CRPTStatusId				as 'CRPTStatusId',
			isnull(d.CRPTStatus, '')	as 'CRPTStatus',

			d.RegTryCount				as 'RegTryCount',
			d.NextTryDate				as 'NextTryDate',

			d.Error						as 'Error',
			d.Comments					as 'Comments'
			--row_number() over (order by d.CreatedDate desc) as 'RowNo'
		from 
			DataMatrixCRPTWithdrawalDocuments d 
				join CLIENTORDERS co on d.OrderId = co.ID
		where
			d.CreatedDate >= @DateFrom		and 
			d.CreatedDate < @DateTo			and 
			(@DocNumber is null	or (@DocNumber is not null and d.PublicId = @DocNumber))		and 
			(@OrderPublicNumber is null		or (@OrderPublicNumber	is not null and co.PUBLICNUMBER = @OrderPublicNumber))	and 
			(@StatusId is null		or (@StatusId	is not null and d.StatusId = @StatusId))
		order by
			d.CreatedDate desc
	/*) t
	where
		t.RowNo <= @Limit
	order by
		t.RowNo*/

end
