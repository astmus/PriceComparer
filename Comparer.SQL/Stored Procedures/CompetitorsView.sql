create proc CompetitorsView 
(
	@IsActive			bit,				-- Активный
	@Name				varchar(100)		-- Наименование
) as
begin
	
	select 
		Id				as 'Id',
		IsActive		as 'IsActive',	
		Name			as 'Name',	
		OfficialName	as 'OfficialName'
   from  Competitors 
   where (@IsActive  is null or (@IsActive is not null and @IsActive=IsActive))
   and  (@Name is null or (@Name is not null and  Name like '%'+@Name+'%'))

end
