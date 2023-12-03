create proc UserActionStatistic (@ObjType int, @dBegin datetime, @dEnd datetime) as
begin

	select @dEnd=dateadd(dd, 1, @dEnd)

	select	B.NAME, 
			A.CREATEDDATE, 
			A.OBJECTTYPE,
			A.ACTIONTYPE,
			A.Quantity
	from USERS B
	join (select USERID, convert(date, CREATEDDATE) as CREATEDDATE, OBJECTTYPE, ACTIONTYPE, count(1) as Quantity
			from USERACTIONS
			where CREATEDDATE>=@dBegin and CREATEDDATE<@dEnd and OBJECTTYPE = @ObjType
			group by USERID, convert(date, CREATEDDATE), OBJECTTYPE, ACTIONTYPE) A on B.ID=A.USERID
	order by B.NAME, A.CREATEDDATE, A.OBJECTTYPE, A.ACTIONTYPE

end
