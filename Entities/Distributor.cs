
using System;

namespace Comparer.Entities
{
	public class Distributor
	{
		public virtual Guid Id { get; set; } // uniqueidentifier		
		public virtual string Name { get; set; } // varchar(255)
		public virtual bool Active { get; set; } // bit
		public virtual string Phone { get; set; } // nvarchar(64)
		public virtual string Email { get; set; } // nvarchar(1024)
		public virtual string Address { get; set; } // nvarchar(1024)		
	}
}
