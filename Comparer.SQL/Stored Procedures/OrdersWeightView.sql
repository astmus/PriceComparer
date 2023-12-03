CREATE PROC OrdersWeightView
AS
BEGIN

	select
		o.ID, Sum(oc.QUANTITY * p.[WEIGHT]) as 'Weight'
	from
		CLIENTORDERS o
		JOIN #orders t ON o.ID = t.Id
		JOIN CLIENTORDERSCONTENT oc ON o.ID = oc.CLIENTORDERID
		JOIN PRODUCTS p ON oc.PRODUCTID = p.ID
	group by
		o.ID

END
