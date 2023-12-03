create proc UserActivityView
(	
	@UserId				uniqueidentifier,		-- Идентификатор пользователя
	@SourceId			int,					-- Идентификатор источника действия
	@EntityId			int,					-- Идентификатор сущности
	@ObjectId			varchar(128),			-- Идентификатор обьекта над которым совершалась активность	
	@DateFrom			datetime,				-- Дата с
	@DateTo				datetime				-- Дата по
) as
begin

	-- Проверяем задан ли фильтр по виду совершенных действий
	if exists(select 1 from #Actions) begin
		
		select distinct
			b.Id			as	'Id',
			b.UserId		as  'UserId',
			b.SourceId		as  'SourceId',
			b.EntityId		as	'EntityId',
			b.ObjectId		as  'ObjectId',
			b.CreatedDate	as  'CreatedDate'
		from ActivityUserBatch b
			join ActivityBatchItems i on i.BatchId = b.Id
			join #Actions a on a.ActionId = i.ActionId
		where
			(@UserId	is null or (@UserId		is not null and b.UserId					= @UserId))						and
			(@SourceId	is null or (@SourceId	is not null and b.SourceId					= @SourceId))					and
			(@EntityId	is null or (@EntityId	is not null and b.EntityId					= @EntityId))					and
			(@ObjectId	is null or (@ObjectId	is not null and b.ObjectId					= @ObjectId))					and
			(@DateFrom	is null or (@DateFrom	is not null and cast(b.CreatedDate as date) >= cast(@DateFrom as date)))	and
			(@DateTo	is null or (@DateTo		is not null and cast(b.CreatedDate as date) <= cast(@DateTo as date)))

	end 
	else begin
		
		select distinct
			b.Id			as	'Id',
			b.UserId		as  'UserId',
			b.SourceId		as  'SourceId',
			b.EntityId		as	'EntityId',
			b.ObjectId		as  'ObjectId',
			b.CreatedDate	as  'CreatedDate'
		from ActivityUserBatch b
		where
			(@UserId	is null or (@UserId		is not null and b.UserId					= @UserId))						and
			(@SourceId	is null or (@SourceId	is not null and b.SourceId					= @SourceId))					and
			(@EntityId	is null or (@EntityId	is not null and b.EntityId					= @EntityId))					and
			(@ObjectId	is null or (@ObjectId	is not null and b.ObjectId					= @ObjectId))					and
			(@DateFrom	is null or (@DateFrom	is not null and cast(b.CreatedDate as date) >= cast(@DateFrom as date)))	and
			(@DateTo	is null or (@DateTo		is not null and cast(b.CreatedDate as date) <= cast(@DateTo as date)))

	end
end
