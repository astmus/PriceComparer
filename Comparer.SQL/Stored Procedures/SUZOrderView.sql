create proc SUZOrderView
(
	@Id				int				-- Идентификатор заказа в ShopBase
)
as
begin

	
	-- Заказ
	select 
		o.Id,
		o.PublicId,
		o.IsActive,
		o.StatusId,
		o.ClosedDate,
		o.CreatedDate
	from 
		SUZOrders o
	where
		o.Id = @Id

	-- Позиции
	select 
		i.Id,
		i.OrderId,
		i.GTIN,
		i.Quantity,
		i.PrintedQuantity,
		i.ProductId,
		i.IsActive,
		i.CreatedDate,

		isnull(p.SKU, 0)						as 'Sku', 
		isnull(m.NAME, '')						as 'Brand',
		isnull(p.NAME + ' ' + p.CHILDNAME, '')	as 'Name',
		isnull(p.INSTOCK, 0)					as 'Stock'
	from
		SUZOrderItems i
			left join PRODUCTS p on p.ID = i.ProductId
			left join MANUFACTURERS m on m.ID = p.MANID
	where
		i.OrderId = @Id

	-- Маркировка

	select
		dm.Id,
		dm.ItemId,
		dm.DataMatrix,
		dm.IsPrinted,
		dm.PrintedDate,
		dm.CreatedDate
	from
		SUZOrderItems i
			join SUZOrderItemDataMatrixes dm on dm.ItemId = i.Id
	where
		i.OrderId = @Id

end
