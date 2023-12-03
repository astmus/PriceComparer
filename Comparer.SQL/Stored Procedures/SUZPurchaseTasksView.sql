create proc SUZPurchaseTasksView
(
	@TaskId				int,					-- Идентификатор задания на закупку
	@ExpectedDate		date,					-- Дата поставки
	@DistributorId		uniqueidentifier,		-- Идентификатор поставщика
	@DistributorName	nvarchar(64)			-- Имя поставщика
)
as
begin
	
	select 
		-- Задания
		t.Id				as 'Id',
		t.TaskId			as 'TaskId',
		t.ExpectedDate		as 'ExpectedDate',
		t.CreatedDate		as 'CreatedDate',
		t.OrderNum			as 'OrderNum',
		-- Поставщик
		d.ID				as 'DistId',
		d.Name				as 'DistName'
	from 
		SUZPurchaseTasks t
			join PurchasesTasks pt on pt.CODE = t.TaskId
			join Distributors d on d.ID = pt.DistributorId
	where 
		(@TaskId is null or (@TaskId is not null and t.TaskId = @TaskId))							and
		(@ExpectedDate is null or (@ExpectedDate is not null and t.ExpectedDate = @ExpectedDate))	and
		(@DistributorId is null or (@DistributorId is not null and d.ID = @DistributorId))			and
		(@DistributorName is null or (@DistributorName is not null and d.NAME like '%' + @DistributorName + '%'))
	order by
		t.OrderNum

end
