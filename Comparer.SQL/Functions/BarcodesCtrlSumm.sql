create function BarcodesCtrlSumm(@BarCode varchar(25)) returns varchar(1) as
begin

	declare @sum int, @kof int, @Pos int, @Dit int, @CtrlDit int
	
	select @sum=0, @kof=1, @Pos=LEN(rtrim(@BarCode))-1
	while @Pos>0
	begin
		if substring(@BarCode, @Pos, 1) not in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') return null
		select @Dit=cast(substring(@BarCode, @Pos, 1) as int)
		
		if @kof=1
			select @kof=3
		else
			select @kof=1
			
		select @sum=@sum+@kof*@Dit
	
		select @Pos=@Pos-1
	end
	
	select @CtrlDit=10 - @sum % 10
	
	if @CtrlDit=10 return '0'
	return cast(@CtrlDit as varchar(1))
	
end
