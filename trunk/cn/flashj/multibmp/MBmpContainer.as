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
			super();
		}

		private var _childrenList : Array = [];

		// 1级子级使用的长度
		internal var _depthChildren : int = 0;
		// 所有子级所用的深度
		internal var _depthAllChilren : int = 0;

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
		 * 设置子显示列表
		 * 通常用于层级排序后的写入操作
		 * 	(如果用setChildIndex的方法，会浪费开销在数组的splice上，所以在外面把层级排好后设置进来)
		 * 注意：此方法直接设置子级列表 @param list 的元素应该是我的现有子级。
		 * @param verify 是否校验list的每一项是否是子级，默认因为效率原因不做校验，这要求调用者必须保证数据完整性
		 * （校验的消耗太大：1560个对象的排序，如果有校验耗时20ms，无校验耗时0ms）
		 */
		public function setChildList(list : Array , verify : Boolean = false) : void
		{
			if(list.length != _childrenList.length)
			{
				throw new Error("设置子级显示列表错误：子级数量不匹配"); 
				return ;
			}
			if(verify)
			{
				//若需要校验，则检查每一项是否都是我现有子级 
				for each(var child : * in list)
				{
					if(_childrenList.indexOf(child) == -1)
					{
						throw new Error("设置子显示列表校验失败:不存在的child");
						return;
					}
				}
			}
			_childrenList = list;
			// 层级发生变化，调用渲染
			_bmpStage.commitDepthChange();
		}


		/**
		 * 加的时候目前只支持一级一级加
		 */
		public function addChild(child : MBmpObject) : void
		{
			// 若已经存在，则忽略
			if (_childrenList.indexOf(child) > -1)
			{
				return ;
			}
			 _childrenList.push(child) ;
			// 设置父容器引用
			child.setParent(this);
			// 设置Bmp舞台引用
			child.setStage(bmpStage);
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


	}
}
