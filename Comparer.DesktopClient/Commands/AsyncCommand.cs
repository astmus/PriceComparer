using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Comparer.DesktopClient.Commands
{
	internal record AsyncCommand<T> : ICommand
	{
		public event EventHandler? CanExecuteChanged
		{
			add { CommandManager.RequerySuggested += value; }
			remove { CommandManager.RequerySuggested -= value; }
		}

		readonly Func<T, Task> execute;
		readonly Func<T, bool>? canExecute;
		readonly Action<Exception>? onException;

		public AsyncCommand(Func<T, Task> execute, Func<T, bool>? canExecute = default, Action<Exception>? onException = default)
		{
			this.execute = execute;
			this.canExecute = canExecute;
			this.onException = onException;
		}

		public async void Execute(object? parameter)
		{
			if (parameter is T arg)
				try
				{
					await execute(arg);
				}
				catch (Exception ex)
				{
					if (onException != null)
						onException.Invoke(ex);
					else
						throw;
				}
			else
				throw new ArgumentException("Wrong parameter");
		}

		public bool CanExecute(object? parameter)
			=> parameter is T arg ? canExecute?.Invoke(arg) ?? false : false;
	}

	internal record AsyncCommand : ICommand
	{
		public event EventHandler? CanExecuteChanged
		{
			add { CommandManager.RequerySuggested += value; }
			remove { CommandManager.RequerySuggested -= value; }
		}

		readonly Func<Task> execute;
		readonly Func<object, bool>? canExecute;
		readonly Action<Exception>? onException;
		readonly bool continueOnCapturedContext;

		public AsyncCommand(Func<Task> execute, Func<object, bool> canExecute = null, Action<Exception>? onException = null, bool continueOnCapturedContext = false)
		{
			this.execute = execute;
			this.canExecute = canExecute;
			this.onException = onException;
		}

		public async void Execute(object parameter)
		{
			try
			{
				await execute().ConfigureAwait(continueOnCapturedContext);
			}
			catch (Exception ex) when (onException is Action<Exception> handler)
			{
				handler.Invoke(ex);
			}
			catch { throw; }
		}

		public bool CanExecute(object? parameter)
			=> canExecute?.Invoke(parameter) ?? false;
	}
}
