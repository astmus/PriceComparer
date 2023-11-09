using System.Buffers;
using System.Text.Json;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Formatters;

namespace Comparer.Api.Filters
{
	public class SerializationFilter : ActionFilterAttribute
	{
		private readonly bool useDefaultFormatter;

		public SerializationFilter(bool useDefaultFormatter = true)
		{
			this.useDefaultFormatter = useDefaultFormatter;
		}
		public override void OnActionExecuted(ActionExecutedContext ctx)
		{
			if (ctx.Result is ObjectResult objectResult)
			{
				if (useDefaultFormatter)
					objectResult.Formatters.Add(new SystemTextJsonOutputFormatter(
						new JsonSerializerOptions()
						{
							DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull,
							PropertyNamingPolicy = null,
							IgnoreReadOnlyFields = true
						}
						));
			}
		}
	}
}
