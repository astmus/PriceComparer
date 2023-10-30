using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Comparer.DataAccess.Dto
{

	public class ObjectInfo<TItem> : List<ItemInfo> where TItem : class
	{
		public ObjectInfo(TItem item)
		{
			var d = JsonDocument.Parse(JsonSerializer.Serialize(item)).RootElement.EnumerateObject();
			d.MoveNext();
			do
			{

				Add(new ItemInfo(d.Current.Name, d.Current.Value));
			} while (d.MoveNext());
		}
	}
	public record ItemInfo(string Name, object Value);
	public record ItemInfo<ItemId>(ItemId Id, string? Name = default);
}
