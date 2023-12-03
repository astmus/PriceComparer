CREATE TABLE [dbo].[BarCodes] (
    [SKU]            INT           NOT NULL,
    [BarCode]        NVARCHAR (39) NOT NULL,
    [BarFormat]      VARCHAR (10)  NULL,
    [CtrlDigit]      INT           NULL,
    [CtrlDigitCalc]  INT           NULL,
    [ValidSign]      BIT           DEFAULT ((0)) NOT NULL,
    [BatchNo1РЎ]     NCHAR (10)    NULL,
    [SessionIDPrice] INT           NULL,
    [ReportDate]     DATETIME      DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_BarCodes] PRIMARY KEY CLUSTERED ([SKU] ASC, [BarCode] ASC),
    CONSTRAINT [UN_BarCodes] UNIQUE NONCLUSTERED ([BarCode] ASC)
);

