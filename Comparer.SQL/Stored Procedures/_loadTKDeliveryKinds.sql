create proc _loadTKDeliveryKinds as
begin
	
	delete #tkDeliveryKinds
	insert #tkDeliveryKinds (Id) values 
		/*Почта России*/
		(5),(12),(14),(24),
		/*PickPoint*/
		(16),(17),(26),
		/*СДЭК*/
		(21),(22),
		/*DalliService*/
		(25)

end
