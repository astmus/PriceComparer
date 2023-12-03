create proc DiscountActiveUpdate
(
		@DiscountId			int, 		-- Id скидки
		@IsActive			bit			-- Будет ли активна

) as
begin

set nocount off

	begin try
			update DISCOUNTS 
			set ACTIVE = @IsActive
			where ID = @DiscountId

		return 0
	end try	

	begin catch
		return 1
	end catch

end
