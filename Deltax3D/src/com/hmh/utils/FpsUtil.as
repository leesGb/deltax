package com.hmh.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	import deltax.appframe.BaseApplication;
	import deltax.common.pool.Matrix3DPool;
	import deltax.gui.manager.GUIManager;
	
	/**
	 *
	 * FPS – 帧率，每秒帧数。 允许（在每次单击后）对自己程序的FPS进行自增，以用来测试运行中增加的性能。<br>
	 * MS – 渲染周期，渲染一帧所需要的毫秒速。<br>
	 * MEM – 所用的的总内存。<br>
	 * MAX – 你的程序运行到现在使用的内存的峰值（最大值）。<br>
	 *
	 * @author 中文参数注释：笑笑小兵
	 *
	 */
	public class FpsUtil extends Sprite
	{
		protected const WIDTH:uint = 100;
		protected const HEIGHT:uint = 150;
		
		protected var xml:XML;
		
		protected var text:TextField;
		protected var style:StyleSheet;
		
		protected var timer:uint;
		protected var fps:uint;
		protected var ms:uint;
		protected var ms_prev:uint;
		protected var mem:Number;
		protected var mem_max:Number;
		
		protected var theme:Object = {bg: 0x000033, fps: 0xffff00, ms: 0xffff00, mem: 0xffff00, memmax: 0xffff00,traverseTime: 0xffff00,renderTime: 0xffff00,guiTime: 0xffff00};
		
		
		
		/**
		 * <b>Stats</b> FPS, MS and MEM, all in one.
		 *
		 * @param  _theme         Example: { bg: 0x202020, fps: 0xC0C0C0, ms: 0x505050, mem: 0x707070, memmax: 0xA0A0A0 }
		 */
		public function FpsUtil()
		{
			mem_max = 0;
			
			xml = <xml><fps>FPS:</fps>
								<ms>MS:</ms>
								<traverseTime>TRA</traverseTime>
								<renderTime>RND</renderTime>
								<guiTime>GUI</guiTime>
								<mem>MEM:</mem>
								<memMax>MAX:</memMax>
								<face>FACE:</face>
								<effectUnit>EUnit:</effectUnit>
								<matrix3DCount>MCount:</matrix3DCount>
						</xml>;
			
			style = new StyleSheet();
			style.setStyle("xml", {fontSize: '10px', fontFamily: 'simsun', leading: '1px'});
			style.setStyle("fps", {color: hex2css(theme.fps)});
			style.setStyle("ms", {color: hex2css(theme.ms)});
			style.setStyle("mem", {color: hex2css(theme.mem)});
			style.setStyle("memMax", {color: hex2css(theme.memmax)});
			style.setStyle("traverseTime", {color: hex2css(theme.traverseTime)});
			style.setStyle("renderTime", {color: hex2css(theme.renderTime)});
			style.setStyle("guiTime", {color: hex2css(theme.guiTime)});
			style.setStyle("face", {color: hex2css(theme.renderTime)});
			style.setStyle("effectUnit", {color: hex2css(theme.guiTime)});
			style.setStyle("matrix3DCount", {color: hex2css(theme.guiTime)});
			
			text = new TextField();
			text.width = WIDTH;
			text.height = HEIGHT;
			text.styleSheet = style;
			text.condenseWhite = true;
			text.selectable = false;
			text.mouseEnabled = false;
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, dispose, false, 0, true);
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		private function init(e:Event):void
		{
			graphics.beginFill(theme.bg);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
			
			addChild(text);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function dispose(e:Event):void
		{
			graphics.clear();
			//
			while(numChildren > 0)
			{
				removeChildAt(0);
			}
			//
			removeEventListener(Event.ENTER_FRAME, update);
			
			
		}
		
		private function update(e:Event):void
		{
			timer = getTimer();
			//
			if(timer - 1000 > ms_prev)
			{
				ms_prev = timer;
				mem = Number((System.privateMemory * 0.000000954).toFixed(3));//0.000000954
				mem_max = mem_max > mem ? mem_max : mem;
				//
				xml.fps = "FPS: " + fps + " / " + stage.frameRate;
				xml.mem = "MEM: " + mem;
				xml.memMax = "MAX: " + mem_max;
				//
				fps = 0;
			}
			//
			fps++;
			//
			xml.ms = "PMS: " + (timer - ms);
			xml.traverseTime = "TRA:" + BaseApplication.TraverseSceneTime;
			xml.renderTime = "RND:" +BaseApplication.RenderSceneTime;
			xml.guiTime = "GUI:"+GUIManager.RENDER_TIME;
			xml.face = "FACE:"+BaseApplication.RenderTriangleNum;
			xml.effectUnit = "EUnit:"+BaseApplication.RenderEffectUnitNum;
			xml.matrix3DCount = "MCount:"+Matrix3DPool.matrix3DCount;
			ms = timer;
			//
			text.htmlText = xml.toString();
		}
		
		// .. Utils
		
		private function hex2css(color:int):String
		{
			return "#" + color.toString(16);
			
		}
	}
}