create proc QueueOutView_v2
(
	@PublicId			nvarchar(50) = null,	-- Идентификатор обмена (публичный)
	@Receiver			nvarchar(255)= null,	-- Идентификатор адаптера получателя
	@Limit				int			 = null		-- Максимальное количество загружаемых сообщений
) as
begin 

	--begin try 

		if @PublicId is not null

			select 
				Id					as 'Id', 
				PublicId			as 'PublicId', 
				ClassId				as 'ClassId',
				Receivers			as 'Receivers', 
				Body				as 'Body', 
				CreatedDate			as 'CreatedDate', 
				isnull(Error,'')	as 'Error'
			from SyncQueueOut
			where PublicId = @PublicId

		else if @Limit is not null begin 
		
			with outMessages as
			(
				select row_number() over (order by Id) as RowNo, *
				from SyncQueueOut
			)
			select 
				Id					as 'Id', 
				PublicId			as 'PublicId', 
				ClassId				as 'ClassId',
				Receivers			as 'Receivers', 
				Body				as 'Body', 
				CreatedDate			as 'CreatedDate', 
				isnull(Error,'')	as 'Error'
			from outMessages
			where RowNo <= @Limit and Receivers = isnull(@Receiver, Receivers)
					and TryCount < 3 and (NextTryDate is null or (NextTryDate is not null and getdate() > NextTryDate))
			order by Id
		
		end else begin
	
			select
				Id					as 'Id', 
				PublicId			as 'PublicId', 
				ClassId				as 'ClassId',
				Receivers			as 'Receivers', 
				Body				as 'Body', 
				CreatedDate			as 'CreatedDate', 
				isnull(Error,'')	as 'Error'
			from SyncQueueOut
			where Receivers = isnull(@Receiver, Receivers)
					and TryCount < 3 and (NextTryDate is null or (NextTryDate is not null and getdate() > NextTryDate))
			order by Id

		end
		
		/*return 0
	end try
	begin catch
		return 1
	end catch*/

end
