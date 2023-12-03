create proc EditDistributorComment (@DistId uniqueidentifier, @Comment varchar(255)) as
begin
	
	begin try 
			
		update DISTRIBUTORS set COMMENT = @Comment where ID = @DistId

		return 0
	end try 
	begin catch
		return 1
	end catch
			
end
