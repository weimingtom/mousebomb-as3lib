package cn.flashj.multibmp
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2011-1-5
	 */
	public class MBmpObject
	{
		// 父级内的相对x
		protected var _x : int;
		// 父级内的相对y
		protected var _y : int;

		// 舞台x (注册点所在位置)
		internal var _globalX : int;
		// 舞台y (注册点)
		internal var _globalY : int;

		// 舞台显示层级(我在舞台中的深度)
		internal var _globalDepth : int = -1;

		protected var _bmp : RefBitmap;
		protected var _bmd : BitmapData;
		// 当前的bounds
		protected var _bounds : Rectangle;

		public var name : String;

		internal var _isDisplay : Boolean = true;

		internal var _bornFromPool : Boolean = false;


		// 父级
		protected var _parent : MBmpContainer;
		/**
		 * 加到Bmp舞台上的对象会有此引用
		 */
		protected var _bmpStage : MBmpStage;

		// 回调函数
		public var onYChange : Function;
		public var onXChange : Function;

		public function MBmpObject()
		{
			_bmp = new RefBitmap();
			_bmp.mbRef = this;
		}

		/**
		 * 由本地坐标点转成全局坐标点
		 * 这个表示的是下一次渲染时“应该在的点”，而不是最近一次完成渲染时候产生的点
		 */
		public function localToGlobal() : Point
		{
			var ending : Point = new Point(x, y);
			var parentContainer : MBmpContainer = this._parent;
			while (parentContainer)
			{
				ending.x += parentContainer.x;
				ending.y += parentContainer.y;
				parentContainer = parentContainer.parent;
			}
			return ending;
		}

		public function get x() : int
		{
			return _x;
		}

		public function set x(v : int) : void
		{
			if (_x == v) return;
			var xAdd : int = v - _x;
			$validateRectWhenMove(xAdd, 0);
			_x = v;
			if (onXChange != null) onXChange(v);
		}

		public function get y() : int
		{
			return _y;
		}

		public function set y(v : int) : void
		{
			if (_y == v) return;
			var yAdd : int = v - _y;
			$validateRectWhenMove(0, yAdd);
			_y = v;
			if (onYChange != null) onYChange(v);
		}

		public function get width() : Number
		{
			return _bounds.width;
		}

		public function get height() : Number
		{
			return _bounds.height;
		}


		public function get parent() : MBmpContainer
		{
			return _parent;
		}

		/**
		 * 内部：由于注册点位置变化导致的位移，需要重新计算位置
		 */
		internal function $validateRectWhenMove(xAdd : int, yAdd : int) : void
		{
			// 对全局坐标进行更新
			_globalX += xAdd;
			_globalY += yAdd;
			validatePos();
		}


		/**
		 * 立即按照数据更新显示位置
		 */
		public function validatePos() : void
		{
			// 修改实际显示坐标
			_bmp.x = _globalX + _bounds.x;
			_bmp.y = _globalY + _bounds.y;
		}

		/**
		 * 立即更新深度显示
		 */
		public function validateDepth() : void
		{
			_bmpStage.commitDepthChange();
//			//
//			if (_bmpStage.getChildIndex(bmp) != _globalDepth)
//			{
//				_bmpStage.setChildIndex(bmp, _globalDepth);
//			}
		}

		/**
		 * 立即更新显示
		 */
		public function validate() : void
		{
			validatePos();
			validateDepth();
		}

		internal function setParent(parent : MBmpContainer) : void
		{
			/*
			 * 设置父级引用，
			 * 同时要计算global坐标
			 */
			_parent = parent;
			// 坐标
			var pos : Point = localToGlobal();
			_globalX = pos.x;
			_globalY = pos.y;
			//
			validatePos();
		}

		public function get bmpStage() : MBmpStage
		{
			return _bmpStage;
		}

		internal function setStage(v : MBmpStage) : void
		{
			if (v == _bmpStage)
			{
				return;
			}
			// 如果由有舞台变成无舞台 则remove所有；如果由无舞台变成有舞台，则add；如果由一个舞台换成另一个舞台则remove+add
			// 化简= 如果之前有舞台 则remove，如果有新舞台则add
			if (_bmpStage != null)
			{
				$validateDisplayInStage(false);
			}
			_bmpStage = v;
			if (v != null)
			{
				$validateDisplayInStage(true);
			}
		}

		/**
		 * 重设是否在舞台上
		 * 当舞台变化时调用
		 * @param inStage 变化后 有舞台还是没舞台，即是要add还是要remove
		 */
		internal function $validateDisplayInStage(inStage : Boolean) : void
		{
			if (inStage)
			{
				// _bmpStage.addChildAt(_bmp, _globalDepth);
				_bmpStage.addChild(_bmp);
				_bmpStage.commitDepthChange();
			}
			else
			{
				_bmpStage.removeChild(_bmp);
			}
		}

		//	//  移动之后的总
		// public var needValidate : Boolean = false;

		/**
		 * 释放资源
		 * 释放所有监听
		 */
		public function dispose() : void
		{
			// 有父级则自动移除.
			if (this.parent)
			{
				// 释放监听在removeChild里已经做了，所以不需要额外调用
				parent.removeChild(this);
			}
			else
			{
				// 只是释放监听
				// removeAllListener();
			}
			// this._bmp = null;
		}

		public function get bmp() : Bitmap
		{
			return _bmp;
		}

		public function get isDisplay() : Boolean
		{
			// TODO 如果不在画面内 应该为false
			return _isDisplay;
		}

		public function get globalDepth() : int
		{
			return _globalDepth;
		}

		/**
		 * 设置全局深度
		 */
		public function set globalDepth(v : int) : void
		{
			_globalDepth = v;
		}


	}
}
