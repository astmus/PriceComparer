create proc DataMatrixesRemarking
(
	-- Out - параметры
	@ErrorMes			nvarchar(2000)	null out		-- Сообщение об ошибке					
) as
begin

	set nocount on
    set @ErrorMes = ''

	declare
		@LastDmCount	int,
		@NewDmCount		int,
		@TotalCount		int

	--begin try

		select 
			@LastDMCount = count(distinct r.LastDM),
			@NewDMCount  = count(distinct r.NewDM),
			@TotalCount	 = count(1)
		from
			 #remarking r

		--select @LastDMCount, @NewDMCount, @TotalCount

		-- 1.1 Проверяем дубли среди выводимых маркировок
		if (@TotalCount > @LastDMCount) begin
			
			set @ErrorMes = 'Имеются дубли выводимых маркировок!'
			return 1
		end

		-- 1.2 Удаляем дубли среди заменяющих маркировок
		if (@TotalCount > @NewDMCount) begin
			
			set @ErrorMes = 'Имеются дубли заменяющих маркировок!'
			return 1
		end

		-- 1.3 Проверки на существование маркировки
		if not exists 
			(
				select 1 
				from
					#remarking r
					join DataMatrixes dm on r.LastDM = dm.DataMatrix 
			) 
		begin
			set @ErrorMes = 'Выводимые маркировки отсутствуют в системе!'
			return 1
		end

		if exists 
			(
				select 1 
				from
					#remarking r
					join DataMatrixes dm on r.NewDM = dm.DataMatrix 
			) 
		begin
				
			set @ErrorMes = 'Заменяющие маркировки уже добавлены в таблицу учета DataMatrixes!'
			return 1
		end

		declare 
			@trancount int
 		select @trancount = @@trancount

		if @trancount = 0
			begin transaction

			-- 2.0 Отмечаем выводимую маркировку
			update dm set
				dm.StatusId = 2
			from	
				#remarking r
				join DataMatrixes dm on r.LastDM = dm.DataMatrix
			where
				dm.DataMatrix = r.LastDM


			-- 3.0 Отмечаем добавляемую макркировку
			insert DataMatrixes
				(DataMatrix, StatusId)
			select
				r.NewDM, 1
			from 
				#remarking r
				left join DataMatrixes dm on r.NewDM = dm.DataMatrix
			where
				dm.Id is null

			-- 4.0 Вставка новой маркировки в очередь на обновление статусов
			insert DataMatrixStatusQueue
				(DataMatrix)
			select
				r.NewDM
			from 
				#remarking r
				left join DataMatrixStatusQueue q on r.NewDM = q.DataMatrix
			where
				q.Id is null
			UNION
			select
				r.LastDM
			from 
				#remarking r
				left join DataMatrixStatusQueue q on r.LastDM = q.DataMatrix
			where
				q.Id is null


		if @trancount = 0
			commit transaction

		return 0
	--end try

	--begin catch		
	--	if @trancount = 0
	--		rollback transaction
	--	set @ErrorMes =  error_message()
	--	return 1
	--end catch

end
