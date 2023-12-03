create proc ISOCodeForCountryView 
(
	@CountryName				varchar(100)			-- Название страны
) as
begin

	select
		Id				as 'Id',
		Name			as 'Name',
		DESCRIPTION		as 'Description',
		CodeISO			as 'CodeIso',
		Alfa2			as 'Alfa2'
	from 
		Countries
	where 
		Name = @CountryName

end
