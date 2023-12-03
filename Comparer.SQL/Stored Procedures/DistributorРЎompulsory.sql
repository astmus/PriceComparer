create proc DistributorРЎompulsory (@DistributorID uniqueidentifier, @dateBegin datetime, @dateEnd datetime) as
begin

	select A.DISTRIBUTORID,	B.SKU,	case	when B.VIEWSTYLEID = 4 then B.NAME + ' ' + B.CHILDNAME
											else B.NAME
									end as NAME, A.PLANPRICE, A.FACTPRICE, A.PLANQUANTITY, A.FACTQUANTITY
	from (	select DISTRIBUTORID, SKU, PLANPRICE, FACTPRICE, sum(PLANQUANTITY) as PLANQUANTITY, sum(FACTQUANTITY) as FACTQUANTITY
			from (	select B.CODE, B.SKU, row_number() over (partition by B.CODE, B.SKU order by B.ARCHIVEDATE desc) as rowno, B.DISTRIBUTORID, B.PLANQUANTITY, B.PLANPRICE, B.FACTQUANTITY, B.FACTPRICE, B.CURRENCY, B.STATUS
					from PurchasesTasksArchive A
					join PurchasesTasksContent B on B.CODE=A.CODE and B.DISTRIBUTORID=A.DISTRIBUTORID
					where A.PURCHASEDATE>=@dateBegin and A.PURCHASEDATE<@dateEnd and A.DISTRIBUTORID=@DistributorID ) A
			where rowno=1
			group by DISTRIBUTORID, SKU, PLANPRICE, FACTPRICE) A
	join PRODUCTS B on B.SKU=A.SKU
	
end
