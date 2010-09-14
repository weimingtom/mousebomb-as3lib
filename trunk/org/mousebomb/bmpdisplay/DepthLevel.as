package org.mousebomb.bmpdisplay 
{

	/**
	 * 本来打算作为一种数据类型
	 * 已经弃用
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2010-6-23
	 */
	public class DepthLevel extends Object 
	{
		private var _bits : Array = [];

		/**
		 * 深度层级数据结构
		 * 1
		 * 2
		 * 1
		 */
		public function DepthLevel()
		{
		}

		/**
		 * 设置位值
		 * 从0开始
		 */
		public function setBit(bit : int,value : int) : void
		{
			_bits[bit] = value;
		}

		public function getBit(bit : int) : int
		{
			return _bits[bit];
		}

		/**
		 * 比较我是否大于level
		 * 低层为高位
		 */
		public function greaterThan(level : DepthLevel) : Boolean
		{
			for (var i : int = 0 ;i < _bits.length;i++)
			{
				if(this.getBit(i) > level.getBit(i)) return true;
			}
			return false;
		}
	}
}
