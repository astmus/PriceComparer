namespace Comparer.Entities
{
	public class PricesListItem
	{
		public int RECORDINDEX { get; set; } // int
		public Guid PRICEID { get; set; } // uniqueidentifier
		public string NAME { get; set; } // nvarchar(1024)
		public byte STATE { get; set; } // tinyint
		public bool USED { get; set; } // bit
		public double PRICE { get; set; } // float
		public bool DELETED { get; set; } // bit
		public string COMMENT { get; set; } // nvarchar(1024)
		public string SKU { get; set; } // nvarchar(50)
		public int STOCK { get; set; } // int
		public int INSTOCK { get; set; } // int
	}
}
