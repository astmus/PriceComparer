create proc WhatsAppMessageBufferPop
(	
	@PhoneNumber   		varchar(50)
) as
begin

	begin tran

	create table #BufferIds (Id int)

	insert into #BufferIds
	select 
		b.Id
	from 
		ClientDeliveredWhatsAppTemplatesBuffer b
	where 
		b.PhoneNumber = @PhoneNumber

	select m.[Message], m.TemplateId, m.CreatedDate
	from ClientDeliveredWhatsAppTemplatesBuffer b
	join #BufferIds bi on b.Id = bi.Id
	join WhatsAppTemplateMessages m on m.Id = b.MessageId
	order by b.CreatedDate desc

	delete from ClientDeliveredWhatsAppTemplatesBuffer
	where Id in (select Id from #BufferIds)

	drop table #BufferIds

	commit tran

end
