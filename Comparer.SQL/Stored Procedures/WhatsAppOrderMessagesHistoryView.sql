create proc WhatsAppOrderMessagesHistoryView
(	
    @OrderId		uniqueidentifier,	-- Идентификатор заказа
    @TemplateId		int					-- Идентификатор шаблона
) as
begin

    select
        m.Id					as 'Id', 
		h.OrderId				as 'OrderId',
		m.ExternalId			as 'ExternalId', 
		m.PhoneNumber			as 'PhoneNumber', 
		m.StatusId				as 'StatusId', 
		m.CreatedDate			as 'CreatedDate',

		m.ErrorCode				as 'ErrorCode', 
		isnull(m.ErrorDescription, '')
								as 'ErrorDescription', 

		m.TemplateId			as 'TemplateId',
        t.TemplateName			as 'TemplateName',

		h.AuthorId				as 'AuthorId',
		isnull(u.[NAME], '')	as 'AuthorName'
    from
		WhatsAppOrderMessagesHistory h
		join WhatsAppTemplateMessages m on m.Id = h.MessageId
		join WhatsAppTemplates t on t.Id = m.TemplateId
		left join USERS u on u.ID = h.AuthorId
    where 
		h.OrderId = @OrderId and 
		(@TemplateId is null or (@TemplateId is not null and t.Id = @TemplateId))
	order by
		m.CreatedDate desc

end
