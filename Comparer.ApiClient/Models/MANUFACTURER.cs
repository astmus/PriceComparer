using System.Collections.Generic;

using Comparer.Entities;

using LinqToDB.Mapping;

namespace Comparer.DataAccess.Models
{
	[Table(Schema = "dbo", Name = "MANUFACTURERS")]
	public partial class MANUFACTURER : Manufacturer
	{
		[PrimaryKey, NotNull] public override Guid Id { get; set; } // uniqueidentifier
		[Column, NotNull] public override string Name { get; set; } // varchar(255)
		[Column, Nullable] public override string Description { get; set; } // varchar(255)
		[Column, NotNull] public override bool? IsDeleted { get; set; } // bit		
	}
}
