#pragma warning disable 1573, 1591

using System.Collections.Generic;

using LinqToDB.Mapping;

namespace Comparer.DataAccess.Models
{
	[Table(Schema = "dbo", Name = "PRODUCTS")]
	public partial class PRODUCT
	{
		[Column(), PrimaryKey, NotNull] public Guid ID { get; set; } // uniqueidentifier
		[Column(), NotNull] public string NAME { get; set; } // varchar(1024)
		[Column(), NotNull] public Guid MANID { get; set; } // uniqueidentifier
		[Column(), NotNull] public double PRICE { get; set; } // float
		[Column(), Nullable] public double? BASEPRICE { get; set; } // float
		[Column(), NotNull] public string LABEL { get; set; } // varchar(255)
		[Column(), Nullable] public string PARENTLABEL { get; set; } // varchar(255)
		[Column(), NotNull] public byte STATE { get; set; } // tinyint
		[Column(), NotNull] public bool USERCHANGED { get; set; } // bit
		[Column(), NotNull] public bool EXTRAUSED { get; set; } // bit
		[Column(), NotNull] public int EXTRA { get; set; } // int
		[Column(), NotNull] public bool AUTOUPDATE { get; set; } // bit
		[Column(), Nullable] public bool? AUTOUPDATETESTS { get; set; } // bit
		[Column(), Nullable] public bool? PRODUCTEXISTS { get; set; } // bit
		[Column(), NotNull] public bool PHOTOEXISTS { get; set; } // bit
		[Column(), NotNull] public int VIEWSTYLEID { get; set; } // int
		[Column(), NotNull] public string CHILDNAME { get; set; } // nvarchar(1024)
		[Column(), NotNull] public bool TESTER { get; set; } // bit
		[Column(), NotNull] public bool PUBLISHED { get; set; } // bit
		[Column(), NotNull] public DateTime CREATEDATE { get; set; } // datetime
		[Column(), NotNull] public DateTime CHANGEDATE { get; set; } // datetime
		[Column(), NotNull] public byte CORRECTEDSTATUS { get; set; } // tinyint
		[Column(), NotNull] public int INSTOCK { get; set; } // int
		[Column(), NotNull] public bool ISPROBIRKA { get; set; } // bit
		[Column(), NotNull] public string COMMENT { get; set; } // nvarchar(500)
		[Column(), NotNull] public bool DELETED { get; set; } // bit
		[Column("IS_PROMO"), NotNull] public bool IsPromo { get; set; } // bit
		[Column(), NotNull] public int TEMPLATEID { get; set; } // int
		[Column(), NotNull] public int SKU { get; set; } // int
		[Column(), NotNull] public bool ISNEW { get; set; } // bit
		[Column(), Nullable] public DateTime? ISNEWSTARTDATE { get; set; } // datetime
		[Column(), NotNull] public double WEIGHT { get; set; } // float
		[Column(), NotNull] public byte DEFAULTCURRENCY { get; set; } // tinyint

		#region Associations

		[Association(ThisKey = "ID", OtherKey = "CATALOGPRODUCTID", CanBeNull = true)]
		public IEnumerable<LINK> ProductCatalogproductsLinkFK { get; set; }

		#endregion
	}
}
