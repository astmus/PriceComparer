namespace Comparer.WFDesktopClient
{
	partial class MainForm
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.rootHost = new System.Windows.Forms.Integration.ElementHost();
			this.ProductsControl = new Comparer.Presentation.ProductsControl();
			this.SuspendLayout();
			// 
			// rootHost
			// 
			this.rootHost.Dock = System.Windows.Forms.DockStyle.Fill;
			this.rootHost.Location = new System.Drawing.Point(0, 0);
			this.rootHost.Name = "rootHost";
			this.rootHost.Size = new System.Drawing.Size(1021, 450);
			this.rootHost.TabIndex = 0;
			this.rootHost.Text = "elementHost1";
			this.rootHost.Child = this.ProductsControl;
			// 
			// MainForm
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(1021, 450);
			this.Controls.Add(this.rootHost);
			this.Name = "MainForm";
			this.Text = "Comparer";
			this.ResumeLayout(false);

		}

		#endregion

		private System.Windows.Forms.Integration.ElementHost rootHost;
		private Presentation.ProductsControl ProductsControl;
	}
}

