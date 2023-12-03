using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using Comparer.DataAccess.Abstractions;
using Comparer.DataAccess.Repositories;
using Comparer.Entities;

namespace Comparer.WFDesktopClient
{
	public partial class MainForm : Form
	{
		public MainForm(IDistributorRepository distributorsRepository, IManufacturerRepository mansRepo)
		{
			InitializeComponent();

			ProductsControl.DistributorDropDown.Items = distributorsRepository.Distributors.ToList();
			ProductsControl.ManufacturerDropDown.Items = mansRepo.LoadManufacturers<Manufacturer>();
		}
	}
}
