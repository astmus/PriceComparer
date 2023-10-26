
namespace Comparer.Entities
{
	public class PriceList
	{
		public Guid ID { get; set; } // uniqueidentifier
		public string NAME { get; set; } // varchar(255)
		public Guid? DISID { get; set; } // uniqueidentifier
		public double DISCOUNT { get; set; } // float
		public byte DEFAULTCURRENCY { get; set; } // tinyint
		public double TURNDOLLARSRATE { get; set; } // float
		public string SHEET { get; set; } // varchar(1024)
		public string NAMERANGE { get; set; } // varchar(16)
		public string PRICERANGE { get; set; } // varchar(16)
		public int FIRSTROW { get; set; } // int
		public float MAXPRICECHANGE { get; set; } // real
		public string STOPWORDS { get; set; } // varchar(6000)
		public string FILENAME { get; set; } // varchar(1024)
		public DateTime? FILEDATE { get; set; } // datetime
		public string FILESHEETS { get; set; } // varchar(1024)
		public string COMMENT { get; set; } // nvarchar(1024)
		public string SKURANGE { get; set; } // varchar(16)
		public string STOCKRANGE { get; set; } // nvarchar(16)
		public string INSTOCKRANGE { get; set; } // nvarchar(16)
		public bool ISACTIVE { get; set; } // bit
	}
}
