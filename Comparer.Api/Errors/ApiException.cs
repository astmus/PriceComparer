using Microsoft.AspNetCore.Mvc;

namespace Comparer.Api.Errors
{
	public class ApiException : Exception
	{
		public ApiException(string message = null) : base(message)
		{

		}
		public StatusCodeResult Result { get; init; }

	}
}
