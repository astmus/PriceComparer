using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using System.Windows.Threading;

namespace Comparer.DesktopClient.ViewModels
{
	public abstract class ViewModel : INotifyPropertyChanged
	{
		private readonly ConcurrentDictionary<string, object> _properties = new ConcurrentDictionary<string, object>();

		public event PropertyChangedEventHandler PropertyChanged;

		protected void OnPropertyChanged([CallerMemberName] string propertyName = default)
			=> PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));

		public virtual ICommand LoadMainDataCommand
			=> default;

		protected T Get<T>(T defValue = default, bool initialize = false, [CallerMemberName] string name = default)
		{
			if (string.IsNullOrEmpty(name))
				return defValue;

			return (T)_properties.GetOrAdd(name, initialize ? Activator.CreateInstance<T>() : defValue);
		}

		protected bool Set(object value, [CallerMemberName] string name = default)
		{
			if (string.IsNullOrEmpty(name))
				return false;

			var isFound = _properties.TryGetValue(name, out var oldValue);
			if (isFound && Equals(value, oldValue))
				return false;

			if (!_properties.AddOrUpdate(name, value, (s, o) => value).Equals(value))
				OnPropertyChanged(name);

			return true;
		}

		protected bool ScheduleExecute<TParam>(Action<TParam> work, TParam args)
			=> ThreadPool.QueueUserWorkItem(work, args, true);
		protected TResponse ScheduleExecute<TParam, TResponse>(Action<TParam> work, TParam args, Func<TResponse, bool, string, TResponse> factory, [CallerMemberName] string name = default)
		{
			TResponse response = factory(default, true, name);
			ThreadPool.QueueUserWorkItem(work, args, true);
			return response;
		}

		protected TParam ScheduleExecute<TParam>(Action<TParam> work, Func<TParam, bool, string, TParam> factory, [CallerMemberName] string name = default)
		{
			TParam args = factory(default, true, name);
			ThreadPool.QueueUserWorkItem(work, args, true);
			return args;
		}
	}

	public abstract class ViewModel<TView> : ViewModel where TView : class
	{
		protected abstract Task LoadDataAsync();


		protected virtual bool IsMainThread
			=> !Thread.CurrentThread.IsBackground && !Thread.CurrentThread.IsThreadPoolThread;
	}
}
