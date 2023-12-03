create proc TracingRecordsView
(
	@Source		varchar(50),	
	@Object		varchar(100),
	@Method		varchar(10),
	@CodeAnswer	varchar(5),
	@DateForm	datetime,
	@DateTo		datetime
)
as
begin
	
	if @DateForm is null
		set @DateForm = '20000101'

	if @DateTo is null 
		set @DateTo =  dateadd(dd, 1, getdate())	

	select
		Id,
		Date,
		Source,	
		[Object],
		Method,
		CodeAnswer,
		EndPoint,
		Request,
		Answer
	from TracingRecords r
	where 
		(@Source is null or (@Source is not null and r.Source = @Source))
		and (@Method is null or (@Method is not null and r.Method = lower(@Method)))
		and (@Object is null or (@Object is not null and [Object] = @Object))
		and (@CodeAnswer is null or (@CodeAnswer is not null and r.CodeAnswer = @CodeAnswer))
		and r.Date > @DateForm and r.Date <= @DateTo
end

-- exec TracingRecordsView null, null, null, null, null, null
-- truncate table TracingRecords
