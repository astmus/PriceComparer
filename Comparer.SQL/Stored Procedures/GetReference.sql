create proc GetReference
(
	@Type int	--  С‚РёРї СЃРїСЂР°РІРѕС‡РЅРѕР№ С‚Р°Р±Р»РёС†С‹
)
as
begin

	set nocount on

	begin try

	declare @TableName nvarchar(50)
	set @TableName = null

	declare @sql varchar(500)

	set @TableName=
	case @Type
		when 1 then 'CRPTDocumentInternalStatuses'	 
		when 2 then 'CRPTDocumentTypes'
		when 3 then 'CRPTDocumentStatuses'
		when 4 then 'CRPTDataMatrixInternalStatuses'
	end

	if @TableName is null return 1

	if @Type = 2
	-- Р’С‹РІРѕРґРёРј С‚РёРїС‹ РёРјРµСЋС‰РёС…СЃСЏ РґРѕРєСѓРјРµРЅС‚РѕРІ
		set @sql = 'select distinct 
						t.Id,
						t.Value, 
						t.Name
					from '+@TableName + ' t 
					join CRPTDocuments d on t.Value = d.CRPTType
					order by t.Id' 

	else 
		set @sql = 'select * from '+@TableName
	execute( @sql)

		return 0

	end try
	begin catch		
		return 1
	end catch

end
