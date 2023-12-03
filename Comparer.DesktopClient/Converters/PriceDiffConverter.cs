using System;
using System.Globalization;
using System.Linq;
using System.Windows;
using System.Windows.Data;

namespace Comparer.DesktopClient.Converters
{
	public class PriceDiffConverter : IMultiValueConverter
	{
		public double? Convert(double basePrice, double? price, Type targetType, object parameter, CultureInfo culture)
		{
			if (!price.HasValue)
				return default;
			return Math.Round(price.Value - basePrice, 2);
		}

		public object Convert(object[] values, Type targetType, object parameter, CultureInfo culture)
		{
			if (values.Any(v => v == DependencyProperty.UnsetValue))
				return DependencyProperty.UnsetValue;

			var price = Convert((double)values[0], values[1] as double?, targetType, parameter, culture);
			if (!price.HasValue) return default;

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
