create proc SmsSiteStatusTemplateView (
	@SiteId			uniqueidentifier,	
	@StatusId		tinyint)   
 as
begin

	select t.Body as 'SmsTemplate'
	from SmsSiteStatusTemplates sms  
		join Templates t on  t.Id=sms.TemplateId
	 where sms.SiteId=@SiteId and sms.StatusId=@StatusId  

end
