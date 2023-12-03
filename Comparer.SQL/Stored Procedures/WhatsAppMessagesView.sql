create proc WhatsAppMessagesView
(	
	@OrderId			uniqueidentifier		-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р·Р°РєР°Р·Р°
) as
begin
    set nocount on

	select 
		m.OrderId, m.MessageStateId, m.TemplateId, m.CreatedDate 
	from 
		WhatsAppMessages m
	where
		m.OrderId = @OrderId
end
