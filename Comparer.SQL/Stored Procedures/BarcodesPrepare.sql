create procedure BarcodesPrepare as
begin

	set nocount on
	
	begin try  
		declare @RetValue int

		exec @RetValue=BarcodesRead
		if @RetValue = 1 return 1

		exec @RetValue=BarcodesTypeFind
		if @RetValue = 1 return 1

		exec @RetValue=BarcodesCtrl
		if @RetValue = 1 return 1
		
		return 0
	end try
	begin catch 
		
		return 1
	end catch 

end
