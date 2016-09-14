package deltax.gui.manager 
{
	import deltax.appframe.BaseApplication;
	import deltax.common.error.Exception;
	import deltax.common.error.SingletonMultiCreateError;
	import deltax.common.math.MathUtl;
	import deltax.graphic.render2D.font.DeltaXFontRenderer;
	import deltax.graphic.render2D.rect.DeltaXRectRenderer;
	import deltax.gui.base.style.WindowStyle;
	import deltax.gui.component.DeltaXEdit;
	import deltax.gui.component.DeltaXTooltipWnd;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.ICustomTooltip;
	import deltax.gui.component.event.DXWndEvent;
	import deltax.gui.component.event.DXWndKeyEvent;
	import deltax.gui.component.event.DXWndMouseEvent;
	
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 *	gui管理器 
	 * @author lees
	 * @date 2016/03/28
	 * @QQ:625498747   email:lees_test02@163.com
	 */	
	
	public class GUIManager 
	{
		private static const ACCEKEY_CTRL:uint = 268435456;
		private static const ACCEKEY_SHIFT:uint = 536870912;
		private static const ACCEKEY_ALT:uint = 1073741824;
		private static const WND_POSITION_MAP_SIZE:uint = 16;
		
		private static var m_instance:GUIManager;
		
		public static var CUR_ROOT_WND:DeltaXRootWnd;
		
		/***/
		private var m_cursorPos:Point;
		private var m_curMouseEvent:MouseEvent = null;
		private var m_keyIsPress:Boolean = false;
		private var m_ignoreNextKeyup:Boolean = false;
		private var m_rootWnd:DeltaXRootWnd;
		private var m_moduleWnd:DeltaXWindow;
		private var m_holdWnd:DeltaXWindow;
		private var m_lastMouseOverWnd:DeltaXWindow;
		private var m_curTooltipWnd:DeltaXWindow;
		private var m_cursorAttachWnd:DeltaXWindow;
		private var m_commonTooltipsWnd:DeltaXTooltipWnd;
		private var m_globalCursorName:String;
		private var m_guiHandler:IGUIHandler;
		private var m_holdWndMoving:Boolean;
		private var m_preMouseOverTime:uint;
		private var m_attachPos:Point;
		private var m_curHeldPos:Point;
		private var m_preHoldTime:uint;
		private var m_curEvent:Event;
		private var m_preRenderTime:uint;
		private var m_holdingSameWnd:Boolean;
		private var m_continuosMouseDownPassTime:int;
		private var m_mapAcceKey:Dictionary;
		private var m_listModuleWnd:Vector.<DeltaXWindow>;
		private var m_pixelXPerPositionUnit:int = 0;
		private var m_pixelYPerPositionUnit:int = 0;
		private var m_wndPositionMapInvalid:Boolean = true;
		private var m_wndPositionMap:Vector.<Vector.<Vector.<DeltaXWindow>>>;
		private var m_lastMouseUpTime:uint;
		private var m_tempAccelKeysToUnregister:Vector.<Object>;
		private var m_tempAccelKeysToUnregisterCount:uint;
		private var m_curShowingCustomTooltip:DeltaXWindow;
		private var m_componentToTooltipUIMap:Dictionary;
		
		public function GUIManager($handler:IGUIHandler=null)
		{
			this.m_cursorPos = new Point();
			this.m_attachPos = new Point();
			this.m_curHeldPos = new Point();
			this.m_mapAcceKey = new Dictionary();
			this.m_listModuleWnd = new Vector.<DeltaXWindow>();
			this.m_tempAccelKeysToUnregister = new Vector.<Object>();
			this.m_componentToTooltipUIMap = new Dictionary(false);
			
			if (m_instance)
			{
				throw (new SingletonMultiCreateError(GUIManager));
			}
			m_instance = this;
			
			this.m_guiHandler = $handler;
			this.m_rootWnd = new DeltaXRootWnd();
			CUR_ROOT_WND = this.m_rootWnd;
			
			this.m_commonTooltipsWnd = new DeltaXTooltipWnd();
			
			this.m_wndPositionMap = new Vector.<Vector.<Vector.<DeltaXWindow>>>();
			
			var i:uint = 0;
			var j:uint = 0;
			while (i < WND_POSITION_MAP_SIZE) 
			{
				this.m_wndPositionMap[i] = new Vector.<Vector.<DeltaXWindow>>();
				j = 0;
				while (j < WND_POSITION_MAP_SIZE) 
				{
					this.m_wndPositionMap[i][j] = new Vector.<DeltaXWindow>();
					j++;
				}
				i++;
			}
		}
		
		public static function get instance():GUIManager
		{
			return m_instance;
		}
		
		public function get rootWnd():DeltaXWindow
		{
			return this.m_rootWnd;
		}
		
		public function get width():int
		{
			return this.m_rootWnd.width;
		}
		
		public function get height():int
		{
			return this.m_rootWnd.height;
		}
		
		public function get xCursor():int
		{
			return this.m_cursorPos.x;
		}
		
		public function get yCursor():int
		{
			return this.m_cursorPos.y;
		}
		
		public function get cursorPos():Point
		{
			return this.m_cursorPos.clone();
		}
		
		public function get lastMouseOverWnd():DeltaXWindow
		{
			if (this.m_wndPositionMapInvalid)
			{
				var wnd:DeltaXWindow = this.detectTopWnd(this.m_cursorPos);
				if (this.m_lastMouseOverWnd != wnd)
				{
					this.m_preMouseOverTime = getTimer();
				}
				this.m_lastMouseOverWnd = wnd;
			}
			
			return this.m_lastMouseOverWnd;
		}
		
		public function get cursorAttachWnd():DeltaXWindow
		{
			return this.m_cursorAttachWnd;
		}
		public function set cursorAttachWnd(va:DeltaXWindow):void
		{
			if (va)
			{
				this.m_attachPos.x = this.xCursor - va.globalX;
				this.m_attachPos.y = this.yCursor - va.globalY;
			}
			
			this.m_cursorAttachWnd = va;
		}
		
		public function get holdWnd():DeltaXWindow
		{
			return this.m_holdWnd;
		}
		
		public function get holdPos():Point
		{
			return this.m_curHeldPos.clone();
		}
		public function set holdPos(va:Point):void
		{
			this.m_curHeldPos.copyFrom(va);
		}
		
		public function set commonTooltipsRes(url:String):void
		{
			this.m_commonTooltipsWnd.createFromRes(url, this.rootWnd);
		}
		public function get commonTooltipsWnd():DeltaXWindow
		{
			return this.m_commonTooltipsWnd;
		}
		
		public function get curWndSelectable():Boolean
		{
			return (this.m_lastMouseOverWnd is DeltaXEdit) && DeltaXEdit(this.m_lastMouseOverWnd).editable;
		}
		
		public function get curWndEditable():Boolean
		{
			return (this.m_rootWnd.focusWnd is DeltaXEdit) && DeltaXEdit(this.m_rootWnd.focusWnd).editable;
		}
		
		public function get curTooltipWnd():DeltaXWindow
		{
			return this.m_curTooltipWnd;
		}
		
		public function get curShowingCustomTooltip():DeltaXWindow
		{
			return this.m_curShowingCustomTooltip;
		}
		
		public function get globalCursorName():String
		{
			return this.m_globalCursorName;
		}
		public function set globalCursorName(name:String):void
		{
			this.m_globalCursorName = name;
		}
		
		/**
		 * 根容器初始化
		 * @param $w
		 * @param $h
		 */		
		public function init($w:uint, $h:uint):void
		{
			this.m_rootWnd.creatAsEmptyContain(null, $w, $h);
		}
		
		/**
		 * 窗口位置发生变化
		 */		
		public function invalidWndPositionMap():void
		{
			this.m_wndPositionMapInvalid = true;
		}
		
		/**
		 * 鼠标隐藏
		 */		
		public function hideMouse():void
		{
			Mouse.hide();
		}
		
		/**
		 * 鼠标显示
		 */		
		public function showMouse():void
		{
			Mouse.show();
		}
		
		/**
		 * 鼠标设置
		 * @param name
		 */		
		public function setCursor(name:String):void
		{
			if (this.m_guiHandler && name)
			{
				this.m_guiHandler.doSetCursor(name);
			}
		}
		
		/**
		 * 获取最上面的窗口
		 * @param p
		 * @return 
		 */		
		public function detectTopWnd(p:Point):DeltaXWindow
		{
			var wnds:Array = this.getWindowUnderPoint(p, 1);
			return wnds.length ? wnds[0] : null;
		}
		
		/**
		 * 获取鼠标点下的窗口列表
		 * @param p
		 * @param count
		 * @return 
		 */		
		public function getWindowUnderPoint(p:Point, returnCount:uint=4294967295):Array
		{
			if (returnCount == 0)
			{
				return [];
			}
			
			this.checkWndPositionMap();
			
			var xr:int = p.x / this.m_pixelXPerPositionUnit;
			var yr:int = p.y / this.m_pixelYPerPositionUnit;
			if (xr < 0 || xr >= WND_POSITION_MAP_SIZE)
			{
				return [];
			}
			
			if (yr < 0 || yr >= WND_POSITION_MAP_SIZE)
			{
				return [];
			}
			
			var wnd:DeltaXWindow = null;
			var r:Array = [];
			var list:Vector.<DeltaXWindow> = this.m_wndPositionMap[yr][xr];
			var idx:int = list.length - 1;
			while (idx >= 0) 
			{
				wnd = list[idx];
				if (wnd.isInWndArea(p.x, p.y))
				{
					r.push(wnd);
					if (r.length >= returnCount)
					{
						return r;
					}
				}
				idx--;
			}
			
			return r;
		}
		
		/**
		 * 检测窗口位置列表是否发生变化，如果是列表会重置
		 */		
		private function checkWndPositionMap():void
		{
			if (!this.m_wndPositionMapInvalid)
			{
				return;
			}
			
			this.m_pixelXPerPositionUnit = (this.m_rootWnd.width / WND_POSITION_MAP_SIZE) + 1;
			this.m_pixelYPerPositionUnit = (this.m_rootWnd.height / WND_POSITION_MAP_SIZE) + 1;
			
			var xIdx:uint = 0;
			var yIdx:uint = 0;
			while (yIdx < WND_POSITION_MAP_SIZE) 
			{
				xIdx = 0;
				while (xIdx < WND_POSITION_MAP_SIZE) 
				{
					this.m_wndPositionMap[yIdx][xIdx].length = 0;
					xIdx ++;
				}
				yIdx++;
			}
			
			this.buildWndPositionMap(this.m_rootWnd);
			this.m_wndPositionMapInvalid = false;
		}
		
		/**
		 * 窗口位置构建
		 * @param rWnd
		 */		
		private function buildWndPositionMap(rWnd:DeltaXWindow):void
		{
			if (rWnd.mouseEnabled && rWnd.enable)
			{
				var xr:int = rWnd.globalX / this.m_pixelXPerPositionUnit;
				var yr:int = rWnd.globalY / this.m_pixelYPerPositionUnit;
				var xc:int = (rWnd.globalX + rWnd.width) / this.m_pixelXPerPositionUnit;
				var yc:int = (rWnd.globalY + rWnd.height) / this.m_pixelYPerPositionUnit;
				
				var yIdx:int = yr;
				var xIdx:int = 0;
				var isYNotInArea:Boolean = false;
				var isXNotInArea:Boolean = false;
				while (yIdx <= yc) 
				{
					isYNotInArea = (yIdx < 0) || (yIdx >= WND_POSITION_MAP_SIZE);
					if(!isYNotInArea)
					{
						xIdx = xr;
						while (xIdx <= xc) 
						{
							isXNotInArea = (xIdx < 0) || (xIdx >= WND_POSITION_MAP_SIZE);
							if(!isXNotInArea)
							{
								this.m_wndPositionMap[yIdx][xIdx].push(rWnd);	
							}
							xIdx++;
						}
					}
					yIdx++;
				}
			}
			
			var wnd:DeltaXWindow = rWnd.visibleChildBottomMost;
			while (wnd) 
			{
				if ((wnd.style & WindowStyle.MODAL) == 0)
				{
					this.buildWndPositionMap(wnd);
				}
				wnd = wnd.visibleBrotherAbove;
			}
		}
		
		/**
		 * 注册功能键命令
		 * @param wnd									gui
		 * @param ctrl										ctrl键是否按下
		 * @param shift									shift键是否按下
		 * @param alt										alt键是否按下
		 * @param kc										keycode
		 * @param context								内容
		 * @param allowRepeat						是否允许重复
		 */		
		public function registerAccelKeyCommand(wnd:DeltaXWindow, ctrl:Boolean, shift:Boolean, alt:Boolean, kc:uint, context:Object, allowRepeat:Boolean=false):void
		{
			if (ctrl)
			{
				kc = kc | ACCEKEY_CTRL;
			}
			
			if (shift)
			{
				kc = kc | ACCEKEY_SHIFT;
			}
			
			if (alt)
			{
				kc = kc | ACCEKEY_ALT;
			}
			
			var ak:AcceKey = (this.m_mapAcceKey[kc] = ((this.m_mapAcceKey[kc]) || (new AcceKey())));
			ak.m_targetWnd = wnd;
			ak.m_context = context;
			ak.m_allowRepeat = allowRepeat;
		}
		
		/**
		 * 移除已注册的功能键命令（通过gui）
		 * @param wnd
		 */		
		public function unRegisterAccelKeyCommandByWnd(wnd:DeltaXWindow):void
		{
			this.m_tempAccelKeysToUnregisterCount = 0;
			
			var key:*;
			for (key in this.m_mapAcceKey) 
			{
				if (this.m_mapAcceKey[key].m_targetWnd == wnd)
				{
					this.m_tempAccelKeysToUnregister[this.m_tempAccelKeysToUnregisterCount++] = key;
				}
			}
			
			var idx:uint = 0;
			while (idx < this.m_tempAccelKeysToUnregisterCount) 
			{
				delete this.m_mapAcceKey[this.m_tempAccelKeysToUnregister[idx]];
				idx++;
			}
		}
		
		/**
		 * 移除已注册的功能键命令
		 * @param ctrl
		 * @param shift
		 * @param alt
		 * @param kc
		 */		
		public function unRegisterAccelKeyCommand(ctrl:Boolean, shift:Boolean, alt:Boolean, kc:uint):void
		{
			if (ctrl)
			{
				kc = kc | ACCEKEY_CTRL;
			}
			
			if (shift)
			{
				kc = kc | ACCEKEY_SHIFT;
			}
			
			if (alt)
			{
				kc = kc | ACCEKEY_ALT;
			}
			
			this.m_mapAcceKey[kc] = null;
			delete this.m_mapAcceKey[kc];
		}
		
		/**
		 * 功能键转换
		 * @param kEvt
		 * @param wnd
		 * @return 
		 */		
		private function translateAccelKey(kEvt:KeyboardEvent, wnd:DeltaXWindow):Boolean
		{
			var kCode:uint = kEvt.keyCode;
			if (kEvt.ctrlKey)
			{
				kCode = kCode | ACCEKEY_CTRL;
			}
			
			if (kEvt.shiftKey)
			{
				kCode = kCode | ACCEKEY_SHIFT;
			}
			
			if (kEvt.altKey)
			{
				kCode = kCode | ACCEKEY_ALT;
			}
			
			var ak:AcceKey = this.m_mapAcceKey[kCode];
			if (ak == null)
			{
				return false;
			}
			
			if (kEvt.type == KeyboardEvent.KEY_DOWN && this.m_keyIsPress && !ak.m_allowRepeat)
			{
				return false;
			}
			
			if (kCode == kEvt.keyCode && (wnd.focusWnd is DeltaXEdit))
			{
				return false;
			}
			
			var tw:DeltaXWindow = ak.m_targetWnd;
			while (tw) 
			{
				if (wnd == tw)
				{
					ak.m_targetWnd.dispatchEvent(new DXWndEvent(DXWndEvent.ACCELKEY, ak.m_context));
					this.m_ignoreNextKeyup = (kEvt.type == KeyboardEvent.KEY_DOWN);
					return true;
				}
				tw = tw.parent;
			}
			
			return false;
		}
		
		/**
		 * 移除已注册的gui
		 * @param wnd
		 */		
		public function unregistWnd(wnd:DeltaXWindow):void
		{
			if (this.m_holdWnd == wnd)
			{
				this.setHeldWindow(null);
			}
			this.unRegisterAccelKeyCommandByWnd(wnd);
		}
		
		/**
		 * 设置鼠标按住的窗口
		 * @param wnd
		 */		
		public function setHeldWindow(wnd:DeltaXWindow):void
		{
			if (wnd && this.m_holdWnd)
			{
				Exception.CreateException("set held window duplicate!!!");
			}
			
			var cp:Point = null;
			if (wnd)
			{
				cp = this.m_cursorPos.clone();
				cp.x -= wnd.globalX;
				cp.y -= wnd.globalY;
				
				if (this.m_holdWnd != wnd)
				{
					this.m_holdWndMoving = false;
				}
				
				this.m_holdingSameWnd = !this.m_holdWnd || this.m_holdWnd == wnd;
				this.m_continuosMouseDownPassTime = 0;
				this.m_holdWnd = wnd;
				this.m_curHeldPos.copyFrom(cp);
				this.m_preHoldTime = getTimer();
			} else 
			{
				if (this.m_holdWnd)
				{
					cp = this.m_cursorPos.clone();
					cp.x -= this.m_holdWnd.globalX;
					cp.y -= this.m_holdWnd.globalY;
					
					if (this.m_holdWndMoving)
					{
						this.m_holdWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DRAGEND, cp, 0, false, false, false, false));
						this.m_holdWndMoving = false;
					}
					
					this.m_holdWnd = null;
					this._resetContinuosMouseDownState();
				}
			}
		}
		
		/**
		 * 设置模块窗口
		 * @param wnd					窗口
		 * @param va						是否可见
		 */		
		public function setModuleWnd(wnd:DeltaXWindow, va:Boolean):void
		{
			var idx:int = this.m_listModuleWnd.indexOf(wnd);
			if (idx >= 0)
			{
				this.m_listModuleWnd.splice(idx, 1);
			}
			
			if (va)
			{
				this.setHeldWindow(null);
				this.m_listModuleWnd.push(wnd);
				this.m_moduleWnd = wnd;
			} else 
			{
				if (this.m_moduleWnd == wnd)
				{
					if (this.m_listModuleWnd.length)
					{
						this.m_moduleWnd = this.m_listModuleWnd[(this.m_listModuleWnd.length - 1)];
					} else 
					{
						this.m_moduleWnd = null;
					}
					this.setHeldWindow(null);
				}
			}
		}
		
		/**
		 * 重设连续按住鼠标的状态
		 */		
		private function _resetContinuosMouseDownState():void
		{
			this.m_holdingSameWnd = false;
			this.m_continuosMouseDownPassTime = 0;
		}
		
		/**
		 * 事件处理
		 * @param evt
		 */		
		public function processEvent(evt:Event):void
		{
			var mEvt:MouseEvent;
			if(evt.type == MouseEvent.RIGHT_MOUSE_DOWN)
			{
				trace("====================",evt.target);
			}
			if (evt is MouseEvent)
			{
				mEvt = MouseEvent(evt);
				if (mEvt.type == MouseEvent.MOUSE_MOVE)
				{
					if (this.m_curMouseEvent != mEvt)
					{
						this.m_curMouseEvent = mEvt;
						this.m_cursorPos.x = this.m_curMouseEvent.localX;
						this.m_cursorPos.y = this.m_curMouseEvent.localY;
						return;
					}
				} else 
				{
					if (this.m_curMouseEvent != null)
					{
						this.processEvent(this.m_curMouseEvent);
						this.m_curMouseEvent = null;
					}
				}
			}
			
			var mWnd:DeltaXWindow = this.m_moduleWnd ? this.m_moduleWnd : this.m_rootWnd;
			
			if (evt is KeyboardEvent)
			{
				var kEvt:KeyboardEvent = KeyboardEvent(evt);
				this.m_keyIsPress = (kEvt.type == KeyboardEvent.KEY_DOWN);
				if (this.m_ignoreNextKeyup && kEvt.type == KeyboardEvent.KEY_UP)
				{
					this.m_ignoreNextKeyup = false;
					return;
				}
				
				var isAcc:Boolean = this.translateAccelKey(kEvt, mWnd);
				if (isAcc)
				{
					return;
				}
			}
			
			var hWnd:DeltaXWindow = this.m_holdWnd;
			if (mEvt && ((mEvt.type == MouseEvent.MOUSE_UP) || (mEvt.type == MouseEvent.MOUSE_MOVE && !mEvt.buttonDown)))
			{
				this.setHeldWindow(null);
			}
			
			this.m_curEvent = evt;
			
			var rWnd:DeltaXWindow = null;
			if (mEvt)
			{
				if (mEvt.type == MouseEvent.MOUSE_DOWN)
				{
					this.m_cursorPos.x = 0;
				}
				
				this.m_cursorPos.x = mEvt.localX;
				this.m_cursorPos.y = mEvt.localY;
				mEvt.localX = this.m_cursorPos.x;
				mEvt.localY = this.m_cursorPos.y;
				
				if (this.m_cursorAttachWnd && this.m_cursorAttachWnd.inUITree)
				{
					this.m_cursorAttachWnd.setGlobal((this.m_cursorPos.x - this.m_attachPos.x), (this.m_cursorPos.y - this.m_attachPos.y));
				}
				
				rWnd = this.m_holdWnd ? this.m_holdWnd : this.detectTopWnd(this.m_cursorPos);
				if (!this.m_holdWnd && hWnd && rWnd != hWnd)
				{
					return;
				}
			}
			
			rWnd = rWnd ? rWnd : this.m_rootWnd.focusWnd;
			
			var lp:Point = null;
			if (mEvt)
			{
				if (this.m_lastMouseOverWnd != rWnd)
				{
					if (this.m_lastMouseOverWnd && this.m_lastMouseOverWnd.parent)
					{
						lp = new Point(mEvt.localX, mEvt.localY);
						lp.x -= this.m_lastMouseOverWnd.globalX;
						lp.y -= this.m_lastMouseOverWnd.globalY;
						this.m_lastMouseOverWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.MOUSE_LEAVE, lp, mEvt.delta, mEvt.ctrlKey, mEvt.shiftKey, mEvt.altKey, mEvt.buttonDown));
					}
					
					if (rWnd)
					{
						lp = new Point(mEvt.localX, mEvt.localY);
						lp.x -= rWnd.globalX;
						lp.y -= rWnd.globalY;
						rWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.MOUSE_ENTER, lp, mEvt.delta, mEvt.ctrlKey, mEvt.shiftKey, mEvt.altKey, mEvt.buttonDown));
					}
					
					this.m_preMouseOverTime = getTimer();
					this.m_lastMouseOverWnd = rWnd;
				}
			}
			
			if (rWnd == null || !rWnd.enable)
			{
				return;
			}
			
			if (mEvt && mEvt.buttonDown)
			{
				rWnd.setFocus();
				this.m_lastMouseOverWnd = null;
				this.m_curTooltipWnd = null;
			}
			
			if (mEvt && mEvt.type == MouseEvent.MOUSE_DOWN && this.m_holdWnd != rWnd)
			{
				this.setHeldWindow(rWnd);
			}
			
			this.dispatchEvent(rWnd, evt);
		}
		
		/**
		 * 事件发送
		 * @param wnd
		 * @param evt
		 */		
		public function dispatchEvent(wnd:DeltaXWindow, evt:Event):void
		{
			if (evt is KeyboardEvent)
			{
				var kEvt:KeyboardEvent = evt as KeyboardEvent;
				if (kEvt.type == KeyboardEvent.KEY_UP)
				{
					wnd.dispatchEvent(new DXWndKeyEvent(DXWndKeyEvent.KEY_UP, kEvt.keyCode, kEvt.ctrlKey, kEvt.shiftKey, kEvt.altKey));
				}
				
				if (kEvt.type == KeyboardEvent.KEY_DOWN)
				{
					wnd.dispatchEvent(new DXWndKeyEvent(DXWndKeyEvent.KEY_DOWN, kEvt.keyCode, kEvt.ctrlKey, kEvt.shiftKey, kEvt.altKey));
				}
				return;
			}
			
			var ct:int = getTimer();
			if ((evt is TextEvent) && ((ct - this.m_preHoldTime) > 200))
			{
				wnd.dispatchEvent(new DXWndEvent(DXWndEvent.TEXT_INPUT, TextEvent(evt).text));
				return;
			}
			
			if (evt is MouseEvent)
			{
				var mEvt:MouseEvent = evt as MouseEvent;
				var lp:Point = new Point(mEvt.localX, mEvt.localY);
				if (wnd.isHeld && mEvt.type == MouseEvent.MOUSE_MOVE && mEvt.buttonDown)
				{
					if (wnd.parent)
					{
						if ((WindowStyle.CHILD & wnd.style) == 0)
						{
							var ox:int = this.m_curHeldPos.x + wnd.globalX;
							var oy:int = this.m_curHeldPos.y + wnd.globalY;
							if (wnd.isInTitleArea(ox, oy))
							{
								lp.x -= ox;
								lp.y -= oy;
								if (!this.m_holdWndMoving)
								{
									this.m_holdWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DRAGSTART, lp, 0, false, false, false, true));
									this.m_holdWndMoving = true;
								}
								
								if (wnd.onWndPreMoved(lp))
								{
									wnd.setGlobal((wnd.globalX + lp.x), (wnd.globalY + lp.y));
								}
							}
						} else 
						{
							lp.x -= wnd.globalX;
							lp.y -= wnd.globalY;
							if (!this.m_holdWndMoving)
							{
								this.m_holdWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DRAGSTART, lp, 0, false, false, false, true));
								this.m_holdWndMoving = true;
							}
							wnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DRAG, lp, mEvt.delta, mEvt.ctrlKey, mEvt.shiftKey, mEvt.altKey, mEvt.buttonDown));
						}
					}
				} else 
				{
					lp.x -= wnd.globalX;
					lp.y -= wnd.globalY;
					if (mEvt.type == MouseEvent.MOUSE_UP)
					{
						if (this.m_lastMouseUpTime && ((ct - this.m_lastMouseUpTime) < 200))
						{
							this.m_lastMouseUpTime = ct;
							wnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.DOUBLE_CLICK, lp, mEvt.delta, mEvt.ctrlKey, mEvt.shiftKey, mEvt.altKey, mEvt.buttonDown));
							return;
						}
						this.m_lastMouseUpTime = ct;
					}
					wnd.dispatchEvent(new DXWndMouseEvent(mEvt.type, lp, mEvt.delta, mEvt.ctrlKey, mEvt.shiftKey, mEvt.altKey, mEvt.buttonDown));
				}
				return;
			}
			
			if (evt.type == Event.RESIZE)
			{
				//this.rootWnd.setSize(Stage(_arg2.target).stageWidth, Stage(_arg2.target).stageHeight);
				this.rootWnd.setSize(BaseApplication.instance.mContainer.width, BaseApplication.instance.mContainer.height);
			}
		}
		
		/**
		 * 设置默认tips
		 * @param url
		 */		
		public function setDefaultTooltipRes(url:String):void
		{
			this.m_commonTooltipsWnd.createFromRes(url, this.m_rootWnd);
		}
		
		/**
		 * 注册自定义tips
		 * @param wnd					要显示tips的窗口
		 * @param tWnd					自定义的tips窗口
		 * @param param					tips参数
		 */		
		public function registerCustomTooltip(wnd:DeltaXWindow, tWnd:DeltaXWindow, param:Object=null):void
		{
			this.m_componentToTooltipUIMap[wnd] = [tWnd, param];
		}
		
		/**
		 * 移除已注册的自定义tips
		 * @param wnd
		 */		
		public function unregisterCustomTooltip(wnd:DeltaXWindow):void
		{
			delete this.m_componentToTooltipUIMap[wnd];
		}
		
		/**
		 * 隐藏tips
		 */		
		public function hideToolTips():void
		{
			var wnds:Array = this.m_componentToTooltipUIMap[this.m_curTooltipWnd];
			if (!wnds)
			{
				this.m_commonTooltipsWnd.hide();
				return;
			}
			
			var wnd:DeltaXWindow = wnds[0];
			if (wnd && (wnd == this.m_curShowingCustomTooltip))
			{
				this.m_curShowingCustomTooltip.visible = false;
				this.m_curShowingCustomTooltip = null;
			}
		}
		
		/**
		 * 显示tips
		 */		
		public function showToolTips():void
		{
			var wnds:Array = this.m_componentToTooltipUIMap[this.m_curTooltipWnd];
			if (!wnds)
			{
				var tStr:String = this.m_curTooltipWnd.tooltipsText;
				if (!tStr)
				{
					return;
				}
				
				this.m_commonTooltipsWnd.setText(tStr);
				this.m_commonTooltipsWnd.show();
				this.calcTooltipPosition(this.m_commonTooltipsWnd, this.m_curTooltipWnd);
				return;
			}
			
			var wnd:DeltaXWindow = wnds[0];
			if (wnd)
			{
				if (this.m_curShowingCustomTooltip && this.m_curShowingCustomTooltip != wnd)
				{
					this.m_curShowingCustomTooltip.visible = false;
				}
				
				this.m_curShowingCustomTooltip = wnd;
				
				var param:Object=null;
				if (wnd is ICustomTooltip)
				{
					param = wnds[1];
					wnd.visible = ICustomTooltip(wnd).prepareContent(this.m_curTooltipWnd, param);
				} else 
				{
					wnd.setText(this.m_curTooltipWnd.tooltipsText);
					wnd.visible = true;
				}
				
				this.calcTooltipPosition(wnd, this.m_curTooltipWnd);
				
				if (wnd is ICustomTooltip)
				{
					ICustomTooltip(wnd).postCalcPosition(this.m_curTooltipWnd, param);
				}
			}
		}
		
		/**
		 * 计算tips的位置
		 * @param tWnd				tips窗口
		 * @param oWnd				鼠标移上去的窗口
		 */		
		private function calcTooltipPosition(tWnd:DeltaXWindow, oWnd:DeltaXWindow):void
		{
			if (!tWnd || !oWnd)
			{
				return;
			}
			
			var followCursor:Boolean = false;
			if (oWnd is DeltaXWindow)
			{
				followCursor = Boolean((DeltaXWindow(oWnd).properties.style & WindowStyle.TOOLTIP_FOLLOW_CURSOR));
			}
			
			var rect:Rectangle = oWnd.globalBounds.clone();
			this.calcTooltipPositionByTargetBound(tWnd, rect, followCursor);
		}
		
		/**
		 * 通过目标对象的范围来计算tips的位置
		 * @param tWnd											tips窗口
		 * @param rect												目标对象的范围
		 * @param followCursor								跟随鼠标
		 */		
		public function calcTooltipPositionByTargetBound(tWnd:DeltaXWindow, rect:Rectangle, followCursor:Boolean=false):void
		{
			if (!tWnd || !rect)
			{
				return;
			}
			
			var rWnd:DeltaXWindow = this.m_rootWnd;
			
			var tRect:Rectangle = MathUtl.TEMP_RECTANGLE2;
			tRect.x = 0;
			tRect.y = 0;
			tRect.width = rWnd.width;
			tRect.height = rWnd.height;
			
			if (followCursor)
			{
				var mx:Number = tWnd.mouseX;
				var my:Number = tWnd.mouseY;
				tWnd.x = mx;
				tWnd.y = my;
				var gWnd:DeltaXWindow = rWnd.getChildByName("GameMainState");
				if (gWnd && ((my + tWnd.height) > (gWnd.y + gWnd.height)))
				{
					tWnd.y = my - tWnd.height;
				}
			} else 
			{
				var tx:Number = rect.x;
				var ty:Number = rect.y;
				var tw:Number = rect.width;
				var th:Number = rect.height;
				var gx:Number = tx;
				var gy:Number = ty - tWnd.height;
				var reverse:Boolean = false;
				if (gy < tRect.x)
				{
					gy = ty + th;
					if ((gy + tWnd.height) > tRect.bottom)
					{
						gy = tRect.bottom - tWnd.height;
						if (gy < tRect.top)
						{
							gy = tRect.top;
						}
						reverse = true;
					}
				}
				
				if (gx > (tRect.left + tRect.width * 0.5))
				{
					gx = tx + tw - tWnd.width;
					if (reverse)
					{
						gx = tx - tWnd.width;
					}
				} else 
				{
					if (reverse)
					{
						gx = tx + tw;
					}
				}
				
				if ((gx + tWnd.width) > tRect.right)
				{
					gx = Math.min((tx + tWnd.width), tRect.right) - tWnd.width;
				}
				
				if (gx < tRect.left)
				{
					gx = Math.max((tx + tw - tWnd.width), tRect.left);
				}
				
				tWnd.globalX = gx;
				tWnd.globalY = gy;
			}
		}
		
		/**
		 * 渲染
		 * @param context3d
		 * @param isDebug
		 */		
		public function render(context3d:Context3D, isDebug:Boolean):void
		{
			if (!context3d)
			{
				return;
			}
			
			if (this.m_curMouseEvent != null)
			{
				this.processEvent(this.m_curMouseEvent);
				this.m_curMouseEvent = null;
			}
			
			var curTime:uint = getTimer();
			var interval:int = this.m_preRenderTime ? curTime - this.m_preRenderTime : 0;
			
			var overWin:DeltaXWindow = this.lastMouseOverWnd;
			
			this.m_preRenderTime = curTime;
			
			if ((overWin && overWin.visible) && ((curTime - this.m_preMouseOverTime) >= overWin.mouseOverDescDelay))
			{
				if (this.m_curTooltipWnd != overWin)
				{
					this.m_curTooltipWnd = overWin;
					this.showToolTips();
				}
			} else 
			{
				if (this.m_curTooltipWnd && this.m_curTooltipWnd != overWin)
				{
					this.hideToolTips();
					this.m_curTooltipWnd = null;
				}
			}
			
			if (this.m_holdingSameWnd && this.m_holdWnd && this.m_holdWnd.enableMouseContinousDownEvent)
			{
				this.m_continuosMouseDownPassTime += interval;
				var cInterval:int = MathUtl.max(1, this.m_holdWnd.mouseContinousDownInterval);
				while (int(this.m_continuosMouseDownPassTime) >= cInterval) 
				{
					this.m_continuosMouseDownPassTime -= cInterval;
					this.m_holdWnd.dispatchEvent(new DXWndMouseEvent(DXWndMouseEvent.MOUSE_CONTINUOUS_DOWN, this.cursorPos, 0, false, false, false, true));
				}
			}
			
			this.draw(context3d, this.m_rootWnd, curTime, interval);
			
			var wnd:DeltaXWindow=null;
			var canNotDraw:Boolean = false;
			for each (wnd in this.m_listModuleWnd) 
			{
				canNotDraw = !wnd.parent || (!wnd.visible && !wnd.fading);
				if(!canNotDraw)
				{
					this.draw(context3d, wnd, curTime, interval);
				}
			}
			
			if (isDebug)
			{
				var fWnd:DeltaXWindow = this.rootWnd.focusWnd;
				var lastWnd:DeltaXWindow = overWin ? overWin : fWnd;
				if (fWnd == lastWnd)
				{
					this.drawRectWireFrame(context3d, fWnd.globalBounds, 4294902015);
				} else 
				{
					this.drawRectWireFrame(context3d, fWnd.globalBounds, 4294901760);
					this.drawRectWireFrame(context3d, lastWnd.globalBounds, 4278190335);
				}
			}
			
			DeltaXRectRenderer.Instance.flushAll(context3d);
			DeltaXFontRenderer.Instance.endFontRender(context3d);
		}
		
		/**
		 * 画矩形线框
		 * @param context3d
		 * @param rect
		 * @param color
		 */		
		private function drawRectWireFrame(context3d:Context3D, rect:Rectangle, color:uint):void
		{
			var rectRender:DeltaXRectRenderer = DeltaXRectRenderer.Instance;
			rectRender.renderRect(context3d, 0, 0, new Rectangle(rect.left, rect.top, rect.width, 1), color);
			rectRender.renderRect(context3d, 0, 0, new Rectangle((rect.right - 1), rect.top, 1, rect.height), color);
			rectRender.renderRect(context3d, 0, 0, new Rectangle(rect.left, (rect.bottom - 1), rect.width, 1), color);
			rectRender.renderRect(context3d, 0, 0, new Rectangle(rect.left, rect.top, 1, rect.height), color);
		}
		
		/**
		 * 绘制
		 * @param context3d			上下文内容
		 * @param wnd					gui
		 * @param ct						当前时间
		 * @param it							渲染间隔
		 */		
		public function draw(context3d:Context3D, wnd:DeltaXWindow, ct:uint, it:int):void
		{
			
			if (wnd != this.m_rootWnd)
			{
				wnd.render(context3d, ct, it);
			}
			
			var tw:DeltaXWindow = null;
			var isModal:Boolean = false;
			var canNotDraw:Boolean = false;
			if (wnd.fadingChildCount > 0)
			{
				tw = wnd.childBottomMost;
				while (tw) 
				{
					isModal = Boolean(tw.style & WindowStyle.MODAL);
					if (!isModal)
					{
						canNotDraw = !tw.visible && !tw.fading;
						if(!canNotDraw)
						{
							this.draw(context3d, tw, ct, it);
						}
					} 
					tw = tw.brotherAbove;
				}
			} else 
			{
				tw = wnd.visibleChildBottomMost;
				while (tw) 
				{
					isModal = Boolean(tw.style & WindowStyle.MODAL);
					if(!isModal)
					{
						this.draw(context3d, tw, ct, it);
					}
					tw = tw.visibleBrotherAbove;
				}
			}
		}
		
		
	}
} 

import deltax.gui.component.DeltaXFrame;
import deltax.gui.component.DeltaXWindow;

class AcceKey 
{
	public var m_targetWnd:DeltaXWindow;
	public var m_context:Object;
	public var m_allowRepeat:Boolean;
	
	public function AcceKey()
	{
		//
	}
}

class DeltaXRootWnd extends DeltaXFrame 
{
	public function DeltaXRootWnd()
	{
		super(null, null);
		m_visible = true;
	}
}