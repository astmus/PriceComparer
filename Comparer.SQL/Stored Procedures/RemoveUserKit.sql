CREATE PROCEDURE dbo.RemoveUserKit @kitId int, @userId uniqueidentifier AS
BEGIN
    DELETE FROM MonobrandKits 
	WHERE MonoId in (SELECT Id 
					FROM KitDefinitions 
					 WHERE CreatorId = @userId
					 AND Id = @kitId);
	DELETE FROM KitDefinitions
	WHERE Id = @kitId;
END;
