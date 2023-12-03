create proc DistributorApiSettingsView (@DistId uniqueidentifier) as
begin

	select DistributorId, ApiHost, ApiUser, ApiPassword, ApiSecretToken, AnswerDataFormat
	from DistributorsApiSettings 
	where DistributorId = @DistId

end
