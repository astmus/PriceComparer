create proc DebugInfoStore(@xmlParameters nvarchar(4000), @xmlFiles nvarchar(4000), @sessionID int output) as
begin

	set nocount on

	declare @trancount int, @paramXMLDoc int, @fileXMLDoc int

	select @sessionID = 0
	select @trancount = @@TRANCOUNT

	if @trancount = 0
		begin transaction

	begin try 
		
		insert DebugSession (SessionDate) values (getdate())
		select @sessionID = @@identity

		insert DebugParameters (SessionID, ParameterName, ParameterValue)
		select @sessionID, 'xmlParameters', @xmlParameters
		insert DebugParameters (SessionID, ParameterName, ParameterValue)
		select @sessionID, 'xmlFiles', @xmlFiles
		
		exec sp_xml_preparedocument @paramXMLDoc OUTPUT, @xmlParameters
		insert DebugParameters (SessionID, ParameterName, ParameterValue)
		select @sessionID, cast(Name as nvarchar(255)), cast(Value as nvarchar(4000)) FROM OPENXML (@paramXMLDoc, '/ROOT/Parameter',0) WITH (Name nvarchar(100), Value nvarchar(255))

		if isnull(@xmlFiles, '') <> ''
		begin
			declare @FilePath nvarchar(255), @insertString nvarchar(4000), @File_Exists int
			exec sp_xml_preparedocument @fileXMLDoc OUTPUT, @xmlFiles
			declare FileCursor cursor for select Path FROM OPENXML (@fileXMLDoc, '/ROOT/File',0) WITH (Path nvarchar(255))
			open FileCursor
			fetch next from FileCursor into @FilePath
			while @@FETCH_STATUS = 0
			begin
				exec Master.dbo.xp_fileexist @FilePath, @File_Exists OUT
				if @File_Exists = 1
				begin
					select @insertString=	'insert into DebugFiles(SessionID, Name, FileData) '+
											'select '+cast(@sessionID as varchar(12))+', '''+@FilePath+''', (select * FROM OPENROWSET(BULK '''+@FilePath+''', SINGLE_BLOB) A)'  
					exec (@insertString)
				end
				else
					insert DebugFiles(SessionID, Name, ErrorMessage) values (@sessionID, @FilePath, 'РћС‚СЃСѓС‚СЃС‚РІСѓРµС‚ С„Р°Р№Р»')
				fetch next from FileCursor into @FilePath
			end 
			close FileCursor
			deallocate FileCursor
		end

		if @trancount = 0
			commit transaction
		return 0
	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		return 1
	end catch 

end
