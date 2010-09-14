package org.mousebomb.framework 
{
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	//加载渐进
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	public class DConfigProxy extends EventDispatcher
	{
		private var loader : URLLoader;
		private var rawXML : XML;

		/**
		 * 初始化
		 * @param configFile 若赋值，则立即加载配置；留空则直到手动调用getDConfig(_configFile:String)才加载
		 */
		public function DConfigProxy(configFile : String = undefined)
		{
			loader = new URLLoader();
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);			loader.addEventListener(Event.COMPLETE, onComp);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIoErr);
			if(configFile)
			{
				getDConfig(configFile);
			}
		}

		/**
		 * 解析配置，产生一些变量,方便访问.
		 * 会在加载完成后被调用
		 */
		protected function parseConfig() : void
		{
			//config.sth...
		}

		private function onIoErr(event : IOErrorEvent) : void
		{
			dispatchEvent(event);
		}

		private function onProgress(event : ProgressEvent) : void
		{
			//var p : Number = (event.bytesLoaded / event.bytesTotal);
			dispatchEvent(event);
		}

		private function onComp(event : Event) : void
		{
			rawXML = XML(loader.data);
			parseConfig();
			dispatchEvent(event);
		}

		public function getDConfig(configFile : String) : void
		{
			loader.load(new URLRequest(configFile));
		}

		public function get config() : XML
		{
			return rawXML;
		}
	}
}
