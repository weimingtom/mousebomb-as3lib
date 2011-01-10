package cn.flashj.multibmp
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2011-1-5
	 */
	public class MBmpStage extends Sprite
	{

		// 交互的监听承载者
		private var _interactiveContainer : DisplayObjectContainer;

		internal var _eventCatcher : MBmpEventCatcher;
		// 深度变化计数器
		private var _depthChange : uint;

		private static var _shape : Shape;
		staticInit();
		private static function staticInit() : void
		{
			_shape = new Shape();
		}

		//
		private var _bmdObject : MBmpRoot;

		public function MBmpStage(bmdObject : MBmpRoot)
		{
			_bmdObject = bmdObject;
			_bmdObject.setStage(this);
			addChild(_bmdObject.bmp);
			_interactiveContainer = this;
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(Event.REMOVED, onLostStage);
			_eventCatcher = new MBmpEventCatcher(this);
			_shape.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * 对显示列表维护操作
		 */
		protected function onEnterFrame(event : Event) : void
		{
			validateDepth();
		}

		/**
		 * 设置根级bmd
		 */
		public function setBmdObject(bmdObject : MBmpRoot) : void
		{
			_bmdObject = bmdObject;
			_bmdObject.setStage(this);
			addChild(_bmdObject.bmp);
		}

		// 从舞台移除的时候解除捕捉
		private function onLostStage(event : Event) : void
		{
			// 以_interactiveContainer为对象
			if (event.target == this)
				_eventCatcher.clearEvents(_interactiveContainer);
		}

		// 加入舞台开始捕捉
		private function onStage(event : Event) : void
		{
			// 以_interactiveContainer为对象
			if (event.target == this)
				_eventCatcher.initEvents(_interactiveContainer);
		}

		// 1.统计效率用的 2.计算总深度
		internal var totalObjCount : int = 0;

		/**
		 * 立即将深度重新显示
		 */
		internal function validateDepth() : void
		{
//			TimerCounter.startTask("validateDepth");
			// 根据_globalDepth
			if (_depthChange)
			{
				_depthChange = 0;
				// 开始处理
				totalObjCount = 0;
				var maxI : int = _bmdObject.numChildren;
				for (var i : int = 0;i < maxI;i++)
				{
					// 目标显示对象
					var child : MBmpObject = _bmdObject.getChildAt(i);
					// 目标index
					var index : int = ++totalObjCount;
					if (child.globalDepth != index)
					{
						child._globalDepth = index;
						this.setChildIndex(child.bmp, index);
					}
					validateChildrenDepth(child as MBmpContainer);
				}
//				trace(totalObjCount + "个对象");
//				TimerCounter.endTask("validateDepth");
			}
		}

		/**
		 * 对某个容器进行内部的递归
		 */
		private function validateChildrenDepth(container : MBmpContainer) : void
		{
			var maxI : int = container.numChildren;
			for (var i : int = 0;i < maxI;i++)
			{
				var child : MBmpObject = container.getChildAt(i);
				var index : int = ++totalObjCount;
				if (child.globalDepth != index)
				{
					child._globalDepth = index;
					this.setChildIndex(child.bmp, index);
				}
				validateChildrenDepth(child as MBmpContainer);
			}
		}

		/**
		 * 提交改动，将会在下一帧设置
		 */
		internal function commitDepthChange() : void
		{
			_depthChange++;
		}

		/**
		 * 释放资源
		 * 这里会释放渲染和最后渲染的位图，解除对bmdObject的引用。
		 * 但不会调用BmdObject.dispose，以便其他地方使用，若有需要，需要手动释放BmdObject。
		 */
		public function dispose() : void
		{
			_shape.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_bmdObject.dispose();
			_bmdObject = null;
		}

		public function get eventCatcher() : MBmpEventCatcher
		{
			return _eventCatcher;
		}

		public function get interactiveContainer() : DisplayObjectContainer
		{
			return _interactiveContainer;
		}

		public function set interactiveContainer(v : DisplayObjectContainer) : void
		{
			_interactiveContainer = v;
		}

		/**
		 * 用于监听onEnterFrame的
		 */
		public function get shape() : Shape
		{
			return _shape;
		}
	}
}
