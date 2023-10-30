
using System;
using System.IO;
using System.Linq;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public class GetApiAttribute<T> : GetAttribute
	{
		public GetApiAttribute(string path = default) : base(string.Join('/', "/", typeof(T).Name, path))
		{ }
	}

}
