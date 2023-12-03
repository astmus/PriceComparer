create proc ExportRefundTasksCreate
(
	@ReceiptPublicId uniqueidentifier	-- Id документа ожидаемой приемки
)
 as
begin

	insert ExportRefundTasks (PublicId)
	values(@ReceiptPublicId)

	return 0
end
