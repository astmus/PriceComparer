using System.Collections.Generic;
using System.Linq;

namespace Comparer.CollectionExtensions
{
	public static class CollectionExtensions
	{
		public static bool IsEmpty<T>(this IEnumerable<T> collection)
			=> collection?.Any() == false;

		public static void ForEach<T>(this IEnumerable<T> collection, Action<T> action)
		{
			foreach (var item in collection)
				action(item);
		}

		public static IEnumerable<T> ForEachPrepare<T>(this IEnumerable<T> collection, Action<T> action)
		{
			foreach (var item in collection)
				action(item);
			return collection;
		}

		public static void AddRange<T>(this ICollection<T> collection, IEnumerable<T> items)
		{
			foreach (var item in items)
				collection.Add(item);
		}

		public static void Reload<T>(this ICollection<T> collection, IEnumerable<T> items)
		{
			collection.Clear();
			foreach (var item in items)
				collection.Add(item);
		}
	}
}
