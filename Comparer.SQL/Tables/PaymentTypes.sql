CREATE TABLE [dbo].[PaymentTypes] (
    [ID]             INT             IDENTITY (0, 1) NOT NULL,
    [TITLE]          VARCHAR (100)   NOT NULL,
    [DESCRIPTION]    NVARCHAR (1024) DEFAULT ('') NOT NULL,
    [ADAPTER]        NVARCHAR (25)   DEFAULT ('') NOT NULL,
    [PRICE]          FLOAT (53)      DEFAULT ((0.0)) NOT NULL,
    [PRICE_ORIGINAL] FLOAT (53)      DEFAULT ((0.0)) NOT NULL,
    [MIN_ORDER_SUM]  FLOAT (53)      DEFAULT ((0.0)) NOT NULL,
    [Max_Order_Sum]  FLOAT (53)      NULL,
    [SORT_ID]        INT             DEFAULT ((0)) NOT NULL,
    [IS_ACTIVE]      BIT             DEFAULT ((0)) NOT NULL,
    [IsDeleeted]     BIT             DEFAULT ((0)) NOT NULL,
    [SourceID]       INT             DEFAULT ((1)) NOT NULL,
    [DISABLED]       NVARCHAR (255)  DEFAULT ('') NOT NULL,
    [IsOld]          BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PaymetTypes] PRIMARY KEY CLUSTERED ([ID] ASC)
);

