using System;
using System.Collections;
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
	/// <summary>
	/// Interaction logic for TitledComboBox.xaml
	/// </summary>
	public partial class TitledComboBox : UserControl
	{
		public TitledComboBox()
		{
			InitializeComponent();
		}



		public string DisplayMember
		{
			get { return (string)GetValue(DisplayMemberProperty); }
			set { SetValue(DisplayMemberProperty, value); }
		}

		// Using a DependencyProperty as the backing store for DisplayMember.  This enables animation, styling, binding, etc...
		public static readonly DependencyProperty DisplayMemberProperty =
			DependencyProperty.Register("DisplayMember", typeof(string), typeof(TitledComboBox), null);



		public string ValueMember
		{
			get { return (string)GetValue(ValueMemberProperty); }
			set { SetValue(ValueMemberProperty, value); }
		}

		// Using a DependencyProperty as the backing store for ValueMember.  This enables animation, styling, binding, etc...
		public static readonly DependencyProperty ValueMemberProperty =
			DependencyProperty.Register("ValueMember", typeof(string), typeof(TitledComboBox), null);



		public string Caption
		{
			get { return (string)GetValue(CaptionProperty); }
			set { SetValue(CaptionProperty, value); }
		}

		// Using a DependencyProperty as the backing store for Caption.  This enables animation, styling, binding, etc...
		public static readonly DependencyProperty CaptionProperty =
			DependencyProperty.Register("Caption", typeof(string), typeof(TitledComboBox), new PropertyMetadata(""));

		public IList Items
		{
			get { return (IList)GetValue(ItemsProperty); }
			set { SetValue(ItemsProperty, value); }
		}

		// Using a DependencyProperty as the backing store for Items.  This enables animation, styling, binding, etc...
		public static readonly DependencyProperty ItemsProperty =
			DependencyProperty.Register("Items", typeof(IList), typeof(TitledComboBox), new PropertyMetadata(null));
	}
}
