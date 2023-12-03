create proc WmsReturnedOrdersView
(
	@Partial		bit,
	@OrderNumber	nvarchar(25),
	@DateFrom		date,
	@DateTo			date
)
as
begin
   
   select distinct
	   w.ReturnedOrderId		as 'OrderId',
	   o.Number					as 'Number',
	   o.PublicNumber			as 'PublicNumber',
	   o.Date					as 'CreatedDate',
	   o.Status					as 'Status',
	   o.DeliveryKind			as 'DeliveryKind',
	   isnull(dt.TITLE,'?')		as 'DeliveryKindName',
	   w.WmsCreateDate			as 'ReturnedDate',
	   o.CreatorId				as 'AuthorId',
	   d.WmsCreateDate			as 'ShippedDate',
	   u.Name					as 'AuthorName'
   from WmsReceiptDocuments w
	   join ClientOrders o on o.Id = w.ReturnedOrderId and w.DocSource = 2	   
	   join Users u on o.CreatorId = u.ID
	   left join WmsShipmentDocuments d on d.PublicId = o.ID
	   left join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
   where
		o.PublicNumber = isnull(@OrderNumber,o.PublicNumber) and
        w.CreateDate >= isnull(@DateFrom,w.CreateDate) and 
		w.CreateDate < dateadd(dd,1,isnull(@DateTo,'20600101')) and
		(@Partial = 0 or (@Partial = 1 and o.STATUS <> 6))
	order by w.WmsCreateDate desc

end
