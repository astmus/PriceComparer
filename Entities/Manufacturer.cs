
using System;

namespace Comparer.Entities
{
	public record Manufacturer
	{
		public virtual Guid Id { get; set; }
		public virtual string Name { get; set; }
		public virtual string Description { get; set; }
		public virtual bool? IsDeleted { get; set; }
	}
}
