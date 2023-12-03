CREATE PROCEDURE DeliveryServiceIKNConditionCreate
(
	@IKNId			int,					-- Идентификатор ИКН
	@Name			nvarchar(255),			-- Имя условия
	@Conditions		nvarchar(max),			-- Условие
	@OrderNum		int,					-- Порядковый номер
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
) AS
BEGIN
	
	set nocount on
	set @ErrorMes = ''
		
	begin try

		-- Создаем условие
		INSERT ApiDeliveryServicesIKNConditions (IKNId, Name, Conditions, OrderNum)
		VALUES (@IKNId, @Name, @Conditions, @OrderNum)

		RETURN 0

	end try
	begin catch		
		set @ErrorMes = 'Ошибка выполнения хранимой процедуры DeliveryServiceIKNConditionCreate!'		
		RETURN 1
	end catch

END
