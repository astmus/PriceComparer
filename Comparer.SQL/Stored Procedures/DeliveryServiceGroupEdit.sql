create proc DeliveryServiceGroupEdit 
(
	@GroupId		int,				-- Внутренний идентификатор группы
	@ExpectedDate	date = null,			-- Дата планируемой отправки
	@DocsLoaded		bit = null,				-- Документы загружены
	@IsSent			bit = null,				-- Группа отправлена
	@StatusId		int = null,				-- Статус группы
	@SentDate		datetime = null,			-- Дата отправки
	@AuthorId		uniqueidentifier,	-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes		nvarchar(255) out	-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''

	-- Если параметры не заданы, выходим
	if @ExpectedDate is null and @DocsLoaded is null and @SentDate is null and @IsSent is null and @StatusId is null
		return 0

	declare @trancount int
	select @trancount = @@TRANCOUNT

	begin try

		if @trancount = 0
			begin transaction
		
		-- Изменяем запись в основной таблице
		update ApiDeliveryServiceGroups
		set ChangedDate = getdate(),
		StatusId = isnull(@StatusId, StatusId)
		where Id = @GroupId

		-- Изменяем запись во вспомогательной таблице
		update ApiDeliveryServiceGroupsInfo 
		set	ExpectedDate	= isnull(@ExpectedDate, ExpectedDate),
			DocsLoaded		= case when @DocsLoaded is null then DocsLoaded else isnull(DocsLoaded,0) + 1 end,
			IsSent			= isnull(@IsSent, IsSent),
			SentDate		= isnull(@SentDate, SentDate)
		where Id = @GroupId

		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServiceGroupEdit!'		
		return 1
	end catch

end
