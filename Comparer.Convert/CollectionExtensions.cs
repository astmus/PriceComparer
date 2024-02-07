using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.Xml;
using System.Xml.Linq;

using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;

using SoapCore;

namespace Comparer.ApiConvert
{
#nullable disable
	public static class ServiceCollectionExtensions
	{
		public static IServiceCollection AddSoapConverters(this IServiceCollection collection)
		{

			collection.AddSingleton<IAuthorService, AuthorService>().AddSoapCore();
			collection.AddSoapMessageProcessor(async (message, httpcontext, next) =>
			{
				var bufferedMessage = message.CreateBufferedCopy(int.MaxValue);
				var msg = bufferedMessage.CreateMessage();
				var reader = msg.GetReaderAtBodyContents();
				var content = reader.ReadInnerXml();

				//now you can inspect and modify the content at will.
				//if you want to pass on the original message, use bufferedMessage.CreateMessage(); otherwise use one of the overloads of Message.CreateMessage() to create a new message
				var soapmessage = bufferedMessage.CreateMessage();

				//pass the modified message on to the rest of the pipe.
				var responseMessage = await next(message);

				//Inspect and modify the contents of returnMessage in the same way as the incoming message.
				//finish by returning the modified message.	

				return responseMessage;
			});
			return collection;
		}
		public static IApplicationBuilder UseSoapEndpoints(this IApplicationBuilder app)
		{
			app.UseRouting();

			//app.UseEndpoints(endpoints =>
			//{
			//	endpoints.UseSoapEndpoint<IAuthorService>("/ServicePath.asmx", new SoapEncoderOptions(), SoapSerializer.DataContractSerializer);
			//});
			app.UseSoapEndpoint<IAuthorService>("/AuthorService.asmx", new SoapEncoderOptions());
			return app;
		}
	}
}

[DataContract]
public class Author
{
	[DataMember]
	public int Id { get; set; }
	[DataMember]
	public string FirstName { get; set; }
	[DataMember]
	public string LastName { get; set; }
	[DataMember]
	public string Address { get; set; }
}
[ServiceContract]
public interface IAuthorService
{
	[OperationContract]
	void MySoapMethod(Message xml);
}
public class AuthorService : IAuthorService
{
	public void MySoapMethod(Message xml)
	{
		System.Diagnostics.Trace.WriteLine(xml.ToString());
	}
}
#nullable enable