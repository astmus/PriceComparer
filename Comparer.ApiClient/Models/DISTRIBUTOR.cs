﻿using System.Collections.Generic;

using Comparer.Entities;

using LinqToDB.Mapping;

namespace Comparer.DataAccess.Models
{
	[Table(Schema = "dbo", Name = "DISTRIBUTORS")]
	public partial class DISTRIBUTOR : Distributor
	{
		[PrimaryKey, NotNull] public override Guid Id { get; set; } // uniqueidentifier
		[Column, NotNull] public string NAME { get; set; } // varchar(255)
		[Column, NotNull] public bool ACTIVE { get; set; } // bit
		[Column, Nullable] public bool? GOINPURCHASELIST { get; set; } // bit
		[Column, Nullable] public bool? FIRSTALWAYS { get; set; } // bit
		[Column, Nullable] public string PHONE { get; set; } // nvarchar(64)
		[Column, Nullable] public string EMAIL { get; set; } // nvarchar(1024)
		[Column, Nullable] public bool? SENDMAIL { get; set; } // bit
		[Column, Nullable] public string ADDRESS { get; set; } // nvarchar(1024)
		[Column, Nullable] public string COMMENT { get; set; } // nvarchar(4000)
		[Column, Nullable] public byte? PRIORITY { get; set; } // tinyint
		[Column, Nullable] public int? DEALERORDER { get; set; } // int

		#region Associations

		[Association(ThisKey = "ID", OtherKey = "DISID", CanBeNull = true)]
		public IEnumerable<PRICE> DistributorPrices { get; set; }

		#endregion
	}
}
