namespace Comparer.DataAccess.Dto
{
	public class PriceListProductDiffItem
	{
		public ProductInfo Product { get; init; }
		public string? MinPrice { get; init; }
		public double? MaxPrice { get; init; }
		public double? MaxPriceDiff { get; init; }
		public string? Notes { get; init; }

		//public double? PriceDiff { get; init; }
		//<DataGridTextColumn Header = "Price" Binding="{Binding Path=Price}"/>
		//<DataGridTextColumn Header = "MinPrice" Binding="{Binding Path=Email}"/>
		//<DataGridTextColumn Header = "" Binding="{Binding Path=Phone}"/>
		//<DataGridTextColumn Header = "" Binding="{Binding Path=Phone}"/>
		//<DataGridTextColumn Header = "" Binding="{Binding Path=Phone}"/>
		//<DataGridTextColumn Header = "Distributor" Binding="{Binding Path=Phone}"/>
		//<DataGridTextColumn Header = "Price List" Binding="{Binding Path=Phone}"/>
		//<DataGridTextColumn Header = "Notes"
	}
}
