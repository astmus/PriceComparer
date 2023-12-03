﻿CREATE TABLE [dbo].[MANUFACTURERS] (
    [ID]          UNIQUEIDENTIFIER NOT NULL,
    [NAME]        VARCHAR (255)    NOT NULL,
    [EXTRAUSED]   BIT              NOT NULL,
    [EXTRA]       INT              NOT NULL,
    [DESCRIPTION] NVARCHAR (1024)  DEFAULT ('') NOT NULL,
    [PUBLISHED]   BIT              DEFAULT ((1)) NOT NULL,
    [IsDeleted]   BIT              NULL,
    CONSTRAINT [MANUFACTURERSPRIMARY] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [MANUFACTURERSUNIQUEID] UNIQUE NONCLUSTERED ([ID] ASC),
    CONSTRAINT [MANUFACTURERSUNIQUENAME] UNIQUE NONCLUSTERED ([NAME] ASC)
);
