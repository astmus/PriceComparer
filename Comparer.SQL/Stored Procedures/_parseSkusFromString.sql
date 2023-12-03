create proc _parseSkusFromString 
(	
	@SourseString	nvarchar(max)= '[{"type":"add_product","allow_count":1,"sets":[{"list":[{"sku":68531,"count":1},{"sku":68530,"count":1}]}]}]',		-- Строка с артикулами
	@SourceType		int = 1,			-- Тип данных на входе
										-- 1 - Int
										-- 2 - String
	@TargetType		int = 1				-- Тип данных на выходе
										-- 1 - Int
										-- 2 - String
) as
begin
	 
	-- Создаем таблицу, в которую будем записывать артикулы
	declare @table table (sku int)
 
	-- Создаем переменную, хранящую разделитель
	declare @delimeter nvarchar(1) = ','
 
	-- Определяем позицию первого разделителя
	declare @pos int = charindex(@delimeter, @SourseString)
 
	-- Создаем переменную для хранения одного артикула
	declare @sku nvarchar(15)
    
	while (@pos != 0)
	begin
		-- Получаем артикул
		set @sku = substring(@SourseString, 1, @pos-1)
		-- записываем в таблицу
		insert into @table (sku) values(cast(@sku as int))
		-- сокращаем исходную строку на
		-- размер полученного айдишника
		-- и разделителя
		set @SourseString = substring(@SourseString, @pos+1, len(@SourseString))
		-- определяем позицию след. разделителя
		set @pos = charindex(@delimeter ,@SourseString)
	end
	
	-- Выводим артикулы
	select Sku from @table
		
end
