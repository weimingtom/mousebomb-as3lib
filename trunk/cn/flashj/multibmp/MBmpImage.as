package cn.flashj.multibmp
{

	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2011-1-6
	 */
	public class MBmpImage extends MBmpContainer
	{
		public function MBmpImage()
		{
			super();
		}

		public function born(data : Object) : void
		{
			//保存图像
			_bmd = data.bmd;
			_bounds = data.bounds;
			_bmp.bitmapData = this._bmd;
		}
	}
}
