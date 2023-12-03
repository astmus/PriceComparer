create proc DiscountsViewByFilter 
(
	@SiteId					uniqueIdentifier =NULL,		-- Сайт, на котором действует скидка
	@DiscountType			int =NULL,					-- Тип скидки
	@DiscountObjectType		int=NULL,					-- Объект, на который распространяется скидка
	@OnlyActive				bit=NULL,					-- Только активные
	@ActiveDate				datetime =NULL,				-- Активная дата
	@Name					nvarchar(255)=NULL,			-- Наименование скидки
	@MarketType				int							-- Тип скидок согласно маркетинга
) as
begin
		
	select  
		[ID]
      ,[NAME]
      ,[DESCRIPTION]
      ,[SITEID]
      ,[DATEFROM]
      ,[DATETO]
      ,[DISCOUNTTYPE]
      ,[PRIORITY]
      ,[DATECREATE]
      ,[ACTIVE]
      ,[ACTIONS]
      ,[CONDITIONS]
      ,[DONOTSUM]
      ,[USEORIGINALPRICE]
      ,[STOPONMATCH]
      ,[DISCOUNTKIND]
      ,[PUBLICGUID]
      ,[AFFECTEDPRODUCTS]
      ,[NAMEFORCLIENTS]
      ,[ISADDABLE]
      ,[EXCLUDEDDISCOUNTGUIDS]
		from Discounts 
		where SiteId=isnull(@SiteId,SiteId) and 
			  DiscountType=	isnull(@DiscountType,DiscountType) and 
			  DiscountKind=	isnull(@DiscountObjectType,DiscountKind) and 
		      DateFrom>=isnull(@ActiveDate, DateFrom) and 
			  DateTo<=isnull(@ActiveDate, DateTo) and
			  (isnull(@OnlyActive,0)=0 or (@OnlyActive=1 and Active=1)) and
			  Name like '%'+ isnull(@Name, Name) +'%'
		order by Name desc

		return 0

end
