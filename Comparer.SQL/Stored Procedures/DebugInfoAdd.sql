create proc DebugInfoAdd(@sessionID int, @xmlParameters nvarchar(4000)) as
begin

	set nocount on

	begin try 
		declare @paramXMLDoc int
		exec sp_xml_preparedocument @paramXMLDoc OUTPUT, @xmlParameters

		insert DebugParameters (SessionID, ParameterName, ParameterValue)
		select @sessionID, cast(Name as nvarchar(255)), cast(Value as nvarchar(4000)) FROM OPENXML (@paramXMLDoc, '/ROOT/Parameter',0) WITH (Name nvarchar(100), Value nvarchar(255))

		return 0
	end try 
	begin catch 
		return 1
	end catch 

end
