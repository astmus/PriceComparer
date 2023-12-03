create proc TracingRecordsDelete
(
	@Source		varchar(50),	
	@Object		varchar(100),
	@Method		varchar(10),
	@CodeAnswer	varchar(5),
	@DateBefore	datetime,
	@ErrorMes	nvarchar(4000) out
)
as
begin

	set nocount on
	set @ErrorMes = ''
		
	begin try
		
		delete TracingRecords 
		where 
			(@Source is null or (@Source is not null and Source = @Source))
		   and (@Method is null or (@Method is not null and Method = @Method))
		   and (@Object is null or (@Object is not null and [Object] = @Object))
		   and (@CodeAnswer is null or (@CodeAnswer is not null and CodeAnswer = @CodeAnswer))
		   and Date < @DateBefore

		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
