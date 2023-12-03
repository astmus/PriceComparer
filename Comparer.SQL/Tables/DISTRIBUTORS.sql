﻿CREATE TABLE [dbo].[DISTRIBUTORS] (
    [ID]               UNIQUEIDENTIFIER NOT NULL,
    [NAME]             VARCHAR (255)    NOT NULL,
    [ACTIVE]           BIT              NOT NULL,
    [GOINPURCHASELIST] BIT              NULL,
    [FIRSTALWAYS]      BIT              NULL,
    [PHONE]            NVARCHAR (64)    NULL,
    [EMAIL]            NVARCHAR (1024)  NULL,
    [SENDMAIL]         BIT              NULL,
    [ADDRESS]          NVARCHAR (1024)  NULL,
    [COMMENT]          NVARCHAR (4000)  NULL,
    [PRIORITY]         TINYINT          NULL,
    [DEALERORDER]      INT              NULL,
    CONSTRAINT [DISTRIBUTORSPRIMARY] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [DISTRIBUTORSUNIQUEID] UNIQUE NONCLUSTERED ([ID] ASC),
    CONSTRAINT [DISTRIBUTORSUNIQUENAME] UNIQUE NONCLUSTERED ([NAME] ASC)
);

