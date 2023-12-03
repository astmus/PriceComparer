create proc WarehouseGiftsMonitorPrepareView as
begin

	begin try
	
		declare 
			@Id				int,			
			@Gifts			nvarchar(max) = '',
			@SourseString	nvarchar(max) = '',
			@pos			int = 0,
			@posEnd			int = 0,
			@skus			nvarchar(4000) = '',
			@sku			nvarchar(15) = ''

		declare discCursor cursor for
		select Id, Gifts
		from #GiftDiscounts
		order by Id

		open discCursor  

			fetch next from discCursor into @Id, @Gifts

			while @@fetch_status = 0
			begin
			
				--select @Gifts
				select @SourseString = @Gifts

				select @pos = charindex('sets', @SourseString) 
				if @pos != 0 
					select @SourseString = substring(@SourseString, @pos + 6, len(@SourseString))

				select @pos = charindex('list', @SourseString) 
				if @pos != 0 
					select @SourseString = substring(@SourseString, @pos + 6, len(@SourseString))

				select @pos = charindex('sku', @SourseString) 
				while @pos != 0 begin
	
					select @posEnd = charindex(',', @SourseString)
					select @sku = substring(@SourseString, @pos + 5, @posEnd - @pos - 5)
					
					insert #GiftDiscountsSkus(DiscountId, Sku)
					values (@Id, cast(@sku as int))

					select @SourseString = substring(@SourseString, @posEnd + 7, len(@SourseString) - @posEnd - 6)
					select @pos = charindex('sku', @SourseString)
					if @pos != 0
						select @SourseString = substring(@SourseString, @pos, len(@SourseString) - @pos + 1)
					select @pos = charindex('sku', @SourseString)
					
				end
	
				fetch next from discCursor into @Id, @Gifts
			end

		close discCursor
		deallocate discCursor

		return 0
	end try
	begin catch
		return 1
	end catch

end
