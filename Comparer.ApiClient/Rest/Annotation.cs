
using System;
using System.Linq;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public class GetApiAttribute : GetAttribute
	{
		public GetApiAttribute(string path = default) : base("/api/" + path)
		{
		}
		public GetApiAttribute(params string[] pathItems) : this(string.Join('/', pathItems))
		{
		}
		public GetApiAttribute(Type endpointType, string path = default) : this(endpointType.Name, path)
		{
		}
	}

	public class GetApiAttribute<T> : GetApiAttribute
	{
		public GetApiAttribute() : base(typeof(T))
		{
		}
		public GetApiAttribute(params string[] pathSegment) : base($"{typeof(T).Name}/{string.Join('/', pathSegment)}")
		{
		}
	}

}
