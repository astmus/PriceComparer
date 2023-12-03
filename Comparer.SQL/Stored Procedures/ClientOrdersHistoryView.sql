create proc ClientOrdersHistoryView (@ClientId uniqueidentifier) as
begin

	select o.ID,
			o.NUMBER,
            o.PUBLICNUMBER,
            o.SITENUMBER,
            o.DATE,
            o.FROZENSUM,
            o.SITEID,
            o.DELIVERYKIND,
            o.PAYMENTKIND,
            o.STATUS,
            o.SERVICECOMMENT,            
            o.KIND,            
            o.CREATORID,
            u.NAME as 'U_NAME'
	from CLIENTORDERS o
	left join USERS u on u.ID = o.CREATORID
	where ClientId = @ClientId
	order by o.DATE desc

end
