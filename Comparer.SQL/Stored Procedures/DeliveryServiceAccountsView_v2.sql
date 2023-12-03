create proc DeliveryServiceAccountsView_v2 
(
	@Id				int			 = null,			-- Идентификатор ЛК
	@IknId			int			 = null,			-- Идентификатор ИКН
	@ServiceId		int			 = null,			-- Идентификатор ТК
	@AccountName	varchar(100) = null				-- Имя аккаунта
) as
begin

	create table #tempIds(	
		Id	int	not null,
		primary key(Id)
	)

	if @Id is not null begin

		insert into #tempIds
			select @Id

	end else
	if @IknId is not null begin

		insert into #tempIds
			select acc.Id as 'Id'
			from ApiDeliveryServicesAccounts acc
				join ApiDeliveryServicesIKNs i on i.AccountId = acc.Id and i.Id = @IknId
	
	end else 
	if @ServiceId is not null begin

		insert into #tempIds
			select acc.Id as 'Id'
			from ApiDeliveryServicesAccounts acc
			where acc.ServiceId = @ServiceId
			order by acc.Name

	end else 
	if @AccountName is not null
	begin
		insert into #tempIds
		select acc.Id as 'Id'
		from ApiDeliveryServicesAccounts acc
		where acc.Name = @AccountName
	end else
	begin 

		insert into #tempIds
			select acc.Id as 'Id'
			from ApiDeliveryServices ds
				join ApiDeliveryServicesAccounts acc on ds.Id = acc.ServiceId
			order by ds.Id, acc.Name

	end

	select
		acc.Id						as 'Id',
		acc.ServiceId				as 'ServiceId',
		ds.Name						as 'ServiceName',
		acc.Name					as 'Name',
		acc.Host					as 'Host',
		acc.AuthUser				as 'AuthUser', 
		acc.AuthPassword			as 'AuthPassword',
		acc.AuthType				as 'AuthType',
		isnull(acc.Token, '')		as 'Token',
		acc.TokenLifeTime			as 'TokenLifeTime',
		acc.TokenExpiry				as 'TokenExpiry',
		acc.IsDefault				as 'IsDefault',
		acc.StatusSyncDate			as 'StatusSyncDate',
		acc.ApiVersion				as 'ApiVersion',
 		acc.DopParams				as 'DopParams',
		acc.IsActive 				as 'IsActive',
		acc.Selector				as 'Selector',
		acc.UseAggregator			as 'UseAggregator'
	from #tempIds t
		join ApiDeliveryServicesAccounts acc on t.Id = acc.Id
		JOIN ApiDeliveryServices ds ON acc.ServiceId = ds.Id
	order by 
		acc.ServiceId, acc.Name

	--exec DeliveryServiceIKNsView @Id, @ServiceId

end
