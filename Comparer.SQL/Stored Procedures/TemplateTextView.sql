create proc TemplateTextView(@Id int) as
begin

	if @Id is null
		select Theme, Body from Templates
	else
		select Theme, Body from Templates where Id=@Id

end
