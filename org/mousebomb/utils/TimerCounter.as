package org.mousebomb.utils 
{
	import flash.utils.getTimer;

	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2010-7-8
	 */
	public class TimerCounter extends Object 
	{

		//任务
		private static var _tasks : Object = {};

		/**
		 * 开始任务计时
		 */
		public static function startTask(name : String) : void
		{
			_tasks[name] = getTimer();
		}

		/**
		 * 结束任务计时，返回执行时间
		 */
		public static function endTask(name : String) : int
		{
			var time : int = getTimer() - _tasks[name] ;
			trace("Task " + name + " used :" + time + " ms");
			return time;
		}
	}
}
