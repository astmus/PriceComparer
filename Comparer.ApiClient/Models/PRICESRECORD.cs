#pragma warning disable 1573, 1591

using System.Collections.Generic;

using LinqToDB.Mapping;

namespace Comparer.DataAccess.Models
{
	[Table(Schema = "dbo", Name = "PRICESRECORDS")]
	public partial class PRICESRECORD
	{
		[PrimaryKey, Identity] public int RECORDINDEX { get; set; } // int
		[Column, NotNull] public Guid PRICEID { get; set; } // uniqueidentifier
		[Column, NotNull] public string NAME { get; set; } // nvarchar(1024)
		[Column, NotNull] public byte STATE { get; set; } // tinyint
		[Column, NotNull] public bool USED { get; set; } // bit
		[Column, NotNull] public double PRICE { get; set; } // float
		[Column, NotNull] public bool DELETED { get; set; } // bit
		[Column, NotNull] public string COMMENT { get; set; } // nvarchar(1024)
		[Column, NotNull] public string SKU { get; set; } // nvarchar(50)
		[Column, NotNull] public int STOCK { get; set; } // int
		[Column, NotNull] public int INSTOCK { get; set; } // int

		#region Associations

		/// <summary>
		/// LINKSFOREIGNPRICERECORD_BackReference (dbo.LINKS)
		/// </summary>
		[Association(ThisKey = "RECORDINDEX", OtherKey = "PRICERECORDINDEX", CanBeNull = true)]
		internal IEnumerable<LINK> LinksToPriceResords { get; set; }

		/// <summary>
		/// PRICESRECORDSFOREIGNPRICE (dbo.PRICES)
		/// </summary>
		[Association(ThisKey = "PRICEID", OtherKey = "ID", CanBeNull = false)]
		public PRICE PRICESRECORDSFOREIGNPRICE { get; set; }

		#endregion
	}
}
