package org.mousebomb.classLoader 
{
	import flash.events.ProgressEvent;

	import org.mousebomb.classLoader.IClassLoader;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;	

	[Exclude(name="dispatchEvent", kind="method")]

	[Event(name="progress", type="flash.events.ProgressEvent")]

	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	[Event(name="complete", type="flash.events.Event")]

	/**
	 * 运行时类库加载
	 * 每个实例只能加载一次,不支持重复使用
	 * @author Mousebomb
	 * @date 2009-8-4
	 */
	public class ClassLoader extends EventDispatcher implements IClassLoader 
	{
		public static const LOAD_ERR : String = "加载出错";		public static const LOAD_COMPLETE : String = "加载完成"; 
		private var _loader : Loader;  
		private var _isFree : Boolean = true;

		
		public function ClassLoader( )
		{
			super();
			_loader = new Loader();
			//trace("ClassLoader");
		}

		public function loadFile(url : String) : void
		{
			_loader.load(new URLRequest(url));
			_isFree = false;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadCompH);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoErrorH);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityErrorH);			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressH);
		}

		private function onProgressH(event : ProgressEvent) : void
		{
			dispatchEvent(event);
		}

		private function onSecurityErrorH(event : SecurityErrorEvent) : void
		{
			trace("ClassLoader.onSecurityErrorH" + event.text);
			dispatchEvent(new Event(LOAD_ERR));
		}

		private function onIoErrorH(event : IOErrorEvent) : void
		{
			trace("ClassLoader.onIoErrorH," + event.text);
			dispatchEvent(event);
			//兼容旧版
			dispatchEvent(new Event(LOAD_ERR));
		}

		private function onLoadCompH(event : Event) : void
		{
			dispatchEvent(event);
			//兼容旧版			dispatchEvent(new Event(LOAD_COMPLETE));
		}

		public function getClass(name : String) : Class
		{
			return _loader.contentLoaderInfo.applicationDomain.getDefinition(name) as Class;
		}

		public function isFree() : Boolean
		{
			return _isFree;
		}
	}
}
