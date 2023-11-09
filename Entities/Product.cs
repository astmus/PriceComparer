namespace Comparer.Entities
{
	public partial class Product
	{
		public virtual string NAME { get; set; } // varchar(1024)
		public virtual double PRICE { get; set; } // float
		public virtual string LABEL { get; set; } // varchar(255)
		public virtual byte STATE { get; set; } // tinyint
		public virtual string CHILDNAME { get; set; } // nvarchar(1024)
		public virtual bool PUBLISHED { get; set; } // bit
		public virtual string COMMENT { get; set; } // nvarchar(500)
		public virtual bool DELETED { get; set; } // bit
		public virtual double WEIGHT { get; set; } // float
		public virtual byte DEFAULTCURRENCY { get; set; } // tinyint
	}
}
