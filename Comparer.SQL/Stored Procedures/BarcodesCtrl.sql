create procedure BarcodesCtrl as
begin

	set nocount on
	
	begin try  
		update BarCodes set CtrlDigit=null, CtrlDigitCalc=null, ValidSign=0--, ReportDate=getdate()

		update BarCodes 
		set CtrlDigit=	case
							when substring(BarCode, LEN(rtrim(BarCode)), 1) in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
								then cast(substring(BarCode, LEN(rtrim(BarCode)), 1) as int)
							else null
						end,
			CtrlDigitCalc=dbo.BarcodesCtrlSumm(BarCode)--, ReportDate=getdate()

		update BarCodes set ValidSign=1--, ReportDate=getdate() 
		from BarCodes 
		where CtrlDigit=CtrlDigitCalc
		
		return 0
	end try
	begin catch 
		
		return 1
	end catch 

end
