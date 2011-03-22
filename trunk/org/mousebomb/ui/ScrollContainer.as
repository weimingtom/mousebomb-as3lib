package org.mousebomb.ui
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * 可用于UIScrollBar内容的容器
	 * @author Mousebomb mousebomb@gmail.com
	 */
	public class ScrollContainer extends Sprite implements IScrollContainer
	{
		private var _scrollHeight : Number;
		private var _scrollV : Number;
		private var _maxScrollV : Number;
		private var _bg : BitmapData;

		public function ScrollContainer()
		{
		}

		public function get maxScrollV() : Number
		{
			return _maxScrollV;
		}

		public function get scrollV() : Number
		{
			return _scrollV;
		}

		/**
		 * @param v [1,_maxScrollV]
		 */
		public function set scrollV(v : Number) : void
		{
			_scrollV = v;
			scrollRect = new Rectangle(0, v - 1, width, _scrollHeight);
		}

		// 高度
		override public function get height() : Number
		{
			/*
			 * 覆盖为实际显示的高度
			 */
			return _scrollHeight;
		}

		/**
		 * 拖拽区域高度
		 */
		override public function set height(value : Number) : void
		{
			_scrollHeight = value;
			scrollRect = new Rectangle(0, 0, width, _scrollHeight);
			_scrollV = 0.0;
			validateSize();
		}

		// 背景
		public function set bg(bg : BitmapData) : void
		{
			_bg = bg;
			validateBg();
		}

		/**
		 * 大小更新
		 */
		public function validateSize() : void
		{
			_maxScrollV = 1 + super.height - _scrollHeight;
		}

		/**
		 * 重绘背景
		 */
		public function validateBg() : void
		{
			graphics.clear();
			graphics.beginBitmapFill(_bg);
			graphics.drawRect(0, 0, super.width, super.height);
			graphics.endFill();
		}
		
		public function validate():void
		{
			validateSize();			validateBg();
		}
	}
}
