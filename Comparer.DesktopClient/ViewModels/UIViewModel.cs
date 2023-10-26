using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;

using CommunityToolkit.Mvvm.Input;

namespace Comparer.DesktopClient.ViewModels
{

	public abstract class UIViewModel<TView> : ViewModel where TView : class
	{
		protected abstract Task LoadDataAsync();

		protected void SafeStartCommand(IAsyncRelayCommand command, object? args)
		{
			if (!command.IsRunning && command.CanExecute(args))
				command.ExecuteAsync(args);
		}

		protected async Task<ObservableCollection<TItem>> LoadCollection<TItem>(ObservableCollection<TItem> dest, IAsyncEnumerable<TItem> source)
		{
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));
			await foreach (var item in source.WithCancellation(src.Token))
				if (!IsMainThread)
					Application.Current.Dispatcher.Invoke(() =>
						dest.Add(item));
				else
					dest.Add(item);
			return dest;
		}

		protected void LoadCollection<TItem>(ObservableCollection<TItem> dest, IEnumerable<TItem> source)
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
