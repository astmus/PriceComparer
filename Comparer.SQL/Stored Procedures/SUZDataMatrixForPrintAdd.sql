create proc SUZDataMatrixForPrintAdd
(
	-- Out-параметры
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on;
	set @ErrorMes = ''

	declare 
		@OrderId int

	select @OrderId = Id from SUZOrders where PublicId = 'DataMatrixForPrint'	

	if @OrderId is null 
	begin
		set @ErrorMes = 'Не создан заказ для печати маркировок!'
		return 1
	end

	declare @trancount int
	select @trancount = @@trancount

	begin try

		if @trancount = 0
			begin transaction

		create table #newItems
		(	
			ProductId			uniqueidentifier	not null,
			DataMatrix			nvarchar(128)		not null
		)

		insert #newItems (ProductId, DataMatrix)	
		select 	s.ProductId, s.DataMatrix
		from #Items s			
			left join SUZOrderItemDataMatrixes dm on dbo.ParseBarCodeFromDataMatrix(dm.DataMatrix) = dbo.ParseBarCodeFromDataMatrix(s.DataMatrix)
		where 
			dm.Id is null

		-- Позиции
		insert SUZOrderItems (OrderId, GTIN, Quantity, ProductId)
		select distinct @OrderId, dbo.ParseBarCodeFromDataMatrix(i.DataMAtrix), 1, i.ProductId
		from #newItems i

		-- Маркировки
		insert SUZOrderItemDataMatrixes (ItemId, DataMatrix)
		select it.Id, i.DataMatrix
		from #newItems i
			join SUZOrderItems it on it.GTIN = dbo.ParseBarCodeFromDataMatrix(i.DataMAtrix)
		where 
			it.OrderId = @OrderId

		if @trancount = 0
			commit transaction

		return 0

	end try
	begin catch		
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch

end
