create proc GetUserSessionInfo
(
	@UserId		uniqueidentifier,	-- РР” РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ	 
	@SessionId	int					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ СЃРµСЃСЃРёРё
)
as
begin

	set nocount on

	select 
		s.UserId		as 'UserId',
		u.Name			as 'UserName',
		s.SessionId		as 'SessionId',
		s.DateSession	as	'DateSession'
	from UserSession s 		
	join Users u on u.Id=s.UserId
	where   (@UserId is null or (@UserId is not null and s.UserId=@UserId))
		and (@SessionId is null or (@SessionId is not null and s.SessionId=@SessionId))

end


-- exec  GetUserSessionInfo  null, 2
