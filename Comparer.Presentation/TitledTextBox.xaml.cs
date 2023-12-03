using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace Comparer.Presentation
{
	public partial class TitledTextBox : UserControl
	{
		public TitledTextBox()
		{
			InitializeComponent();
		}


		public string Caption
		{
			get { return (string)GetValue(CaptionProperty); }
			set { SetValue(CaptionProperty, value); }
		}

		public static readonly DependencyProperty CaptionProperty =
			DependencyProperty.Register("Caption", typeof(string), typeof(TitledTextBox), new PropertyMetadata(""));

		public ItemCollection Items
		{
			get { return (ItemCollection)GetValue(ItemsProperty); }
			set { SetValue(ItemsProperty, value); }
		}

		public static readonly DependencyProperty ItemsProperty =
			DependencyProperty.Register("Items", typeof(ItemCollection), typeof(TitledTextBox), new PropertyMetadata(null));
	}
}
