create proc UserBoundEdit (
	@UserId			uniqueidentifier,
	@ParentId		uniqueidentifier	null,
	@ErrorMes	nvarchar(4000) out
) as
begin
	-- Обновление таблицы UsersBounds

		set @ErrorMes = ''
		begin try
			if not exists (select 1 from UsersBounds where UserId=@UserID)
			begin
				insert UsersBounds (UserId, ParentId)
				values (@UserId, @ParentId)
			end
			else
			begin 
				update UsersBounds
				set 
					ParentId = @ParentId
				where UserId = @UserId --and NAME=@Name

			end
			return 0
		end try
		begin catch
			set @ErrorMes = error_message()
			return 1
		end catch
end
