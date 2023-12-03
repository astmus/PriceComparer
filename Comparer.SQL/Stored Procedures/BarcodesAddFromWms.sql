create procedure BarcodesAddFromWms as
begin

	set nocount on
	
	declare @trancount int
	select @trancount = @@trancount

	begin try  
		
		if not exists (select 1 from #wmsBarcodes) 
			return 0

		if @trancount = 0
			begin transaction
		
		-- Создаем новую сессию
		insert BarCodesSession (SessionBegin, SourceType)
		values (getdate(), 3)	-- Тип источника WMS

		declare @session int
		select @session = @@identity

		-- Запись данных о полученных штрих-кодах в протокол
		insert BarCodesSessionBatches (SessionID, BatchNo, BatchBegin, BatchWrite, BatchNull, BatchDuble)
		values(@session, '', getdate(), isnull((select count(1) from #wmsBarcodes), 0), 0, 0)

		-- Удаляем существующие штрих-коды, если они добавлены исключительно из WMS
/*		delete b
		from #wmsBarcodes w
			join PRODUCTS p on p.ID = w.ProductId
			join BarCodes b on b.SKU = p.SKU -- and b.BatchNo1С is null and b.SessionIDPrice is null
*/		
		-- Вставляем новые записи
		insert BarCodes (SKU, BarCode, CtrlDigit, CtrlDigitCalc, ValidSign, SessionIDPrice)
		select distinct p.SKU, replace(replace(w.BarCode, ' ', ''), '''', ''), null, null, 0, null
		from #wmsBarcodes w
			join PRODUCTS p on p.ID = w.ProductId
			left join BarCodes b on b.SKU = p.SKU and b.BarCode = replace(replace(w.BarCode, ' ', ''), '''', '')
		where b.SKU is null

		-- Вставляем записи в BarcodeProductIdLinks
		create table #Links
		(	
			ProductId	uniqueidentifier,
			Barcode		nvarchar(14)
		)
		insert #Links (ProductId, Barcode)
		select distinct b.ProductId, b.Barcode
		from #wmsBarcodes b

		declare 
			@Res		int				= -1,
			@ErrorMes	nvarchar(4000)	= ''
		exec @Res = BarcodeProductIdLinksCreate @ErrorMes out
		if @Res = 1 begin
			if @trancount = 0
				rollback transaction
			return 1
		end

		if @trancount = 0
			commit transaction

		return 0
	end try
	begin catch 
		if @trancount = 0
			rollback transaction
		return 1
	end catch 

end
