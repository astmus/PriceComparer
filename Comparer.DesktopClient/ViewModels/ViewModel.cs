using System;
using System.Collections.Concurrent;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
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

		public virtual ICommand LoadMainDataCommand
			=> default;

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


		protected TParam ScheduleInitLoad<TParam>(Action<TParam> work, TParam args, [CallerMemberName] string name = default)
		{
			ThreadPool.QueueUserWorkItem(work, args, true);
			return args;
		}
	}
}
