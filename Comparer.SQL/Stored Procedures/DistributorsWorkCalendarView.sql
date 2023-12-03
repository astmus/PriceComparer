create proc DistributorsWorkCalendarView (@DistId uniqueidentifier, @minDate date, @maxDate date) as
begin

	-- Переменная таблица списка поставщиков
	declare @distributors table (
		Id				uniqueidentifier	not null,
		Name			varchar(255)		not null,
		IsActive		bit					not null,
		UseInPurchase	bit					not null
		primary key(Id)
	)
	-- Переменная таблица списка нерабочих дат
	declare @notWorkDays table (
		DistId			uniqueidentifier	not null,
		NotWorkDate		datetime			not null		
	)
	
	-- Заполняем таблицу поставщиков
	if @DistId is null begin
		insert @distributors(Id, IsActive, Name, UseInPurchase)
		select d.ID, d.ACTIVE, d.NAME, d.GOINPURCHASELIST from DISTRIBUTORS d order by d.NAME
	end else begin
		insert @distributors(Id, IsActive, Name, UseInPurchase)
		select d.ID, d.ACTIVE, d.NAME, d.GOINPURCHASELIST from DISTRIBUTORS d where d.ID = @DistId
	end

	-- Заполняем таблицу нерабочих дней
	if exists(select 1 from @distributors) begin

		insert @notWorkDays(DistId, NotWorkDate)
		select d.Id, fd.FREEDAY 
		from @distributors d join DistributorFreeDays fd on d.ID = fd.DISTRIBUTORID
		where fd.FREEDAY>=@minDate and fd.FREEDAY<=@maxDate 

	end

	select Id, Name, IsActive, UseInPurchase from @distributors
	select DistId, NotWorkDate from @notWorkDays

end
