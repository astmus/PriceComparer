CREATE TABLE [dbo].[SmsSiteStatusTemplates] (
    [SiteId]     UNIQUEIDENTIFIER NOT NULL,
    [StatusId]   TINYINT          NOT NULL,
    [ServiceId]  INT              NULL,
    [DeliveryId] INT              NULL,
    [TemplateId] INT              NULL,
    UNIQUE NONCLUSTERED ([SiteId] ASC, [StatusId] ASC, [ServiceId] ASC, [DeliveryId] ASC, [TemplateId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_SmsSiteStatusTemplates]
    ON [dbo].[SmsSiteStatusTemplates]([SiteId] ASC, [StatusId] ASC);

