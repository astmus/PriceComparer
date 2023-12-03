create proc DebugInfoFind(@dateFrom datetime, @dateTo datetime, @xmlParameters nvarchar(4000), @outPath nvarchar(255)) as
begin

	set nocount on

	declare @paramXMLDoc int

	declare @Parameters table
	(	ParameterName	nvarchar(255)	not null,
		ParameterValue	nvarchar(4000)		null)

	if isnull(@xmlParameters, '') <> ''
	begin
		exec sp_xml_preparedocument @paramXMLDoc OUTPUT, @xmlParameters
		insert @Parameters (ParameterName, ParameterValue)
		select cast(Name as nvarchar(255)), cast(Value as nvarchar(4000)) FROM OPENXML (@paramXMLDoc, '/ROOT/Parameter',0) WITH (Name nvarchar(100), Value nvarchar(255))
	end

	declare @Session table
	(	SessionID		int				not	null)

	if exists(select 1 from @Parameters)
		insert @Session (SessionID)
		select distinct A.SessionID
		from DebugSession A with (index (DebugSessionDate))
		join DebugParameters B on B.SessionID=A.SessionID
		join @Parameters C on C.ParameterName=B.ParameterName and C.ParameterValue=B.ParameterValue
		where A.SessionDate>=@dateFrom and A.SessionDate<@dateTo
	else
		insert @Session (SessionID)
		select distinct A.SessionID
		from DebugSession A with (index (DebugSessionDate))
		join DebugParameters B on B.SessionID=A.SessionID
		where A.SessionDate>=@dateFrom and A.SessionDate<@dateTo

	select B.SessionID, B.SessionDate, C.ParameterID, C.ParameterName, C.ParameterValue
	from @Session A
	join DebugSession B on B.SessionID=A.SessionID
	join DebugParameters C on C.SessionID=A.SessionID

	declare @FileName nvarchar(255), @FilePath nvarchar(255), @ObjectToken int
	declare FileCursor cursor for select right(B.Name, CHARINDEX(N'\', REVERSE(B.Name)) -1)  FileName, B.Name as FilePath 
									from @Session A 
									join DebugFiles B on B.SessionID=A.SessionID
									where B.FileData is not null
	open FileCursor
	fetch next from FileCursor into @FileName, @FilePath
	while @@FETCH_STATUS = 0
	begin
		select @FileName = @outPath+N'\DTFA_'+replace(replace(replace(convert(nvarchar(30), getdate(), 121), ' ', '_'),':','-'), '.', '-')+'_'+@FileName
		EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
		EXEC sp_OASetProperty @ObjectToken, 'Type', 1
		EXEC sp_OAMethod @ObjectToken, 'Open'
		EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @FilePath
		EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @FileName, 2
		EXEC sp_OAMethod @ObjectToken, 'Close'
		EXEC sp_OADestroy @ObjectToken
		fetch next from FileCursor into @FileName, @FilePath
	end 
	close FileCursor
	deallocate FileCursor

	select B.SessionID, B.SessionDate, C.Name, C.ErrorMessage
	from @Session A
	join DebugSession B on B.SessionID=A.SessionID
	join DebugFiles C on C.SessionID=A.SessionID

end
