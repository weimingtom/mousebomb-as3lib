package cn.flashj.multibmp
{

	/**
	 * 仅作根级容器
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2011-1-5
	 */
	public class MBmpRoot extends MBmpContainer
	{
		
		public function MBmpRoot()
		{
			super();
			_globalDepth = -1;
			_depthChildren = 0;
			_depthAllChilren = 0;
		}
		
	}
}
