create proc DiscountsByFilterView_v3 
(
	@SiteId					uniqueIdentifier =NULL,	   --	Сайт, на котором действует скидка
	@DiscountType			int =NULL,				   --	Тип скидки
	@DiscountObjectType		int=NULL,				   --	Объект, на который распространяется скидка
	@OnlyActive				bit=NULL,				   --	Только активные
	@ActiveDate				datetime =NULL,			   --	Активная дата
	@Name					nvarchar(255)=NULL,         --   Наименование скидки
	@DiscountPublicId		uniqueIdentifier =NULL,	   --   Guid идентификатор скидки
	@MarketType				int =NULL				   --	Вид скидки
) as
begin

	set nocount on
		
	select  
	   d.[ID]
      ,d.[NAME]
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
	  ,[MarketType]
	  ,[CorrectPriceByPurchaseDisabled]
	  ,l.GroupId
	  ,g.Name as 'GroupName'
		from Discounts d
			left join DiscountsGroupsLinks l on d.Id = l.DiscountId
			left join DiscountGroups g on g.Id = l.GroupId
		where 
			(@DiscountPublicId is null or (@DiscountPublicId is not null and PublicGUID = @DiscountPublicId)) and
			(@SiteId is null or (@SiteId is not null and SiteId = @SiteId)) and 
			(@DiscountType is null or (@DiscountType is not null and DiscountType = @DiscountType)) and 
			(@DiscountObjectType is null or (@DiscountObjectType is not null and DiscountKind = @DiscountObjectType)) and
		    (@ActiveDate is null or (@ActiveDate is not null and DateFrom>=@ActiveDate)) and 
			(@ActiveDate is null or (@ActiveDate is not null and DateTo <= @ActiveDate)) and 
			(@OnlyActive is null or (@OnlyActive is not null and @OnlyActive = d.ACTIVE)) and
			(@Name is null or (@Name is not null and (d.[Name] = @Name or d.[Name] like '%'+ @Name +'%'))) and
			(@MarketType is null or (@MarketType is not null and d.MarketType = @MarketType))
		order by [CreatedDate] desc
	end
	return 0
