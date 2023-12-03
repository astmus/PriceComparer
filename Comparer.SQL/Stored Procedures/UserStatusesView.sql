create proc UserStatusesView 
as
begin
		select s.Id as 'Id', s.Name as 'Name'
		from UserStatuses s 
end
