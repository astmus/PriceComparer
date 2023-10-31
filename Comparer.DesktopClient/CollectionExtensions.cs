using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace Comparer.DesktopClient
{
	internal static class CollectionExtensions
	{
		internal static void AddRange<T>(this ObservableCollection<T> collection, IEnumerable<T> items)
		{
			foreach (var item in items)
				collection.Add(item);
		}
		internal static void AddRange<T>(this ICollection<T> collection, IEnumerable<T> items)
		{
			foreach (var item in items)
				collection.Add(item);
		}
		internal static void Reload<T>(this ObservableCollection<T> collection, IEnumerable<T> items)
		{
			collection.Clear();
			foreach (var item in items)
				collection.Add(item);
		}
	}
}
