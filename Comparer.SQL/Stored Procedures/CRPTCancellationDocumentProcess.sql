create proc CRPTCancellationDocumentProcess
(
	-- Документ  отмены
	@CRPTNumber					nvarchar(500),		-- Номер документа в ЦРПТ
	@CRPTCreatedDate			dateTime,			-- Дата создания документа в ЦРПТ
	@CRPTType					varchar(128),		-- Тип документа в ЦРПТ
	@CRPTStatus					varchar(128),		-- Статус документа в ЦРПТ

	@CancelledDocCRPTNumber		nvarchar(500),		-- Номер документа в ЦРПТ, который аннулируется

	@AuthorId					uniqueidentifier,	-- Идентификатор автора				
	-- Out-параметры
	@ErrorMes					nvarchar(4000) out	-- Сообщение об ошибках
)
as
begin

	set nocount on

	set @ErrorMes = ''
	
	--1.1  Проверяем Документ отмены
	if (@CRPTType not in ('UNIVERSAL_CANCEL_DOCUMENT')) begin

		set @ErrorMes = 'Некорректный документ отмены!'
		return 1
	end
	if (@CRPTStatus <> 'CHECKED_OK') begin

		set @ErrorMes = 'Документ отмены еще не обработан в ЦРПТ!'
		return 1
	end


begin try

	-- 1.1 Проверяем существует ли документ
	if exists (select 1 from CRPTDocuments d where d.CRPTNumber = @CancelledDocCRPTNumber) 
	begin

		if not exists (select 1 from CRPTDocuments d where d.CRPTNumber = @CancelledDocCRPTNumber
			 and ( (d.CancellationCRPTNumber <> @CRPTNumber) or (d.CRPTStatus <> 'CANCELLED') )
		) 
		begin

			-- 2.1 Обновление документа
			update d set
				d.CancellationCRPTNumber	= @CRPTNumber,
				d.CancellationDocDate		= @CRPTCreatedDate,
				d.CancellationRecevingDate	= getdate()
			from
				CRPTDocuments d
			where
				d.CRPTNumber = @CancelledDocCRPTNumber

		end else begin

			set @ErrorMes = 'Указанный документ уже аннулирован!'
			return 0
		end
		
	end
	else begin

		set @ErrorMes = 'Аннулируемый документ не найден!'			
		return 1

	end

end try
begin catch		
	set @ErrorMes = error_message()
	return 1
end catch

end
