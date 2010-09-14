/**
* 9切分窗体
* @author Mousebomb
* @version 1.8.9.19
* 该类需要绑定舞台对象
*/

package org.mousebomb.display {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.MovieClip;

	public class NineSliceWindow extends Sprite
	{
		public var slicePart7:DisplayObject;
		public var slicePart8:DisplayObject;
		public var slicePart9:DisplayObject;
		public var slicePart4:DisplayObject;
		public var slicePart5:DisplayObject;
		public var slicePart6:DisplayObject;
		public var slicePart1:DisplayObject;
		public var slicePart2:DisplayObject;
		public var slicePart3:DisplayObject;
		
		public function NineSliceWindow(xPos:Number=0,yPos:Number=0,wid:Number=200,hei:Number=550):void
		{
			this.setWindowSize(wid,hei);
			this.setPos(xPos,yPos);
		}
		public function setWindowSize(wid:Number,hei:Number):void
		{
			this.slicePart1.x = 0;
			this.slicePart1.y = hei;
			this.slicePart2.x = 0;
			this.slicePart2.y = hei;
			this.slicePart2.width = wid;
			this.slicePart3.x = wid;
			this.slicePart3.y = hei;
			this.slicePart4.x = 0;
			this.slicePart4.y = 0;
			this.slicePart4.height =hei;
			this.slicePart5.x = 0;
			this.slicePart5.y = 0;
			this.slicePart5.width=wid;
			this.slicePart5.height=hei;
			this.slicePart6.x = wid;
			this.slicePart6.y = 0;
			this.slicePart6.height =hei;
			this.slicePart7.x = 0;
			this.slicePart7.y = 0;
			this.slicePart8.x = 0;
			this.slicePart8.y = 0;
			this.slicePart8.width = wid;
			this.slicePart9.x = wid;
			this.slicePart9.y = 0;
		}
		public function setPos(xPos:Number,yPos:Number):void
		{
			this.x = xPos;
			this.y = yPos;			
		}
		
	}
	
}
