using System.Collections.Generic;

using LinqToDB.Mapping;

namespace Comparer.Data.Models
{
	[Table(Schema = "dbo", Name = "MANUFACTURERS")]
	public partial class Manufacturer : Comparer.Entities.Manufacturer
	{
		[PrimaryKey, NotNull] public Guid Id { get; set; } // uniqueidentifier
		[Column, NotNull] public override string Name { get; set; } // varchar(255)
		[Column, Nullable] public override string Description { get; set; } // varchar(255)
		[Column, NotNull] public bool? IsDeleted { get; set; } // bit		
	}
}
