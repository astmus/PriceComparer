create proc [dbo].[DeliveryServiceOrderEdit_v3] (
	@InnerId			uniqueidentifier,					-- Внутренний идентификатор заказа
	@OuterId			varchar(50)      = null,			-- Идентификатор заказа в ЛК ТК 
	@StatusId			int				 = null,			-- Идентификатор статуса ТК   
	@GroupId			int				 = null,
	@AccountId			int				 = null, 
	@LabelDowloadCount	int				 = null,			-- Кол-во скаченных этикеток
	@DispatchNumber		varchar(100)     = null,			-- Трек-номер
	@AuthorId			uniqueidentifier,					-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes			nvarchar(4000) out					-- Сообщение об ошибках
) AS
begin 

	 set @ErrorMes = ''
	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT

	begin try

		if @trancount = 0
			begin transaction

		-- Архивируем существующий заказ
		insert ApiDeliveryServiceOrdersArchive (InnerId, OuterId, ServiceId, StatusId, CreatedDate, ChangedDate, AuthorId, AccountId)
		select o.InnerId, o.OuterId, o.ServiceId, o.StatusId, o.CreatedDate, o.ChangedDate, o.AuthorId, o.AccountId
		from ApiDeliveryServiceOrders o
		where o.InnerId = @InnerId

		-- Обновляем существующий заказ
		update ApiDeliveryServiceOrders 
		set StatusId = isnull(@StatusId, StatusId),
			AuthorId = @AuthorId,
			ChangedDate = getdate(),
			OuterId = isnull(@OuterId, OuterId),
			AccountId = isnull(@AccountId, AccountId),
			DispatchNumber = ISNULL(@DispatchNumber, DispatchNumber )
		where InnerId = @InnerId

		update ApiDeliveryServiceGroupOrderLinks 
		set GroupId = isnull(@GroupId, GroupId)
		where OrderId = @InnerId

		update ApiDeliveryServiceOrdersInfo
		set  
			LabelDowloadCount = case when @LabelDowloadCount is null then LabelDowloadCount else isnull(LabelDowloadCount,0) + @LabelDowloadCount end
		where InnerId = @InnerId

		if(@DispatchNumber is not null)
		begin 
			update CLIENTORDERS
			set DispatchNumber = @DispatchNumber
			where Id = @InnerId
		end
		
		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = ERROR_MESSAGE()		
		return 1
	end catch

END
