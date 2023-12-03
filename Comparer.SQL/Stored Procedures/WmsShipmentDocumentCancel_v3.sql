create proc WmsShipmentDocumentCancel_v3
( 
	@DocId  	bigint,					-- Id документа
	@AuthorId	uniqueidentifier,		-- Идентификатор автора 
	-- Выходные параметры
	@ErrorMes nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on;
	set @ErrorMes = ''

	begin try
	
		-- Архивируем устаревший Документ
		insert WmsShipmentDocumentsArchive (Id, WarehouseId, PublicId, Number, Operation, WmsCreateDate, ShipmentDate, ShipmentDirection, DocStatus, RouteId, OuterOrder, IsDeleted, Comments, AuthorId, CreateDate)	
		select Id, WarehouseId, PublicId, Number, Operation, WmsCreateDate, ShipmentDate, ShipmentDirection, DocStatus, RouteId, OuterOrder, IsDeleted, Comments, AuthorId, CreateDate
		from WmsShipmentDocuments 
		where Id = @DocId

		update WmsShipmentDocuments 
		set 
			DocStatus		= 11,
			AuthorId		= @AuthorId
		where 
			Id = @DocId

		return 0
	end try	
	begin catch
	set @ErrorMes = error_message()
		return 1
	end catch

end
