﻿using System.Collections.Generic;
using System.Threading.Tasks;
using System.Windows;

using CommunityToolkit.Mvvm.Input;

using Comparer.CollectionExtensions;

namespace Comparer.DesktopClient.ViewModels
{

	public abstract class UIViewModel<TView> : ViewModel where TView : class
	{
		protected abstract Task LoadDataAsync();

		protected void SafeStartCommand(IAsyncRelayCommand command, object? args)
		{
			if (!command.IsRunning && command.CanExecute(args))
				command.Execute(args);
		}

		protected void SafeStartCommand<T>(IAsyncRelayCommand<T> command, T args)
		{
			if (!command.IsRunning && command.CanExecute(args))
				command.Execute(args);
		}

		protected void LoadCollection<TItem>(ICollection<TItem> dest, IEnumerable<TItem> source)
		{
			if (!IsMainThread)
				Application.Current.Dispatcher.Invoke(() =>
				{
					dest?.Clear();
					dest.AddRange(source);
				});
			else
			{
				dest?.Clear();
				dest.AddRange(source);
			}
		}
	}
}
