create proc WmsShipmentOrderDocumentExists (	
	@Number			varchar(50)			-- Номер документа
) as
begin

	if exists (select 1 from WmsShipmentOrderDocuments where Number = @Number)
		select cast(1 as bit) as 'Exists'
	else
		select cast(0 as bit) as 'Exists'

end
