create proc _getPrePaymentKinds as
begin
	
	declare @prePaymentKinds table (Id	int	not null)
	insert @prePaymentKinds (Id) values (2)
	insert @prePaymentKinds (Id) values (4)
	insert @prePaymentKinds (Id) values (5)
	insert @prePaymentKinds (Id) values (8)
	insert @prePaymentKinds (Id) values (10)
	insert @prePaymentKinds (Id) values (12)
	insert @prePaymentKinds (Id) values (13)
	insert @prePaymentKinds (Id) values (19)
	insert @prePaymentKinds (Id) values (20)
	insert @prePaymentKinds (Id) values (21)
	insert @prePaymentKinds (Id) values (22)
	insert @prePaymentKinds (Id) values (23)
	insert @prePaymentKinds (Id) values (25)
	insert @prePaymentKinds (Id) values (26)
	insert @prePaymentKinds (Id) values (27)
	insert @prePaymentKinds (Id) values (28)

	select Id from @prePaymentKinds

end
