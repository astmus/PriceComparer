create proc SyncProtocolCellView (	
	@Id				bigint,			-- Идентификатор строки
	@CellName		nvarchar(50)	-- Имя столбца	
) as
begin

	if @CellName = 'Content'
		select Content as 'CellValue' from SyncProtocol where Id = @Id
	else if @CellName = 'ResponseAnswer'
		select ResponseAnswer as 'CellValue' from SyncProtocol where Id = @Id
	else
		select '' as 'CellValue'
	
end
