
using System.Collections.Generic;

using LinqToDB.Mapping;

namespace Comparer.DataAccess.Models
{
	[Table(Schema = "dbo", Name = "PRICES")]
	public partial class PRICE
	{
		[PrimaryKey, NotNull] public Guid ID { get; set; } // uniqueidentifier
		[Column, NotNull] public string NAME { get; set; } // varchar(255)
		[Column, Nullable] public Guid? DISID { get; set; } // uniqueidentifier
		[Column, NotNull] public double DISCOUNT { get; set; } // float
		[Column, NotNull] public byte DEFAULTCURRENCY { get; set; } // tinyint
		[Column, NotNull] public double TURNDOLLARSRATE { get; set; } // float
		[Column, NotNull] public string SHEET { get; set; } // varchar(1024)
		[Column, NotNull] public string NAMERANGE { get; set; } // varchar(16)
		[Column, NotNull] public string PRICERANGE { get; set; } // varchar(16)
		[Column, NotNull] public int FIRSTROW { get; set; } // int
		[Column, NotNull] public float MAXPRICECHANGE { get; set; } // real
		[Column, Nullable] public string STOPWORDS { get; set; } // varchar(6000)
		[Column, Nullable] public string FILENAME { get; set; } // varchar(1024)
		[Column, Nullable] public DateTime? FILEDATE { get; set; } // datetime
		[Column, Nullable] public string FILESHEETS { get; set; } // varchar(1024)
		[Column, NotNull] public string COMMENT { get; set; } // nvarchar(1024)
		[Column, NotNull] public string SKURANGE { get; set; } // varchar(16)
		[Column, NotNull] public string STOCKRANGE { get; set; } // nvarchar(16)
		[Column, NotNull] public string INSTOCKRANGE { get; set; } // nvarchar(16)
		[Column, NotNull] public bool ISACTIVE { get; set; } // bit

		#region Associations

		/// <summary>
		/// PRICESFOREIGNDISTRIBUTOR (dbo.DISTRIBUTORS)
		/// </summary>
		[Association(ThisKey = "DISID", OtherKey = "ID", CanBeNull = true)]
		public DISTRIBUTOR Distributor { get; set; }

		/// <summary>
		/// PRICESRECORDSFOREIGNPRICE_BackReference (dbo.PRICESRECORDS)
		/// </summary>
		[Association(ThisKey = "ID", OtherKey = "PRICEID", CanBeNull = true)]
		public IEnumerable<PRICESRECORD> PriceListItems { get; set; }

		#endregion
	}
}
