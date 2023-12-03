create proc UTOrderInvoiceValidateSummaryView 
(
	@InvoiceId		int			-- Идентификатор УПД / накладной
)as
begin

	select 
		-- УПД
		ei.Id										as 'InvoiceId',
		ei.PublicId									as 'InvoicePublicId',
		ei.DocStatus								as 'DocStatus',
		ei.SignedStatus								as 'SignedStatus',
		ei.RecieverId								as 'ReceiverId',
		-- Черновик
		ed.Id										as 'DraftId',
		ed.OrderId									as 'OrderId',
		-- Контрагент
		cast(iif(c.TypeId = 1, 0, 1) as bit)		as 'IsInput',
		-- Клиент
		cl.ID										as 'ClientId',
		isnull(cl.ClientType, 0)					as 'ClientType',
		case
			when cl.Id is null 
				then cast(0 as bit)
			when cl.Id in 
					(
						'9FE81BD2-F9E0-4E04-8D3D-1023B7032AF4',		-- Тест
						'498EF36F-4211-4B72-8A40-BAE4175AEEA5','79CD61D2-988A-471E-B73F-71EBC63BB0AB','BA11349E-5EA0-465D-904A-61D6E381E6DC', -- Escentric 
						'5B0F388B-5131-4E50-99AB-EF643F0A8D90',	-- Новикова	Новикова Александровна
						'459723EB-F12A-44C6-85B0-BF0B7765AD21'	-- Тимошкова Тимошкова Александровна
					) 
				then cast(1 as bit)
			else 
				cast(0 as bit)
		end											as 'IsClientEscentric'

	from 
		EdoInvoices ei
			join Contractors c on c.Id = ei.SenderId 
			left join EdoDrafts ed on cast(ed.EntityId as nvarchar(36)) = ei.PublicId
			left join ContractorClientLinks l on l.ContraсtorId = ei.RecieverId
			left join CLIENTS cl on l.ClientId = cl.ID
	where ei.Id = @InvoiceId

end
