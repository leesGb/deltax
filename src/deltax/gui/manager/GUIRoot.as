package deltax.gui.manager 
{
	import deltax.appframe.BaseApplication;
	import deltax.common.error.Exception;
	import deltax.gui.component.event.DXWndMouseEvent;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	public class GUIRoot extends Sprite implements IGUIHandler 
	{
		/***/
		private var m_textInput:TextField;
		/***/
		private var m_forceFocusSelf:Boolean = true;
		/***/
		private var m_container:Sprite;
		
		public function GUIRoot()
		{
			this.m_textInput = new TextField();
			this.m_textInput.alpha = 0;
			this.m_textInput.type = TextFieldType.INPUT;
			this.m_textInput.doubleClickEnabled = true;
			
			this.alpha = 0;
			this.doubleClickEnabled = true;
		}
		
		/**
		 * 初始化
		 * @param $stage
		 */		
		public function init($container:Sprite):void
		{
			m_container = $container;
			m_container.stage.align = StageAlign.TOP_LEFT;
			m_container.stage.scaleMode = StageScaleMode.NO_SCALE;
			m_container.stage.stageFocusRect = false;
			
			
			this.m_textInput.autoSize = TextFieldAutoSize.NONE;
			this.m_textInput.width = m_container.width;
			this.m_textInput.height = m_container.height;
			
			m_container.addEventListener(Event.RESIZE, this.processEvent);
			m_container.addEventListener(TextEvent.TEXT_INPUT, this.processEvent);
			m_container.addEventListener(DXWndMouseEvent.DOUBLE_CLICK, this.processEvent);
			m_container.addEventListener(DXWndMouseEvent.MOUSE_DOWN, this.processEvent);
			m_container.addEventListener(DXWndMouseEvent.MOUSE_UP, this.processEvent);
			m_container.addEventListener(DXWndMouseEvent.MIDDLE_MOUSE_DOWN, this.processEvent);
			m_container.addEventListener(DXWndMouseEvent.MIDDLE_MOUSE_UP, this.processEvent);
			m_container.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.processEvent);
			m_container.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.processEvent);
			m_container.addEventListener(DXWndMouseEvent.MOUSE_MOVE, this.processEvent);
			m_container.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.processEvent);
			m_container.addEventListener(KeyboardEvent.KEY_DOWN, this.processEvent);
			m_container.addEventListener(KeyboardEvent.KEY_UP, this.processEvent);
			m_container.addEventListener(Event.SELECT_ALL, this.processEvent);
			m_container.addEventListener(Event.COPY, this.processEvent);
			m_container.addEventListener(Event.PASTE, this.processEvent);
			m_container.addEventListener(Event.CUT, this.processEvent);
			m_container.stage.focus = this;
			
			addEventListener(FocusEvent.FOCUS_OUT, this.focusOutHandler);
			new GUIManager(this);
			GUIManager.instance.init(m_container.width,m_container.height);
		}
		
		/**
		 * 事件移除
		 */		
		public function deInit():void
		{
			m_container.removeEventListener(Event.RESIZE, this.processEvent);
			m_container.removeEventListener(TextEvent.TEXT_INPUT, this.processEvent);
			m_container.removeEventListener(DXWndMouseEvent.DOUBLE_CLICK, this.processEvent);
			m_container.removeEventListener(DXWndMouseEvent.MOUSE_DOWN, this.processEvent);
			m_container.removeEventListener(DXWndMouseEvent.MOUSE_UP, this.processEvent);
			m_container.removeEventListener(DXWndMouseEvent.MIDDLE_MOUSE_DOWN, this.processEvent);
			m_container.removeEventListener(DXWndMouseEvent.MIDDLE_MOUSE_UP, this.processEvent);
			m_container.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, this.processEvent);
			m_container.removeEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, this.processEvent);
			m_container.removeEventListener(DXWndMouseEvent.MOUSE_MOVE, this.processEvent);
			m_container.removeEventListener(DXWndMouseEvent.MOUSE_WHEEL, this.processEvent);
			m_container.removeEventListener(KeyboardEvent.KEY_DOWN, this.processEvent);
			m_container.removeEventListener(KeyboardEvent.KEY_UP, this.processEvent);
			m_container.removeEventListener(Event.SELECT_ALL, this.processEvent);
			m_container.removeEventListener(Event.COPY, this.processEvent);
			m_container.removeEventListener(Event.PASTE, this.processEvent);
			m_container.removeEventListener(Event.CUT, this.processEvent);
			m_container.removeChild(this.m_textInput);
		}
		
		/**
		 * 事件处理
		 * @param evt
		 */		
		private function processEvent(evt:Event):void
		{
			var orgCode:uint = 0;
			var keyEvent:KeyboardEvent = null;
			var keyCode:uint = 0;
			var charCode:uint = 0;
			if (evt.type == Event.RESIZE)
			{
				this.m_textInput.width = m_container.width;
				this.m_textInput.height = m_container.height;
			} else 
			{
				if (evt.type == TextEvent.TEXT_INPUT)
				{
					orgCode = TextEvent(evt).text.charCodeAt(0);
					if (orgCode < 32)
					{
						if (orgCode <= 26)
						{
							keyCode = Keyboard.A + orgCode - 1;
							charCode = "A".charCodeAt(0) + orgCode - 1;
						} else
						{
							keyCode = Keyboard.LEFTBRACKET + orgCode - 27;
							charCode = 91 + orgCode - 27;
						}
					}
				} else 
				{
					if (evt.type == Event.SELECT_ALL || evt.type == Event.COPY || evt.type == Event.PASTE || evt.type == Event.CUT)
					{
						keyCode = Keyboard.A;
						if (evt.type == Event.COPY)
						{
							keyCode = Keyboard.C;
						} else
						{
							if (evt.type == Event.PASTE)
							{
								keyCode = Keyboard.V;
							} else 
							{
								if (evt.type == Event.CUT)
								{
									keyCode = Keyboard.X;
								}
							}
						}
						charCode = "A".charCodeAt(0) + keyCode - Keyboard.A;
					} else 
					{
						if (evt is KeyboardEvent)
						{
							keyEvent = evt as KeyboardEvent;
							if (keyEvent.ctrlKey)
							{
								if (keyEvent.keyCode == Keyboard.A || keyEvent.keyCode == Keyboard.C || keyEvent.keyCode == Keyboard.V || keyEvent.keyCode == Keyboard.X)
								{
									return;
								}
							}
						}
					}
				}
			}
			
			var guiManager:GUIManager = GUIManager.instance;
			if (keyCode && charCode)
			{
				guiManager.processEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, charCode, keyCode, 0, true, false, false));
				evt = new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, charCode, keyCode, 0, true, false, false);
			}
			
			guiManager.processEvent(evt);
			
			this.m_textInput.text = "";
			this.m_textInput.selectable = guiManager.curWndSelectable;
			if (guiManager.curWndEditable && this.m_textInput.parent != m_container)
			{
				m_container.addChild(this.m_textInput);
			} else 
			{
				if (!guiManager.curWndEditable && this.m_textInput.parent == m_container)
				{
					m_container.removeChild(this.m_textInput);
				}
			}
		}
		
		private function focusOutHandler(evt:FocusEvent):void
		{
			if (this.m_forceFocusSelf)
			{
				//stage.focus = this;
			}
		}
		
		public function doSetCursor(va:String):Boolean
		{
			Mouse.cursor = va;
			return true;
		}
		
		public function enableForceSelfFocus(va:Boolean):void
		{
			this.m_forceFocusSelf = va;
			if (va)
			{
				stage.focus = this;
			}
		}
		
		
		
	}
}