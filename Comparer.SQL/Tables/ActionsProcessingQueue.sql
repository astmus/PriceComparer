CREATE TABLE [dbo].[ActionsProcessingQueue] (
    [Id]            BIGINT           IDENTITY (1, 1) NOT NULL,
    [ObjectId]      NVARCHAR (50)    NOT NULL,
    [OperationId]   INT              NOT NULL,
    [ObjectTypeId]  INT              NOT NULL,
    [ActionObject]  NVARCHAR (MAX)   NOT NULL,
    [PriorityLevel] INT              DEFAULT ((2)) NOT NULL,
    [InProcess]     BIT              DEFAULT ((0)) NOT NULL,
    [AuthorId]      UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]   DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ActionsProcessingQueue_Id]
    ON [dbo].[ActionsProcessingQueue]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ActionsProcessingQueue_Priority]
    ON [dbo].[ActionsProcessingQueue]([PriorityLevel] DESC);


GO
create trigger trActionsProcessingQueue_Delete on ActionsProcessingQueue after delete as
begin
		
	-- Архивируем запись
	insert ActionsProcessingQueueArchive 
	(
		Id, ObjectId, ObjectTypeId, OperationId, ActionObject, PriorityLevel, AuthorId, CreatedDate
	)
	select 
		d.Id, d.ObjectId, d.ObjectTypeId, d.OperationId, d.ActionObject, d.PriorityLevel, d.AuthorId, d.CreatedDate
	from 
		DELETED d
		left join ActionsProcessingQueueArchive a on a.Id = d.Id
	where
		a.Id is null
	
end
