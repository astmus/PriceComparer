CREATE TABLE [dbo].[DiscountsGroupsLinks] (
    [GroupId]    INT NOT NULL,
    [DiscountId] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([GroupId] ASC, [DiscountId] ASC)
);

