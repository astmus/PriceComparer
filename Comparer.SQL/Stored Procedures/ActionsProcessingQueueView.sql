create procedure ActionsProcessingQueueView
(
	@Limit				int						-- Ограничение
) as
begin

	select 
		q.*
	from
	(
		select 
			q.Id				as 'Id',
			q.ObjectId			as 'ObjectId',
			q.ObjectTypeId		as 'ObjectTypeId',
			q.OperationId		as 'OperationId',
			q.ActionObject		as 'ActionObject',
			q.PriorityLevel		as 'PriorityLevel',
			isnull(u.NAME, '')	as 'AuthorName',
			row_number() over (order by q.PriorityLevel desc, q.Id) as RowNum
		from 
			ActionsProcessingQueue q
			left join USERS u on u.ID = q.AuthorId
		where 
			q.InProcess = 0
	) q
	where 
		q.RowNum <= @Limit
	order by 
		q.RowNum
	
end
