create proc SyncBrandView (
	@Id		uniqueidentifier			-- Идентификатор бренда
) as
begin
	
	-- Основная информация
	select	m.ID				as 'Id',
			m.PUBLISHED			as 'IsActive',
			m.NAME				as 'Name'
	from MANUFACTURERS m
	where m.ID = @Id

	-- Сайты
	select	s.ID				as 'Id',
			s.HOST				as 'Host',
			s.NAME				as 'Name',
			s.DataBusSync		as 'DataBusSync'
	from SITEMANUFACTURERS l
		join SITES s on l.SITEID = s.ID and l.MANUFACTURERID = @Id and s.DataBusSync = 1

	-- Сайты, с которыми разорвана связь
	select	s.ID				as 'Id',
			s.HOST				as 'Host',
			s.NAME				as 'Name',
			s.DataBusSync		as 'DataBusSync'
	from SyncDeletedObjectSites del
		join SITES s on del.SITEID = s.ID and del.ObjectId = cast(@Id as nvarchar(50)) and s.DataBusSync = 1

end
