create proc SyncProductView (
	@Id		uniqueidentifier			-- Идентификатор товара
) as
begin
	
	-- Основная информация
	select	p.ID				as 'Id',
			p.SKU				as 'Sku',
			p.NAME				as 'Name',
			p.CHILDNAME			as 'ChildName',
			p.PUBLISHED			as 'IsActive',
			p.MANID				as 'BrandId',
			m.NAME				as 'BrandName',
			p.CHANGEDATE		as 'ChangedDate',
			case
				when (p.INSTOCK) > 0
					then p.INSTOCK
				else 0
			end as 'InStock'

	from PRODUCTS p
		join MANUFACTURERS m on m.ID = p.MANID
	where p.ID = @Id

	-- Сайты
	select	s.ID				as 'Id',
			s.HOST				as 'Host',
			s.NAME				as 'Name',
			s.DataBusSync		as 'DataBusSync'
	from SITEPRODUCTS l
		join SITES s on l.SITEID = s.ID and l.PRODUCTID = @Id and s.DataBusSync = 1

	-- Сайты, с которыми разорвана связь
	select	s.ID				as 'Id',
			s.HOST				as 'Host',
			s.NAME				as 'Name',
			s.DataBusSync		as 'DataBusSync'
	from SyncDeletedObjectSites del
		join SITES s on del.SITEID = s.ID and del.ObjectId = cast(@Id as nvarchar(50)) and s.DataBusSync = 1

end
