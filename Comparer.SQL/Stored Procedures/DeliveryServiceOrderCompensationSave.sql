create proc DeliveryServiceOrderCompensationSave
(
	@InnerId				uniqueidentifier,		-- Идентификатор заказ
	@CompensationNumber		nvarchar(20),			-- № платежного поручения о компенсации
	@CompensationDate		datetime,				-- Дата платежного поручения о компенсации
	-- Выходные параметры
	@ErrorMes				nvarchar(255) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''

	begin try

		-- Если записи о регистрации не существует
		if not exists (select 1 from ApiDeliveryServiceOrders where InnerId = @InnerId) 
		begin
			set @ErrorMes = 'В базе данных нет записи о регистрации заказа в ТК!'
			return 1
		end

		if exists (select 1 from ApiDeliveryServiceOrdersInfo where InnerId = @InnerId) 
		begin
			
			update a
			set
				a.CompensationNumber		= @CompensationNumber,
				a.CompensationDate			= @CompensationDate,
				a.CompensationUpdateDate	= getdate()
			from 
				ApiDeliveryServiceOrdersInfo a
			where 
				a.InnerId = @InnerId

			return 0

		end
		else 
		begin
			
			insert ApiDeliveryServiceOrdersInfo 
				(InnerId, LabelDowloadCount, CreatedDate, ChangedDate, CompensationNumber, CompensationDate)
			values 
				(@InnerId, 0, getdate(), getdate(), @CompensationNumber, @CompensationDate)

			return 0
		end
	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

end
