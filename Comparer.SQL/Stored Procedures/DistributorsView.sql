create proc DistributorsView 
(
	@DistId				uniqueidentifier	= NULL,
	@IsActive			bit					= NULL,
	@SendRequestMode	int					= NULL 
) as
begin

   if @SendRequestMode is null
   		select 	d.ID as 'Id', d.NAME as 'Name', d.ACTIVE as 'Active', IsNull(d.EMAIL,'') as 'Email', IsNull(d.PHONE ,'') as 'Phone', IsNull(d.ADDRESS,'') as 'Address', d.FIRSTALWAYS as 'FirstAlways',
				d.DEALERORDER as 'DealerOrder'--, 
				--d.GOINAUTOCONTROL as 'UseInPriceCalc', d.GOINPURCHASELIST as 'UseInPurchase', d.DeliveryDaysFrom as 'DeliveryDaysFrom',
				--d.DeliveryDaysTo as 'DeliveryDaysTo', d.PRIORITY as 'Priority', d.PurchaseOrderType as 'PurchaseOrderType', d.ReturnDays as 'ReturnDays', 
				--d.ReturnEnable as 'ReturnEnable', 
				--d.ReturnEnableState as 'ReturnEnableState',
				--IsNull(d.COMMENT,'') as 'Comment', d.SENDMAIL as 'SendEmailForPurchase',
			 --   isNull(d.OfficialName,'') as 'OfficialName',  isNull(d.OfficialEmail,'') as 'OfficialEmail',
				--isNull(d.SendRequestMode,0) as 'SendRequestMode', isNull(d.DefaultRequestMethod,0) as 'DefaultRequestMethod', 
				--isNull(d.RequestPeriodCount,0) as 'RequestPeriodCount', isNull(d.RequestPeriodUnit,0) as 'RequestPeriodUnit' 
		from 
			[dbo].[DISTRIBUTORS] d	
		where 
			d.ID=isnull(@DistId, d.ID) and 
			d.ACTIVE=isnull(@IsActive, d.ACTIVE) 

	if @SendRequestMode is not null
   		select 	d.ID as 'Id', d.NAME as 'Name', d.ACTIVE as 'Active', IsNull(d.EMAIL,'') as 'Email', IsNull(d.PHONE ,'') as 'Phone', IsNull(d.ADDRESS,'') as 'Address', d.FIRSTALWAYS as 'FirstAlways',
				d.DEALERORDER as 'DealerOrder'
				--, d.GOINAUTOCONTROL as 'UseInPriceCalc', d.GOINPURCHASELIST as 'UseInPurchase', d.DeliveryDaysFrom as 'DeliveryDaysFrom',
				--d.DeliveryDaysTo as 'DeliveryDaysTo', d.PRIORITY as 'Priority', d.PurchaseOrderType as 'PurchaseOrderType', d.ReturnDays as 'ReturnDays', 
				--d.ReturnEnable as 'ReturnEnable', 
				--d.ReturnEnableState as 'ReturnEnableState',
				--IsNull(d.COMMENT,'') as 'Comment', d.SENDMAIL as 'SendEmailForPurchase',
			 --   isNull(d.OfficialName,'') as 'OfficialName',  isNull(d.OfficialEmail,'') as 'OfficialEmail',
				--isNull(d.SendRequestMode,0) as 'SendRequestMode', isNull(d.DefaultRequestMethod,0) as 'DefaultRequestMethod', 
				--isNull(d.RequestPeriodCount,0) as 'RequestPeriodCount', isNull(d.RequestPeriodUnit,0) as 'RequestPeriodUnit' 
		from [dbo].[DISTRIBUTORS] d	
		where d.ID=isnull(@DistId, d.ID) and 
			  d.ACTIVE=isnull(@IsActive, d.ACTIVE) 

			  --and
			  --d.SendRequestMode=d.SendRequestMode

end
