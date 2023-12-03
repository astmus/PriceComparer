CREATE PROC ApiDsOrdersForStatusUpdate (
	@ServiceId		int,		-- Идентификатор ТК	
	@AccountId		int			-- Идентификатор аккаунта	
)
AS
begin
	declare @today date = GetDate()

	-- Почта России
	If @ServiceId = 4
	begin 
			SELECT top 300
			o.PublicNumber		AS 'PublicNumber',
			o.Dispatchnumber	AS 'DispatchNumber',
			dso.StatusId		AS 'StatusId',
			dso.ChangedDate		AS 'StatusDate',
			dso.OuterId			as 'OuterId'
		FROM
			ApiDeliveryServiceOrders dso
			JOIN CLIENTORDERS o ON dso.InnerId = o.ID
		WHERE
			dso.ServiceId = 4
			AND dso.CreatedDate > '01/03/2021'
			AND dso.StatusId IN (1, 2, 3)	-- Создан, В_работе
	end else
	-- СДЕК
	If @ServiceId = 2 
	begin

		SELECT top 1000
			o.PublicNumber AS 'PublicNumber',
			o.Dispatchnumber AS 'DispatchNumber',
			dso.StatusId AS 'StatusId',
			dso.ChangedDate AS 'StatusDate',
			dso.OuterId as 'OuterId'
		FROM
			ApiDeliveryServiceOrders dso
			JOIN CLIENTORDERS o ON dso.InnerId = o.ID
		WHERE
			dso.ServiceId = 2
			AND dso.StatusId IN (1, 2, 3)	-- Создан, Получен ТК, Отгружен ТК 
			AND Not Exists (
				select 1 from ApiDeliveryServiceOrderStatusesHistory
				 where InnerId = dso.InnerId AND statusId = 11
				)
		ORDER BY
			CreatedDate desc
	end else
	-- Dalli Service
	If @ServiceId = 3 begin

		SELECT top 20
			o.PublicNumber		AS 'PublicNumber',
			o.Dispatchnumber	AS 'DispatchNumber',
			dso.StatusId		AS 'StatusId',
			dso.ChangedDate		AS 'StatusDate',
			dso.OuterId			as 'OuterId'
		FROM
			ApiDeliveryServiceOrders dso
			JOIN CLIENTORDERS o ON dso.InnerId = o.ID
		WHERE
			dso.ServiceId = 3
			AND DATEDIFF(day, dso.CreatedDate, @today) BETWEEN 3 AND 30
			AND dso.StatusId IN (1, 2, 3)	-- Создан, Получен ТК, Отгружен ТК
		ORDER BY
			CreatedDate desc
	end
end
