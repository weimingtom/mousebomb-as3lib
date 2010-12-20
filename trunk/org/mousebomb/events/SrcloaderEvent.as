package org.mousebomb.events 
{
	import org.mousebomb.events.MousebombEvent;
	
	/**
	 * @author Mousebomb
	 * @date 2009-7-22
	 */
	public class SrcloaderEvent extends MousebombEvent 
	{
		public static const COMPLETE:String = "完成";
		
		public static const SWF_LOADED:String = "swf加载完毕";
		
		
		public function SrcloaderEvent(type : String, data : Object, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, data, bubbles, cancelable);
		}
	}
}