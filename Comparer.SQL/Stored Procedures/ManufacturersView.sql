create proc ManufacturersView 
(
	@Id			uniqueidentifier	= null		-- ИД
) as
begin
	
	select *
	from
		MANUFACTURERS
	where
		(@Id is null or Id = @Id)

end
