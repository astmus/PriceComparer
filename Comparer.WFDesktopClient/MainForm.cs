using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
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

			ThreadPool.QueueUserWorkItem(new WaitCallback(LoadD), distributorsRepository);
			ThreadPool.QueueUserWorkItem(new WaitCallback(LoadM), mansRepo);
		}

		void LoadD(object distributorsRepository)
			=> ProductsControl.DistributorDropDown.Items = ((IDistributorRepository)distributorsRepository).Distributors.ToList();
		void LoadM(object repo)
			=> ProductsControl.ManufacturerDropDown.Items = ((IManufacturerRepository)repo).LoadManufacturers<Manufacturer>();
	}
}
