create proc _loadPrePaymentKinds as
begin
	
	delete #prePaymentKinds
	insert #prePaymentKinds (Id) values (2),(4),(5),(8),(10),(12),(13),(19),(20),(21),(22),(23),(25),(26),(27),(28)

end
