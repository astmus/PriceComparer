using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

using Comparer.DataAccess.Dto;

namespace Comparer.DesktopClient.Converters
{
	public class PriceDiffConverter : IMultiValueConverter
	{
		public object Convert(Models.PriceListProduct product, double price, Type targetType, object parameter, CultureInfo culture)
		{
			return Math.Round(price - product.Price, 2);
		}

		public object Convert(object[] values, Type targetType, object parameter, CultureInfo culture)
		{
			var price = (double)Convert(values[0] as Models.PriceListProduct, (double)values[1], targetType, parameter, culture);
			return price > 0 ? $"+{price}" : $"{price}";
		}

		public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
		{
			//string strValue = value as string;
			//DateTime resultDateTime;
			//if (DateTime.TryParse(strValue, out resultDateTime))
			//{
			//	return resultDateTime;
			//}
			return DependencyProperty.UnsetValue;
		}

		public object[] ConvertBack(object value, Type[] targetTypes, object parameter, CultureInfo culture) => throw new NotImplementedException();
	}
}
