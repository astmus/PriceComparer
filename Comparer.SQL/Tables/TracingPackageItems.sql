CREATE TABLE [dbo].[TracingPackageItems] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [PackageId]     INT            NOT NULL,
    [RowNo]         INT            NOT NULL,
    [RequestMethod] VARCHAR (25)   NOT NULL,
    [RequestQuery]  VARCHAR (500)  NOT NULL,
    [RequestBody]   VARCHAR (4000) NULL,
    [RequestStart]  DATETIME       NOT NULL,
    [RequestEnd]    DATETIME       NOT NULL,
    [ResponseCode]  INT            NOT NULL,
    [ResponseBody]  VARCHAR (4000) NULL,
    [ResponseError] VARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

