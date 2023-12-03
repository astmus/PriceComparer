create proc TemplateView
(
	@Id				int					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ С€Р°Р±Р»РѕРЅР°
) as
begin

		select A.Id, A.TypeId, A.Theme, A.Name, A.Body, A.OperationDate, A.AuthorId, B.NAME as AuthorName
		from Templates A
			join USERS B on B.ID=A.AuthorId
		where
			A.Id = @Id
end
