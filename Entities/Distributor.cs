
using System;

namespace Comparer.Entities
{
	public class Distributor
	{
		public virtual Guid ID { get; set; } // uniqueidentifier		
		public virtual string NAME { get; set; } // varchar(255)
		public virtual bool ACTIVE { get; set; } // bit
		public virtual bool? GOINPURCHASELIST { get; set; } // bit
		public virtual bool? FIRSTALWAYS { get; set; } // bit
		public virtual string PHONE { get; set; } // nvarchar(64)
		public virtual string EMAIL { get; set; } // nvarchar(1024)
		public virtual bool? SENDMAIL { get; set; } // bit
		public virtual string ADDRESS { get; set; } // nvarchar(1024)
		public virtual string COMMENT { get; set; } // nvarchar(4000)
		public virtual byte? PRIORITY { get; set; } // tinyint
		public virtual int? DEALERORDER { get; set; } // int
	}
}
