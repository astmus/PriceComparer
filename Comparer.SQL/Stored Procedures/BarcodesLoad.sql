create procedure BarcodesLoad as
begin

	set nocount on
	
	declare @trancount int
	select @trancount = @@TRANCOUNT
	
	begin try  
		if @trancount = 0
			begin transaction

		declare @RetValue int

		exec @RetValue=BarcodesPrepare
		if @RetValue = 1 begin
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
