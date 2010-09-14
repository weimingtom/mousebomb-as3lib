/**
* 可移动对象
* 增强型Sprite,采用fl.transitions包的动画
* 出生坐标自动根据add到舞台的坐标确定
* Mousebomb
* 08.8.13
* */
package org.mousebomb.display
{
	import flash.display.Sprite;
	import flash.events.*;
	import org.mousebomb.display.MovableObjectMoveMode;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	
	public class MovableObject extends Sprite
	{
		private var __tweenX:Tween;
		private var __tweenY:Tween;
		private var __tweenScaleX:Tween;
		private var __tweenScaleY:Tween;
		
		private var __spawnX:Number=0.0;
		private var __spawnY:Number=0.0;
		private var __spawnScale:Number=1.0;
		
		public var __moveMode:uint;
		
		/**加载到舞台*/
		private function onLoad(e:Event=null):void
		{
			__spawnX=this.x;
			__spawnY=this.y;
			__spawnScale=this.scaleX;
			this.scaleX=__spawnScale;
			this.scaleY=__spawnScale;
			__tweenX = new Tween(this, "x", Regular.easeInOut, this.x, __spawnX, 0.2, true);
			__tweenY = new Tween(this, "y", Regular.easeInOut, this.y, __spawnY, 0.2, true);
			__tweenScaleX = new Tween(this, "scaleX", Regular.easeInOut, this.scaleX, 1, 1, true);
			__tweenScaleY = new Tween(this, "scaleY", Regular.easeInOut, this.scaleY, 1, 1, true);
		}
		
		
		/**获得渐变方法*/
		private function tweenFunction():Function
		{
			switch(this.__moveMode)
			{
				case MovableObjectMoveMode.UNIFORMSPEED:
					return	None.easeNone;
					break;
				case MovableObjectMoveMode.EASEIN:
					return	Regular.easeIn;
					break;
				case MovableObjectMoveMode.EASEOUT:
					return	Regular.easeOut;
					break;
				case MovableObjectMoveMode.EASEINOUT:
					return	Regular.easeInOut;
					break;
				default:
					return null;
			}
		}
		
		/**动画渐变x*/
		private function tweenX(toX:Number,durationSec:Number):void
		{
			with(__tweenX)
			{
				obj=this;
				prop="x";
				func=tweenFunction();
				begin=this.x;
				finish=toX;
				duration=durationSec;
				useSeconds=true;
			}	
			__tweenX.start();
		}
		/**动画渐变y*/
		private function tweenY(toY:Number,durationSec:Number):void
		{
			with(__tweenY)
			{
				obj=this;
				prop="y";
				func=tweenFunction();
				begin=this.y;
				finish=toY;
				duration=durationSec;
				useSeconds=true;
			}	
			__tweenY.start();
		}
		/**动画渐变scaleX*/
		private function tweenScaleX(toScaleX:Number,durationSec:Number):void
		{
			with(__tweenScaleX)
			{
				obj=this;
				prop="scaleX";
				func=tweenFunction();
				begin=this.scaleX;
				finish=toScaleX;
				duration=durationSec;
				useSeconds=true;
			}	
			__tweenScaleX.start();
		}
		/**动画渐变scaleY*/
		private function tweenScaleY(toScaleY:Number,durationSec:Number):void
		{
			with(__tweenScaleY)
			{
				obj=this;
				prop="scaleY";
				func=tweenFunction();
				begin=this.scaleY;
				finish=toScaleY;
				duration=durationSec;
				useSeconds=true;
			}	
			__tweenScaleY.start();
		}
		
		/*/////////////////PUBLIC/////////////////*/
		/**
		* 初始化
		* @param	moveMode	移动模式(补间动画的模式)
		*/
		public function MovableObject(moveMode:uint=MovableObjectMoveMode.EASEIN)
		{
			trace("new MovableObject(" + arguments.join(",") + "):" + this + "\n");
			this.addEventListener(Event.ADDED_TO_STAGE,onLoad);
			
			__moveMode=moveMode;
		}
		
		/**恢复为出生坐标、形态*/
		public function recover(duration:Number=0.5):void
		{
			this.moveTo(__spawnX,__spawnY,duration);
			this.scaleTo(__spawnScale,duration);
		}
		
		/**
		* 移动坐标
		* @param	toX	移动目标X坐标
		* @param	toY	移动目标Y坐标
		* @param	duration	动画秒数
		*/
		public function moveTo(toX:Number,toY:Number,duration:Number=0.5):void
		{
			this.tweenX(toX,duration);
			this.tweenY(toY,duration);
		}
		
		/**
		* 缩放
		* @param	size	大小比例 (1.0)
		* @param	duration	动画秒数
		*/
		public function scaleTo(size:Number,duration:Number=0.5):void
		{
			this.tweenScaleX(size,duration);
			this.tweenScaleY(size,duration);
		}
		/**
		 * 停止一切动画
		 */
		public function stopTween():void
		{
			this.__tweenScaleX.stop();
			this.__tweenX.stop();
			this.__tweenScaleY.stop();
			this.__tweenY.stop();
		}
	}

}