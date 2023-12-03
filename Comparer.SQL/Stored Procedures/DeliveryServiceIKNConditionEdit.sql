CREATE PROCEDURE DeliveryServiceIKNConditionEdit
(
	@IKNId			int,					-- Идентификатор ИКН
	@Name			nvarchar(255),			-- Имя условия
	@Conditions		nvarchar(max),			-- Условие
	@OrderNum		int						-- Порядковый номер
) AS
BEGIN
	
	begin try

		UPDATE ApiDeliveryServicesIKNConditions SET
			Name		= isnull(@Name, Name),
			Conditions	= isnull(@Conditions, Conditions),
			OrderNum	= isnull(@OrderNum, OrderNum)
		WHERE
			IKNId = @IKNId

		RETURN 0

	end try
	begin catch		
		RETURN 1
	end catch

END
