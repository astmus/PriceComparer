create proc OrderContentDataMatrixView
(
	@OrderId	uniqueidentifier
)
as
begin

	select 
		Id				as 'Id',
		DataMatrix		as 'DataMatrix'
	from OrderContentDataMatrixes
	where OrderId = @OrderId

end
