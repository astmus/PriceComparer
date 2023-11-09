namespace System.Runtime.CompilerServices
{
	public class IsExternalInit { }
}


namespace Comparer.DataAccess.Dto
{
	public record BaseUnit;
	public record DataUnit<TEntity> : BaseUnit;
	public record DataUnit : BaseUnit
	{
		public virtual Guid Id { get; init; }
		public string? Name { get; init; }
	}

	public record ItemId : IId
	{
		string? Id;

		public ItemId(string? Id = default)
		{

		}
		public ItemId() : this(string.Empty)
		{

		}

		public virtual bool Equals(ItemId other)
			=> Id == other?.Id == true;

		public override int GetHashCode()
			=> Id.GetHashCode();

		public int CompareTo(ItemId other)
			=> other == this ? 0 : -1;

		public bool Equals(string obj)
			=> string.Compare(Id, obj, StringComparison.OrdinalIgnoreCase) == 0;

		public static ItemId operator +([System.Diagnostics.CodeAnalysis.NotNull] ItemId _this, ItemId other)
			=> _this with { Id = string.Join('.', _this.Id, other.Id) };

		public static implicit operator string(ItemId id)
			=> id?.Id;

		public static implicit operator long(ItemId id)
		{
			if (id.Id is string l)
				return long.Parse(l, System.Globalization.CultureInfo.CurrentCulture);
			else throw new ArgumentException("Wrong long");
		}

		public static implicit operator uint(ItemId id)
		{
			if (id.Id is string l)
				return uint.Parse(l, System.Globalization.CultureInfo.CurrentCulture);
			else throw new ArgumentException("Wrong uint");
		}

		public static implicit operator int(ItemId id)
		{
			if (id.Id is string l)
				return int.Parse(l, System.Globalization.CultureInfo.CurrentCulture);
			else throw new ArgumentException("Wrong int");
		}

		public static implicit operator ItemId(Guid id)
			=> new Id<Guid>($"{id}");
		public static implicit operator ItemId(string id)
		=> new ItemId(id);
		public static implicit operator ItemId(int id)
			=> new Id<int>($"{id}");

		public static implicit operator ItemId(long id)
			=> new Id<long>($"{id}");

		public static implicit operator ItemId(uint id)
			=> new Id<uint>($"{id}");

		public static bool operator <(ItemId left, ItemId right)
			=> left is null ? right is not null : left.CompareTo(right) < 0;


		public static bool operator <=(ItemId left, ItemId right)
		{
			return left is null || left.CompareTo(right) <= 0;
		}

		public static bool operator >(ItemId left, ItemId right)
		{
			return left is not null && left.CompareTo(right) > 0;
		}

		public static bool operator >=(ItemId left, ItemId right)
		{
			return left is null ? right is null : left.CompareTo(right) >= 0;
		}
	}
	public record Id<T>(string? id = default) : ItemId(id), IComparable<Id<T>>
	{

		static Id()
		{

		}

		public Id(Guid id) : this(id.ToString())
		{

		}

		public Id() : this(string.Empty)
		{

		}


		public int CompareTo(T other)
		{
			throw new NotImplementedException();
		}

		public int CompareTo(Id<T> other)
		{
			throw new NotImplementedException();
		}
	}
}
