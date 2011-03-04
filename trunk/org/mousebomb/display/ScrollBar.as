package org.mousebomb.display
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;

	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2011-3-2
	 */
	public class ScrollBar extends Sprite
	{
		public var thumbClass : Class;
		public var trackClass : Class;
		public var upBtnClass : Class;
		public var downBtnClass : Class;
		
		private var thumb : SimpleButton;
		private var track : Sprite;
		private var upBtn : SimpleButton;
		private var downBtn : SimpleButton;
		
		public function ScrollBar()
		{
		}
	}
}
