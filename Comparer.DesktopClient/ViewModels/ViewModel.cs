using System;
using System.Collections.Concurrent;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Windows.Input;

namespace Comparer.DesktopClient.ViewModels
{
	public abstract class ViewModel : INotifyPropertyChanged
	{
		private readonly ConcurrentDictionary<string, object> _properties = new ConcurrentDictionary<string, object>();

		public event PropertyChangedEventHandler PropertyChanged;
		protected virtual bool IsMainThread
			=> !Thread.CurrentThread.IsBackground && !Thread.CurrentThread.IsThreadPoolThread;
		protected void OnPropertyChanged([CallerMemberName] string propertyName = default)
			=> PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));

		public abstract ICommand LoadMainDataCommand { get; protected set; }

		protected T Get<T>(T defValue = default, bool initialize = false, [CallerMemberName] string name = default)
		{
			if (string.IsNullOrEmpty(name))
				return defValue;

			if (initialize)
				return (T)_properties.GetOrAdd(name, (n) => Activator.CreateInstance<T>());

			return (T)_properties.GetOrAdd(name, defValue);
		}

		protected bool Set(object value, [CallerMemberName] string name = default)
		{
			if (string.IsNullOrEmpty(name))
				return false;

			var isFound = _properties.TryGetValue(name, out object oldValue);
			if (isFound && Equals(value, oldValue))
				return false;

			_properties.AddOrUpdate(name, value, (s, o) => value);

			OnPropertyChanged(name);

			return true;
		}

		protected TParam ScheduleExecute<TParam>(Action<TParam> work, TParam args)
		{
			ThreadPool.QueueUserWorkItem(work, args, true);
			return args;
		}

		protected TParam GetOrScheduleInit<TParam>(Action<TParam> work, [CallerMemberName] string name = default)
		{

			if (TryGetValue<TParam>(name) is TParam args)
				return args;

			// Continue only if args is not initialized.
			args = Get<TParam>(default, true, name);
			ThreadPool.QueueUserWorkItem(work, args, true);
			return args;
		}

		TValue TryGetValue<TValue>(string key)
		{
			if (_properties.TryGetValue(key, out object result) && result is TValue valueResult)
				return valueResult;

			return default;
		}
	}
}
