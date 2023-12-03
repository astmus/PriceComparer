create proc WmsShipmentDocumentDataMatrixesEdit_v2
(	
	@DocId				bigint,					-- Идентификатор документа
	@OrderId			uniqueidentifier		-- Идентификатор заказа		
) as
begin

	set nocount on

	begin try

		-- Вставляем новые записи
		insert OrderContentDataMatrixes (OrderId, ProductId, DataMatrix, StateId, FullDataMatrix, SourceId)
		select distinct @OrderId, w.ProductId, substring(w.DataMatrix, 1, 31), 1, w.DataMatrix, 2
		from #wmsShipmentOrderDataMatrixes w
			left join OrderContentDataMatrixes e on substring(w.DataMatrix, 1, 31) = e.DataMatrix and e.OrderId = @OrderId
		where 
			w.DataMatrix != '0'
			and e.OrderId is null

		return 0
	end try
	begin catch 
		return 1
	end catch

end
