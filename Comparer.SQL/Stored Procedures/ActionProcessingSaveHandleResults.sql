create procedure ActionProcessingSaveHandleResults
(
	@ActionId			bigint					-- Идентификатор действия	
) as
begin

	set nocount on
	
	-- Проверка на существование обработчика
	begin try

		if exists 
		(
			select 1
			from 
				#handleResults r
				left join ActionsProcessingHandlers h on h.[Name] = r.HandlerName
			where 
				h.Id is null
		) begin

			-- Регистрируем новые обработчики
			insert ActionsProcessingHandlers (Name)
			select distinct r.HandlerName
			from 
				#handleResults r
				left join ActionsProcessingHandlers h on h.Name = r.HandlerName
			where 
				h.Id is null

		end

		-- Заполняем таблицу обработчиков
		update r 
		set 
			r.HandlerId = h.Id
		from 
			#handleResults r
			join ActionsProcessingHandlers h on h.Name = r.HandlerName

		insert ActionsProcessingHandleResults (ActionId, HandlerId, Successed, Error, StartAt, EndAt)
		select @ActionId, r.HandlerId, r.Successed, r.Error, r.StartAt, r.EndAt
		from #handleResults r

		return 0
	end try
	begin catch
		return 1
	end catch

end
