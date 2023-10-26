namespace Comparer.Entities
{
	public partial class PRODUCT
	{
		public Guid ID { get; set; } // uniqueidentifier
		public string NAME { get; set; } // varchar(1024)
		public Guid MANID { get; set; } // uniqueidentifier
		public double PRICE { get; set; } // float
		public double? BASEPRICE { get; set; } // float
		public string LABEL { get; set; } // varchar(255)
		public string PARENTLABEL { get; set; } // varchar(255)
		public byte STATE { get; set; } // tinyint
		public bool USERCHANGED { get; set; } // bit
		public bool EXTRAUSED { get; set; } // bit
		public int EXTRA { get; set; } // int
		public bool AUTOUPDATE { get; set; } // bit
		public bool? AUTOUPDATETESTS { get; set; } // bit
		public bool? PRODUCTEXISTS { get; set; } // bit
		public bool PHOTOEXISTS { get; set; } // bit
		public int VIEWSTYLEID { get; set; } // int
		public string CHILDNAME { get; set; } // nvarchar(1024)
		public bool TESTER { get; set; } // bit
		public bool PUBLISHED { get; set; } // bit
		public DateTime CREATEDATE { get; set; } // datetime
		public DateTime CHANGEDATE { get; set; } // datetime
		public byte CORRECTEDSTATUS { get; set; } // tinyint
		public int INSTOCK { get; set; } // int
		public bool ISPROBIRKA { get; set; } // bit
		public string COMMENT { get; set; } // nvarchar(500)
		public bool DELETED { get; set; } // bit
		public virtual bool IsPromo { get; set; } // bit
		public int TEMPLATEID { get; set; } // int
		public int SKU { get; set; } // int
		public bool ISNEW { get; set; } // bit
		public DateTime? ISNEWSTARTDATE { get; set; } // datetime
		public double WEIGHT { get; set; } // float
		public byte DEFAULTCURRENCY { get; set; } // tinyint
	}
}
