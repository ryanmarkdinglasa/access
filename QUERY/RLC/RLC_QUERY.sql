INSERT INTO TmpRLC ( 
TenantId, 
TerminalNumber, 
GrossAmount, 
TaxAmount, 
VoidAmount, 
VoidTransaction,
DiscountAmount, 
DiscountTransaction, 
ReturnAmount, 
ReturnTransaction, 
AdjustmentAmount, 
AdjustmentTransaction, 
ServiceChargeAmount, 
PreviousEOD, 
PreviousAmount, 
CurrentEOD, 
CurrentEODAmount, 
TransactionDate, 
NoveltyItemAmount, 
MiscItemAmount, 
LocalTax, 
CreditSalesAmount, 
CreditTaxAmount, 
NonVATSalesAmount, 
PharmaItemSalesAmount, 
NonPharmaItemSalesAmount, 
DisabilityDiscount, 
GrossSalesAmountNotSubectToPercentageRent, 
RePrintedAmount, 
RePrintedTransaction )

SELECT 
DFirst("RLC_TenantId","SysCurrent") AS [TenantId], 
"00000000000000" & Right([MstTerminal].[Terminal],2) AS [TerminalNumber], 
IIF([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL, FORMAT(((([GrossSales].[GrossSalesAmount]) + [TotalDiscount].[TotalDiscountAmount]) - (Nz([RLC_REFUND].[ReturnAmount],0))), '0.00000'),'0.00000') AS [GrossAmount], 
//IIF([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL, FORMAT(([TotalTax].[TotalTaxAmount]), '0.00000'),'0.00000') AS [TaxAmount],
IIf([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL, 0, FORMAT([GrossSales].[GrossSalesAmount], '0.00000')) AS [VoidAmount], 
IIF([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL, 0, 1) AS [VoidTransaction], 
IIF(([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL) AND ([MstDiscount].[Discount] = 'Senior Citizen Discount') AND ([MstDiscount].[Discount] = 'PWD'), FORMAT(([TotalDiscount].[TotalDiscountAmount]), '0.00000'),'0.00000') AS [DiscountAmount], 
IIF(([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL) AND ([MstDiscount].[Discount] = 'Senior Citizen Discount') AND ([MstDiscount].[Discount] = 'PWD'), ([TotalDiscount].[TotalDiscountAmount] > 0),1,0) AS [DiscountTransaction], 
MAX(FORMAT(Nz([RLC_REFUND].[ReturnAmount],0),'0.00000')) AS [ReturnAmount], 
MAX(Nz([RLC_REFUND].[ReturnTransaction],0)) AS [ReturnTransaction], 
IIF(([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL) AND ([MstDiscount].[Discount] = 'Senior Citizen Discount'), FORMAT(([TotalDiscount].[TotalDiscountAmount]), '0.00000')) AS [AdjustmentAmount],
IIF(([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL) AND ([MstDiscount].[Discount] = 'Senior Citizen Discount'), ([TotalDiscount].[TotalDiscountAmount] > 0),1,0) AS [AdjustmentTransaction], 
MAX(IIf(([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL), FORMAT(Nz([TotalServiceCharge].[ServiceCharge], 0), '0.00000'), '0.00000')) AS [ServiceChargeAmount],
0 AS [PreviousEOD],
0 AS PreviousAmount, 
Nz(DCount("Id","trncollection","[CollectionDate] < " & [Forms]![SysSettings]![RLC_DateMem])+1) AS CurrentEOD, 
IIF([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL, FORMAT(([GrossSales].[GrossSalesAmount]), '0.00000'),'0.00000') AS [CurrentEODAmount], 
FORMAT([TrnSales].[SalesDate], 'MM/dd/yyyy') AS [TransactionDate], 
0 AS [NoveltyItemAmount], 
0 AS [MiscItemAmount],
IIF([MstTax].[Tax] = 'LOCAL TAX', FORMAT(([TotalTax].[TotalTaxAmount]), '0.00000'), '0.00000') AS [LocalTax], 
[TmpPayTypeSales].[TotalCreditCardSales] AS [CreditSalesAmount],
[TmpPayTypeSales].[TotalCreditCardTax] AS [CreditTaxAmount],
IIF(([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL), FORMAT(([NonVATSales].[NonVATSalesAmount] ), '0.00000'),'0.00000') AS [NonVATSalesAmount],
0 AS [PharmaItemSalesAmount], 
0 AS [NonPharmaItemSalesAmount], 
MAX(IIF(([TrnCollection].[IsCancelled] = 0 OR [TrnCollection].[IsCancelled] IS NULL) AND ([MstDiscount].[Discount] = 'PWD'), FORMAT([TotalDiscount].[TotalDiscountAmount], '0.00000'), 0)) AS [DisabilityDiscount], 
0 AS [GrossSalesAmountNotSubectToPercentageRent],
FORMAT(Nz([RLC_REPRINT].[RePrintedAmount], 0), '0.00000') AS [RePrintedAmount],
Nz(IIF([RLC_REPRINT].[RePrintedTransaction]>0,1,0), 0) AS [RePrintedTransaction]

FROM 
    ((((((((((((((((((
        TrnSales 
    LEFT JOIN TrnSalesLine ON [TrnSalesLine].[SalesId] = [TrnSales].[Id]) 
    LEFT JOIN [TrnCollection] ON [TrnSales].[Id] = [TrnCollection].[SalesId]) 
    LEFT JOIN [TmpPayTypeSales] ON [TmpPayTypeSales].[SalesId] = [TrnSales].[Id])
    LEFT JOIN [TrnCollectionLine] ON [TrnCollectionLine].[CollectionId] = [TrnCollection].[Id]) 
    LEFT JOIN [SysCurrent] ON [TrnSales].[TerminalId] = [SysCurrent].[TerminalId]) 
    LEFT JOIN [MstTable] ON [TrnSales].[TableId] = [MstTable].[Id]) 
    LEFT JOIN [ItemsPurchase] ON [TrnSales].[Id] = ItemsPurchase.SalesId) 
    LEFT JOIN [MstTax] ON MstTax.Id = TrnSalesLine.TaxId) 
    LEFT JOIN [MstItem] ON MstItem.Id = [TrnSalesLine].ItemId) 
    LEFT JOIN [MstPayType] ON [MstPayType].[Id] = [TrnCollectionLine].[PayTypeId]) 
    LEFT JOIN [MstTerminal] ON [SysCurrent].[TerminalId] = [MstTerminal].[Id]) 
    LEFT JOIN [MstDiscount] ON [MstDiscount].[Id] = [TrnSalesLine].[DiscountId])
    LEFT JOIN [RLC_REPRINT] ON [RLC_REPRINT].[CollectionId] = [TrnCollection].[Id])
    LEFT JOIN [RLC_REFUND] ON [RLC_REFUND].[TerminalId] = [MstTerminal].[Id])
    LEFT JOIN (SELECT [SalesId], FORMAT(SUM(IIF([TrnSalesLine].[TaxAmount] = 0, [Amount], 0)), '0.00000') AS [NonVATSalesAmount] FROM [TrnSalesLine] GROUP BY [SalesId])  AS [NonVATSales] ON [TrnSales].[Id] = [NonVATSales].[SalesId]) 
    LEFT JOIN (SELECT [SalesId], SUM([Amount]) AS GrossSalesAmount FROM TrnSalesLine GROUP BY [SalesId])  AS GrossSales ON [TrnSales].[Id] = GrossSales.[SalesId]) 
    LEFT JOIN (SELECT [SalesId], SUM([Amount]) AS ServiceCharge FROM TrnSalesLine WHERE [ItemId] = 1 GROUP BY [SalesId])  AS TotalServiceCharge ON [TrnSales].[Id] = [TotalServiceCharge].[SalesId]) 
    LEFT JOIN (SELECT [SalesId], (SUM([TaxAmount])) AS TotalTaxAmount FROM TrnSalesLine GROUP BY [SalesId])  AS TotalTax ON [TrnSales].[Id] = TotalTax.[SalesId]) 
    LEFT JOIN (SELECT [SalesId], SUM(([DiscountAmount])*([Quantity])) AS TotalDiscountAmount FROM TrnSalesLine GROUP BY [SalesId])  AS TotalDiscount ON [TrnSales].[Id] = [TotalDiscount].[SalesId]
WHERE [TrnSales].[IsLocked] = True 
  AND [TrnCollection].[IsLocked] = True 
  AND DAY([TrnSales].[SalesDate]) = DAY([Forms]![SysSettings]![RLC_DateMem]) 
  AND MONTH([TrnSales].[SalesDate]) = MONTH([Forms]![SysSettings]![RLC_DateMem]) 
  AND YEAR([TrnSales].[SalesDate]) = YEAR([Forms]![SysSettings]![RLC_DateMem]) 
GROUP BY 