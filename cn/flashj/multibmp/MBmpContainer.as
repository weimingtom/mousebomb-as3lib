package cn.flashj.multibmp
{

	import flash.geom.Point;

	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2011-1-5
	 */
	public class MBmpContainer extends MBmpEventDispatcher
	{
		public function MBmpContainer()
		{
		}

		private var _childrenList : Array = [];

		public function get numChildren() : int
		{
			return _childrenList.length;
		}

		/**
		 * 设置父级（或更换父级）\
		 * 此时即ADDED
		 */
		override internal function setParent(parent : MBmpContainer) : void
		{
			/*
			 * 设置父级引用，
			 * 同时要计算global坐标
			 */
			_parent = parent;
			// 坐标
			var pos : Point = localToGlobal();
			var globalXAdd : Number = pos.x - _globalX;
			var globalYAdd : Number = pos.y - _globalY;
			_globalX = pos.x;
			_globalY = pos.y;
			// 让子级坐标全局换算
			foreachLevelChild(function(bo : MBmpObject) : void
			{
				bo._globalX += globalXAdd;
				bo._globalY += globalYAdd;
			});
			validatePos();
		}

		override public function validatePos() : void
		{
			super.validatePos();
			// 层级
			for (var i : int = numChildren - 1;i >= 0;--i)
			{
				var child : MBmpObject = getChildAt(i);
				child.validatePos();
			}
		}

		/**
		 * 设置舞台引用
		 * 此时即ADD_TO_STAGE
		 */
		internal override function setStage(v : MBmpStage) : void
		{
			super.setStage(v);
			// 这里要加入对自己和子级的维护
			for (var i : int = numChildren - 1;i >= 0;--i)
			{
				var child : MBmpObject = getChildAt(i);
				child.setStage(v);
			}
		}

		internal override function  $validateRectWhenMove(xAdd : int, yAdd : int) : void
		{
			super.$validateRectWhenMove(xAdd, yAdd);
			// 联合体无需检查子级
			// 对子级调用 遍历检测
			for (var i : int = numChildren - 1;i >= 0;--i)
			{
				var child : MBmpObject = getChildAt(i);
				child.$validateRectWhenMove(xAdd, yAdd);
			}
		}

		/**
		 * 遍历所有子级执行
		 */
		internal function foreachLevelChild(func : Function) : void
		{
			for (var i : int = numChildren - 1;i >= 0;--i)
			{
				var child : MBmpObject = getChildAt(i);
				func(child);
				if (child is MBmpContainer)
				{
					(child as MBmpContainer).foreachLevelChild(func);
				}
			}
		}

		public function setChildIndex(child : MBmpObject, index : int) : void
		{
			var oldindex : int = _childrenList.indexOf(child);
			_childrenList.splice(oldindex, 1);
			_childrenList.splice(index, 0, child);
		}

		public function getChildIndex(child : MBmpObject) : int
		{
			return _childrenList.indexOf(child);
		}

		public function getChildAt(index : int) : MBmpObject
		{
			return _childrenList[index];
		}


		/**
		 * 加的时候目前只支持一级一级加
		 */
		public function addChild(child : MBmpObject) : void
		{
			if(_bmpStage == null) {throw new Error("目前仅支持一级一级加，未在舞台上的对象"+this.name+"不可作为容器使用");}
			// 若已经存在，则忽略
			if (_childrenList.indexOf(child) > -1)
			{
				return ;
			}
			var insertIndex : int = _childrenList.push(child) - 1;
			// 设置父容器引用
			child.setParent(this);
			// 每次被addChild之后层级发生变化，调用渲染
			// 被加入的哥们 设置层级值
			child._depth = insertIndex;
			child._globalDepth = this._globalDepth + child._depth + 1;
			//
			depthChildren += 1;
			// 设置Bmp舞台引用
			child.setStage(bmpStage);
			// 影响到父级中其他内容的层级后移
			if (parent)
			{
				var others : Array = parent.deeperThanMe(this);
				for each (var bc : MBmpContainer in others)
				{
					bc.$validateDepthWhenChange(1);
				}
			}
			// 显示更新
			_bmpStage.addChildAt(child.bmp, child._globalDepth);
		}

		/**
		 * 移除的时候会自动去除child的所有监听
		 * 所以若有需要，高层需要重新加入监听
		 */
		public function removeChild(child : MBmpObject) : void
		{
			// 从舞台移除会同时移除监听
			// child.removeAllListener();
			var index : int = _childrenList.indexOf(child);
			if (index == -1)
			{
				trace("not my child");
				return;
			}
			_childrenList.splice(index, 1);
			//
			child.setParent(null);
			child.setStage(null);
			// 子级层级变化
			var deltaDepth : int = -child._depthAllChilren - 1;
			depthChildren += deltaDepth;
			// 影响到的其他子级的子级
			var bc : MBmpContainer;
			var others : Array = deeperThanMe(child);
			for each (bc in others)
			{
				bc.$validateDepthWhenChange(deltaDepth);
			}
			// 影响到父级的其他子级
			if (parent)
			{
				others = parent.deeperThanMe(this);
				for each (bc in others)
				{
					bc.$validateDepthWhenChange(-1);
				}
			}
		}


		/**
		 * 释放资源;
		 * 清除子级;
		 * 若有父级，则自动从父级移除
		 */
		public override function dispose() : void
		{
			// 这里要加入对自己和子级的释放
			for (var i : int = numChildren - 1;i >= 0;--i)
			{
				var child : MBmpObject = getChildAt(i);
				child.dispose();
			}
			// super
			super.dispose();
		}


		/**
		 * 获得子级中在 me 之后的容器
		 */
		internal function deeperThanMe(me : MBmpObject) : Array
		{
			var startIndex : int = me._depth + 1;
			return _childrenList.slice(startIndex, -1);
		}

		/**
		 * 当浅级更改时，深级内容要重算深度
		 * @param depthAdd 层级改动值 ,正数=更深，负数=更浅
		 */
		internal function $validateDepthWhenChange(depthAdd : int) : void
		{
			// 本级深度值更新
			_depth += depthAdd;
			_globalDepth += depthAdd;
			// 遍历所有子级深度值更新
			foreachLevelChild(function(bo : MBmpObject) : void
			{
				bo._globalDepth += depthAdd;
			});
			_globalDepth += depthAdd;
			// 显示更改
			validateDepth();
		}

		override public function validateDepth() : void
		{
			super.validateDepth();
			// 子级处理
			// 遍历子级的_globalDepth重设
			foreachLevelChild(function(bo : MBmpObject) : void
			{
				_bmpStage.setChildIndex(bo.bmp, bo._globalDepth);
			});
		}

		/**
		 * 一级子级使用的深度,没有children的话为0
		 */
		public function get depthChildren() : int
		{
			return _depthChildren;
		}

		/**
		 * 设置当前层级的子级数量
		 */
		public function set depthChildren(v : int) : void
		{
			var deltaDepthChildren : int = v - _depthChildren;
			_depthChildren = v;
			if (parent)
				parent.depthAllChilren += deltaDepthChildren;
		}

		// 所有子级所用的深度
		public function get depthAllChilren() : int
		{
			return _depthAllChilren;
		}

		// 所有子级所用的深度
		public function set depthAllChilren(v : int) : void
		{
			var delta : int = v - _depthAllChilren;
			_depthAllChilren = v;
			if (parent)
				parent.depthAllChilren += delta;
		}

	}
}
