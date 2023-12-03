create proc DistributorFreeDaysView (@DistributorID uniqueidentifier, @minDate date, @maxDate date) as
begin

	select FREEDAY from DistributorFreeDays where DISTRIBUTORID=@DistributorID and FREEDAY>=@minDate and FREEDAY<=@maxDate order by FREEDAY

end
