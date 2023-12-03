create proc SUZPurchaseTaskContentView
(
	@TaskId				int					-- Идентификатор задания на закупку
)
as
begin
	
	select 
		-- Задание на закупку
		t.TaskId							as 'TaskId',
		-- Содержимое
		isnull(c.FACTQUANTITY, 0)			as 'Quantity',
		-- Товар
		p.ID								as 'ProductId',
		p.SKU								as 'ProductSku',
		-- Штрихкоды
		b.Barcode							as 'GTIN'
	from 
		SUZPurchaseTasks t
			join PurchasesTasks pt on pt.CODE = t.TaskId
			join PurchasesTasksContent c on pt.CODE = c.CODE and c.ARCHIVE = 0 and c.DataMatrixState = 3 and isnull(c.FACTQUANTITY, 0) > 0
			join PRODUCTS p on p.SKU = c.SKU
			join CRPTTechCardBarcodes b on b.ProductId = p.ID
	where 
		t.TaskId = @TaskId
	order by
		t.OrderNum

end
