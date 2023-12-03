using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using Comparer.DataAccess.Repositories;

namespace Comparer.WFDesktopClient
{
	public partial class MainForm : Form
	{
		public MainForm(IDistributorRepository distributorsRepository)
		{
			InitializeComponent();

			ProductsControl.DistributorDropDown.Items = distributorsRepository.Distributors.ToList();

			ProductsControl.ManufacturerDropDown.Items = new List<object>();
			ProductsControl.ManufacturerDropDown.Items.Add("12");
			ProductsControl.ManufacturerDropDown.Items.Add(2);
			ProductsControl.ManufacturerDropDown.Items.Add(3);
		}
	}
}
