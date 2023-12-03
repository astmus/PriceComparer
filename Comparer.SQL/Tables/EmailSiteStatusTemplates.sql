CREATE TABLE [dbo].[EmailSiteStatusTemplates] (
    [SiteId]     UNIQUEIDENTIFIER NOT NULL,
    [StatusId]   TINYINT          NOT NULL,
    [TemplateId] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([SiteId] ASC, [StatusId] ASC, [TemplateId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_EmailSiteStatusTemplates]
    ON [dbo].[EmailSiteStatusTemplates]([SiteId] ASC, [StatusId] ASC);

