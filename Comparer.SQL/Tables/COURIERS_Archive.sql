CREATE TABLE [dbo].[COURIERS_Archive] (
    [ID]                  UNIQUEIDENTIFIER NOT NULL,
    [LASTNAME]            NVARCHAR (255)   NOT NULL,
    [NAME]                NVARCHAR (255)   NULL,
    [FATHERNAME]          NVARCHAR (255)   NULL,
    [DATIVEFULLNAME]      NVARCHAR (1024)  NULL,
    [PHONE]               NVARCHAR (10)    NULL,
    [ADRESS]              NVARCHAR (1024)  NULL,
    [PASSPORTDATA]        NVARCHAR (1024)  NULL,
    [MAXDELIVERIESPERDAY] INT              NOT NULL,
    [METRO]               TINYINT          NOT NULL,
    [UserName]            NCHAR (128)      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

