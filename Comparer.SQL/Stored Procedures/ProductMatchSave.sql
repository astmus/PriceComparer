create proc ProductMatchSave
as
begin

	return 0
	/*
	  update o
	  set o.ProductId = r.ProductId
	  from OrderContentDataMatrixes o
		join #Ids r on r.Id = o.Id
	*/

end
