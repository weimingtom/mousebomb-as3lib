package org.mousebomb.framework
{
	import org.mousebomb.global.GlobalFacade;
	import org.mousebomb.global.Notify;
	/**
	 * 命令分派中心
	 * 将某些Notify注册到对应的控制器
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2010-12-20
	 */
	public class CommandCenter
	{

		protected var _allowConfig : Boolean = true;

		/**
		 * 配置映射。
		 * 例如
		notifyHandlerClassMap[NotifyConst.PLATFORM_USER_LOGEDIN] = UserLogedinCtrler;
		notifyHandlerClassMap[NotifyConst.PLATFORM_ROLE_CREATED] = RoleCreatedCtrler;
		notifyHandlerClassMap[NotifyConst.PLATFORM_SERVER_CHOSEN] = ServerChosenCtrler;
		 */
		public function config() : void
		{
			if (_allowConfig)
			{

			}else{
				throw new Error("已经注册控制器之后是不允许改动配置的");
			}
		}
		//类表
		protected var _notifyHandlerClassMap : Object = {};

		/**
		 * 根据配置的映射来注册
		 * 注册之后就不允许再配置了
		 */
		protected function regist() : void
		{
			// 把配置项加监听
			for (var key : String in _notifyHandlerClassMap)
			{
				GlobalFacade.regListener(key, notifyHandler);
			}
			_allowConfig = false;
		}
		
		/**
		 * 处理通告监听
		 * 映射到Ctrler
		 */
		protected function notifyHandler(n : Notify) : void
		{
			//根据n.name找到对应类定义
			var targetClass : Class = _notifyHandlerClassMap[n.name];
			if(targetClass == null) return ;
			//创建实例 
			var ctrler : INotifyControler = new targetClass();
			ctrler.exec(n);
		}

		/**
		 * 解除所有注册的映射
		 */
		protected function unRegist() : void
		{
			for (var key : String in _notifyHandlerClassMap)
			{
				GlobalFacade.removeListener(key, notifyHandler);
			}
			//
			_allowConfig = true;
		}
	}
}