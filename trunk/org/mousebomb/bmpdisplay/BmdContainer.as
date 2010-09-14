package org.mousebomb.bmpdisplay 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Bmd可承载子Bmd的容器
	 * 类似DisplayObjectContainer
	 * @author Mousebomb
	 * @date 2009-6-17
	 */
	public class BmdContainer extends BmdObject 
	{
		private var _childrenList : Array = [];

		public function BmdContainer()
		{
		}

		public function get numChildren() : int
		{
			return _childrenList.length;
		}
		/**
		 * 设置舞台引用
		 * 此时即ADD_TO_STAGE
		 */
		internal override function setStage(v : BmpDisplayObject) : void
		{
			super.setStage(v);
			//这里要加入对自己和子级的维护
			for(var i : int = numChildren - 1;i >= 0;--i)
			{
				var child : BmdObject = getChildAt(i);
				child.setStage(v);
			}
		}

		public function addChild(child : BmdObject) : void
		{
			//若已经存在，则将他位置放到末尾
			if(_childrenList.indexOf(child) > -1)
			{
				setChildIndex(child, numChildren - 1);
			}
			else
			{
				_childrenList.push(child);
			}
			//设置父容器引用
			child.setParent(this);
			//设置Bmp舞台引用
			child.setStage(bmpStage);
			//检测是否显示
			child.validateDisplay();
			//每次被addChild之后层级发生变化，调用渲染
			callReRender();
		}

		public function addChildAt(child : BmdObject,index : int) : void
		{
			//若已经存在，则将他位置切换
			if(_childrenList.indexOf(child) > -1)
			{
				setChildIndex(child, index);
			}
			else
			{
				_childrenList.splice(index, 0, child);
			}
			child.setParent(this);
			child.setStage(bmpStage);
			//检测是否显示
			child.validateDisplay();
			//每次被addChild之后层级发生变化，调用渲染
			callReRender();
		}

		public function getChildAt(index : int) : BmdObject
		{
			return _childrenList[index];
		}

		public function removeChild(child : BmdObject) : void
		{
			//从舞台移除会同时移除监听
			child.removeAllListener();
			var index : int = _childrenList.indexOf(child);
			_childrenList.splice(index, 1);
			//
			child.setParent(null);
			child.setStage(null);
			callReRender();
		}

		public function removeChildAt(index : int) : void
		{
			var child : BmdObject = getChildAt(index);
			child.setParent(null);			child.setStage(null);
			_childrenList.splice(index, 1);
			callReRender();
		}

		public function setChildIndex(child : BmdObject,index : int) : void
		{
			var oldindex : int = _childrenList.indexOf(child);
			_childrenList.splice(oldindex, 1);
			_childrenList.splice(index, 0, child);
		}

		public function getChildIndex(child : BmdObject) : int
		{
			return _childrenList.indexOf(child);
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
				//若需要校验，则检查每一项是否都是我现有子级 TODO
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
			//层级发生变化，调用渲染
			callReRender();
		}

		/**
		 * 释放资源;
		 * 清除子级;
		 * 若有父级，则自动从父级移除
		 */
		public override function dispose() : void
		{
			//这里要加入对自己和子级的释放
			for(var i : int = numChildren - 1;i >= 0;--i)
			{
				var child : BmdObject = getChildAt(i);
				child.dispose();
			}
			//super
			super.dispose();
		}

		/**
		 * 截取此刻象素快照
		 * 此刻自己的bmd放最下，然后递归复制子级的bmd
		 */
		override public function getPixelShot() : BitmapData
		{
			var shot : BitmapData = _bmd.clone();
			var maxI : int = numChildren;
			for(var i : int = 0;i < maxI;i++)
			{
				var child : BmdObject = getChildAt(i);
				var sourceRect : Rectangle = new Rectangle(0, 0, child.width, child.height);
				var destPoint : Point = new Point(child.x, child.y);
				shot.copyPixels(child.getPixelShot(), sourceRect, destPoint, null, null, true);
			}
			return shot;
		}

		internal override function  validateRectWhenMove(xAdd : Number,yAdd : Number) : void
		{
			super.validateRectWhenMove(xAdd, yAdd);
			//对子级调用
			for(var i : int = numChildren - 1;i >= 0;--i)
			{
				var child : BmdObject = getChildAt(i);
				child.validateRectWhenMove(xAdd, yAdd);
			}
		}
	}
}
