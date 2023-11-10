
namespace Comparer.Entities
{
	public class PriceList
	{
		public virtual Guid ID { get; set; } // uniqueidentifier
		public virtual string NAME { get; set; } // varchar(255)
		public virtual Guid? DISID { get; set; } // uniqueidentifier
		public virtual double DISCOUNT { get; set; } // float		
		public virtual bool ISACTIVE { get; set; } // bit
	}
}
