create proc CompetitiorsFeedSettingsView
(
	@FeedId		int,	-- Идентификатор Фида конкурента
	@IsDefault	bit		-- Признак, что требуются настройки по умолчанию, используемые для загрузки
) as
begin

	if (@IsDefault is null)
		set @IsDefault = 0

	select 
	-- Настройки
		s.Id				as 'Id',
		s.SourceTypeId		as 'SourceTypeId',
		s.SourceFormatId	as 'SourceFormatId',
		s.ServiceName		as 'ServiceName',
		s.SourceConfig		as 'SourceConfig',
		s.ConvertConfig		as 'ConvertConfig',
		s.MatchConfig		as 'MatchConfig',
		s.CreatedDate		as 'CreatedDate',
		s.ChangedDate		as 'ChangedDate',
	-- Привязка к Фиду
		l.FeedId			as 'FeedId',
		l.IsDefault			as 'IsDefault'

	from CompetitorsFeedSettingsLinks l
		join CompetitorsFeedSettings s on l.SettingsId = s.Id
	where
			(@FeedId is null or (@FeedId is not null and l.FeedId = @FeedId))
		and (@IsDefault = 0 or (l.IsDefault = @IsDefault))
	order by l.FeedId, l.SettingsId

end
