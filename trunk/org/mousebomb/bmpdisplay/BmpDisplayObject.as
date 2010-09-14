package org.mousebomb.bmpdisplay 
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	/**
	 * 利用BmdObject呈现的显示对象
	 * flash中显示用
	 * @author Mousebomb
	 * @date 2009-6-17
	 * @note
	 * 需要增加重绘区域控制
	 */
	public class BmpDisplayObject extends Bitmap 
	{
		use namespace bmd_render;
		bmd_render var _bmdObject : BmdObject;

		//请求渲染的次数
		private var _needToRender : int = 0;

		//每秒渲染帧数
		private var _fps : int = 25;
		private var _renderTimer : Timer ;

		//事件捕捉
		private var _eventCatcher : EventCatcher;
		//实际提供渲染功能
		private var _render : RenderProcess;
		//计算重绘范围，用于重绘
		private var _rerenderRect : Rectangle = new Rectangle(0, 0, 0, 0);

		
		/**
		 * 
		 * @param bmdObject	一个BmdObject，内容对象，注意：此对象不要设置x,y
		 * @param renderEnterFrame 是否逐帧自动重绘,建议仅用于动画对象
		 */
		public function BmpDisplayObject(bmdObject : BmdObject, pixelSnapping : String = "auto", smoothing : Boolean = false)
		{
			_bmdObject = bmdObject;
			_bmdObject.setStage(this);
			super(_bmdObject.bitmapData, pixelSnapping, smoothing);
			_render = new RenderProcess(this);
			_renderTimer = new Timer(1000 / fps);
			_renderTimer.addEventListener(TimerEvent.TIMER, onRenderTimer);
			_eventCatcher = new EventCatcher(this);
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}

		/**
		 * 设置根级bmd
		 */
		public function setBmdObject(bmdObject : BmdObject) : void
		{
			_bmdObject = bmdObject;
			_bmdObject.setStage(this);
		}

		//从舞台移除的时候解除捕捉
		private function onLostStage(event : Event) : void
		{
			_eventCatcher.clearEvents(stage);
		}

		//加入舞台开始捕捉
		private function onStage(event : Event) : void
		{
			_eventCatcher.initEvents(stage);
		}

		/**
		 * 开始渲染
		 * 第一次全量渲染
		 * 并开启重绘计时
		 */
		public function startRender() : void
		{
			_render.renderWhole();
			_renderTimer.start();
		}

		/**
		 * 查看请求的个数决定是否重绘
		 * (这里帧的速度是取决于为我设置的fps，而不是flash的帧频)
		 * @see BmpDisplayObject.fps
		 */
		private function onRenderTimer(event : TimerEvent) : void
		{
			if(_needToRender)
			{
				_needToRender = 0;
				realRender();
//				trace("r");
//			}else{
//				trace("不渲染");
			}
		}

		/**
		 * 渲染，重绘，调用一次为请求渲染一次
		 */
		private function realRender() : void
		{
			_render.renderWhole();
//			return;
			//等时机成熟了再完善一下 局部绘制(1)
//			_render.renderRect(_rerenderRect);
//			_rerenderRect.x = _rerenderRect.y = _rerenderRect.height = _rerenderRect.width = 0;
		}

		/**
		 * 内部请求重绘
		 * @param whoDoesChange 是谁发生了变化
		 */
		bmd_render function rerender(whoDoesChange : BmdObject) : void
		{
			/*
			 *  计算重绘大小
			 *  记录计数器
			 */
			//_rerenderRect.追加rect 加上之前的位置、新的位置 局部绘制(2)
			//_rerenderRect = _rerenderRect.union(whoDoesChange.renderRect).union(whoDoesChange.globalRect);
			_needToRender++;
		}

		public function dispose() : void
		{
			//
			_render.dispose();
			//清除逐帧
			_renderTimer.removeEventListener(TimerEvent.TIMER, onRenderTimer);
			//清除位图
			bitmapData.dispose();
			_bmdObject = null;
		}

		/**
		 * 每秒渲染帧数
		 */
		public function get fps() : int
		{
			return _fps;
		}

		/**
		 * 每秒渲染帧数
		 */
		public function set fps(v : int) : void
		{
			if(v <= 0) return;
			_fps = v;
			_renderTimer.delay = 1000 / _fps;
		}

		//  ++++ 配合事件 ++++
		/**
		 * 设置了我和我父级的位置之后需要调用此方法，重新检测舞台相对位置
		 */
		public function validatePos() : void
		{
			_eventCatcher.calcBmpOffsetPos();
		}

		//获得事件捕捉器
		internal function get eventCatcher() : EventCatcher
		{
			return _eventCatcher;
		}

		//最近一次渲染的时间
		bmd_render function get totalTime() : int
		{
			return _render.totalTime;
		}

		//最近一次渲染了多少
		bmd_render function get totalObjCount() : int
		{
			return _render.totalObjCount;
		}
	}
}