
using System;

using Refit;

namespace Comparer.ApiClient.Rest
{
	public class GetApiAttribute : GetAttribute
	{
		public GetApiAttribute() : base("/api/")
		{
		}
		public GetApiAttribute(params string[] pathItems) : base("/api/" + string.Join('/', pathItems))
		{
		}
		public GetApiAttribute(Type endpointType, string path = default) : this(endpointType.Name + "/" + path)
		{
		}
	}
	public class GetApiAttribute<T> : GetApiAttribute
	{
		public GetApiAttribute() : base(typeof(T))
		{
		}
		public GetApiAttribute(string path) : base(typeof(T), path)
		{
		}
	}


	public class GetApiAttribute<T, TKey> : GetApiAttribute
	{
		public GetApiAttribute(string path, TKey key) : base(typeof(T).Name, path, $"{key}")
		{
		}
	}
}
