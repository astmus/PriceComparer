#pragma warning disable 1573, 1591

using LinqToDB.Mapping;

namespace Comparer.DataAccess.Models
{
	[Table(Schema = "dbo", Name = "LINKS")]
	public partial class LINK
	{
		[PrimaryKey, NotNull] public Guid ID { get; set; } // uniqueidentifier
		[Column, NotNull] public Guid CATALOGPRODUCTID { get; set; } // uniqueidentifier
		[Column, NotNull] public int PRICERECORDINDEX { get; set; } // int

		#region Associations

		/// <summary>
		/// LINKSFOREIGNCATALOGPRODUCT (dbo.PRODUCTS)
		/// </summary>
		[Association(ThisKey = "CATALOGPRODUCTID", OtherKey = "ID", CanBeNull = false)]
		public PRODUCT CATALOGPRODUCT { get; set; }

		/// <summary>
		/// LINKSFOREIGNPRICERECORD (dbo.PRICESRECORDS)
		/// </summary>
		[Association(ThisKey = "PRICERECORDINDEX", OtherKey = "RECORDINDEX", CanBeNull = false)]
		public PRICESRECORD LINKSFOREIGNPRICERECORD { get; set; }

		#endregion
	}
}
