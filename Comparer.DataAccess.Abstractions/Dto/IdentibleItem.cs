namespace Comparer.DataAccess.Dto
{
	public interface IIdentibleItem<Id>
	{
		Id ItemId { get; }
	}

	public abstract class IdentibleItem<Id> : IIdentibleItem<Id>
	{
		public abstract Id ItemId { get; init; }
	}

	public record IdentibleObject<ItemId>(ItemId Id)
	{
	}

	public record ItemInfo<ItemId>(ItemId? Id, string Description);
}
