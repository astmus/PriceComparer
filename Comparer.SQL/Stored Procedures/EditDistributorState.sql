create proc EditDistributorState (@DistId uniqueidentifier, @State bit, @FieldName varchar(30)) as
begin
	
	begin try 

		if @FieldName = 'Active' 
			update DISTRIBUTORS set ACTIVE = @State where ID = @DistId
		--else if @FieldName = 'UseInPriceCalc'
		--	update DISTRIBUTORS set GOINAUTOCONTROL = @State where ID = @DistId
		else if @FieldName = 'UseInPurchase'
			update DISTRIBUTORS set GOINPURCHASELIST = @State where ID = @DistId
		else if @FieldName = 'SendMail'
			update DISTRIBUTORS set SENDMAIL = @State where ID = @DistId

		return 0
	end try 
	begin catch
		return 1
	end catch
			
end
