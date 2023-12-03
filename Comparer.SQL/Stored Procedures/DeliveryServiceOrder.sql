create proc DeliveryServiceOrder (
	@Id		uniqueidentifier			-- Идентификатор
) AS
begin

	select
		o.InnerId,
		o.OuterId,
		o.ServiceId,
		o.AccountId,
		o.IKNId
	from
		ApiDeliveryServiceOrders o
	WHERE
		o.InnerId = @Id

END
