create proc ActivityProcessView
(
	@EntityId	varchar(36)
)
as
begin

	select
		TypeId,
		pt.Name,
		SourceId,
		src.Name SrcName,
		UserId,
		u.NAME UserName,
		EntityTypeId,
		ent.Name,
		EntityId,
		StartTime,
		FinishTime
	from
		ActivityProcesses p
		JOIN ActivityProcessTypes pt ON p.TypeId = pt.Id
		JOIN ActivitySources src ON p.SourceId = src.Id
		JOIN users u ON p.UserId = u.ID
		JOIN ActivityEntities ent ON p.EntityTypeId = ent.Id
	where
		EntityId = @EntityId

end
