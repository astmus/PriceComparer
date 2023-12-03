create procedure BarcodesTypeFind as
begin

	set nocount on
	
	begin try  
		update BarCodes set BarFormat='GTIN-8'--, ReportDate=getdate()
		from BarCodes
		where LEN(rtrim(BarCode))=8

		update BarCodes set BarFormat='GTIN-12'--, ReportDate=getdate()
		from BarCodes
		where LEN(rtrim(BarCode))=12

		update BarCodes set BarFormat='GTIN-13'--, ReportDate=getdate()
		from BarCodes
		where LEN(rtrim(BarCode))=13

		update BarCodes set BarFormat='GTIN-14'--, ReportDate=getdate()
		from BarCodes
		where LEN(rtrim(BarCode))=14

		update BarCodes set BarFormat='GTIN-14'--, ReportDate=getdate()
		from BarCodes
		where LEN(rtrim(BarCode))=17
		
		return 0
	end try
	begin catch 
		
		return 1
	end catch 

end
