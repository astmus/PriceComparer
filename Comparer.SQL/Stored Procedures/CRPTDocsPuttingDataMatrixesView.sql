create proc CRPTDocsPuttingDataMatrixesView
(
	 @DocNumber		nvarchar(128)		= null,
     @Status		int					= null, 
	 @DateFrom		date,
     @DateTo		date				= null	
)
as
begin 

	select 
		d.Id					as 'Id',
		d.PublicId				as 'DocNumber',

		d.StatusId				as 'StatusId',
		d.CRPTStatusId			as 'CRPTStatusId',
		d.CRPTStatus			as 'CRPTStatus',

		d.Comments				as 'Comments',
		d.Error					as 'Error',

		d.CreatedDate			as 'CreatedDate'
	from DataMatrixCRPTPuttingDocuments d
	where
		(@DocNumber is null or(@DocNumber is not null and @DocNumber = d.PublicId)) and
		(@Status	is null or(@Status	  is not null and @Status	 = d.StatusId)) and
		((@DateTo	is null and cast(d.CreatedDate as date) = @DateFrom) 
			or (@DateTo is not null and cast(d.CreatedDate as date) >= @DateFrom and cast(d.CreatedDate as date) <= @DateTo)) 
	order by d.CreatedDate, d.StatusId

end
