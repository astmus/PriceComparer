using System.Numerics;

namespace System.Runtime.CompilerServices
{
	public class IsExternalInit { }
}


namespace Comparer.DataAccess.Dto
{
	public record BaseUnit;
	public record DataUnit<TEntity> : BaseUnit
	{
		public virtual string? Name { get; init; }
	}


	public record DataUnit : BaseUnit
	{
		public DataUnit()
		{
		}
		public DataUnit(Guid id, string? name)
		{
			Id = id;
			Name = name;
		}
		public virtual Guid Id { get; init; }
		public string? Name { get; init; }
	}
}
