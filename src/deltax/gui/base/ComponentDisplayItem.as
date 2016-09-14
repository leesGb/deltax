//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.base {
    import __AS3__.vec.*;
    
    import deltax.common.*;
    import deltax.common.error.*;
    import deltax.gui.component.subctrl.*;
    
    import flash.geom.*;
    import flash.utils.*;

    public class ComponentDisplayItem implements ReferencedObject {

        private var m_refCount:uint = 1;
        public var rect:Rectangle;
        public var displayStateInfos:Vector.<ComponentDisplayStateInfo>;

        public function ComponentDisplayItem(){
            this.displayStateInfos = new Vector.<ComponentDisplayStateInfo>(SubCtrlStateType.COUNT, true);
            this.displayStateInfos[SubCtrlStateType.ENABLE] = new ComponentDisplayStateInfo();
            this.displayStateInfos[SubCtrlStateType.DISABLE] = new ComponentDisplayStateInfo();
        }
        public function get refCount():uint{
            return (this.m_refCount);
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function release():void{
            if (--this.m_refCount > 0){
                return;
            };
            if (this.m_refCount < 0){
                (Exception.CreateException(("ComponentDisplayItem:after release refCount == " + this.m_refCount)));
				return;
            };
            this.dispose();
        }
        public function load(_arg1:ByteArray, _arg2:int):void{
            var _local4:ComponentDisplayStateInfo;
            var _local5:uint;
            var _local6:uint;
            var _local8:int;
            var _local9:int;
            var _local10:int;
            var _local11:int;
            if (_arg2 != CommonWndSubCtrlType.BACKGROUND){
                _local8 = _arg1.readInt();
                _local9 = _arg1.readInt();
                _local10 = _arg1.readInt();
                _local11 = _arg1.readInt();
                this.rect = new Rectangle(_local8, _local9, _local10, _local11);
            };
            var _local3:uint = _arg1.readUnsignedInt();
            var _local7:uint;
            while (_local7 < _local3) {
                _local4 = new ComponentDisplayStateInfo();
                _local5 = _arg1.readUnsignedShort();
                _local6 = _arg1.readUnsignedShort();
                _local4.load(_arg1);
                this.displayStateInfos[_local6] = _local4;
                _local7++;
            };
        }
        public function clone():ComponentDisplayItem{
            var _local1:ComponentDisplayItem = new ComponentDisplayItem();
            if (this.rect){
                _local1.rect = this.rect.clone();
            };
            _local1.displayStateInfos = new Vector.<ComponentDisplayStateInfo>(this.displayStateInfos.length);
            var _local2:uint;
            while (_local2 < this.displayStateInfos.length) {
                if (this.displayStateInfos[_local2]){
                    _local1.displayStateInfos[_local2] = this.displayStateInfos[_local2].clone();
                };
                _local2++;
            };
            return (_local1);
        }
        public function dispose():void{
            var _local1:uint;
            while (((this.displayStateInfos) && ((_local1 < this.displayStateInfos.length)))) {
                if (this.displayStateInfos[_local1]){
                    this.displayStateInfos[_local1].dispose();
                };
                this.displayStateInfos[_local1] = null;
                _local1++;
            };
            this.displayStateInfos = null;
        }
		
		public function write(data:ByteArray,type:int):void{
			if (type != CommonWndSubCtrlType.BACKGROUND){
				data.writeInt(this.rect.x);
				data.writeInt(this.rect.y);
				data.writeInt(this.rect.width);
				data.writeInt(this.rect.height);				
			}
			var i:int = 0;
			for (var idx:String in displayStateInfos) {
				if(displayStateInfos[idx])
					i++;
			}
			data.writeUnsignedInt(i);
			i = 0;
			for (var idx:String in displayStateInfos) {
				if(displayStateInfos[idx]){
					data.writeShort(0);
					data.writeShort(int(idx));
					displayStateInfos[idx].write(data);
				}
				i++;
			}			
		}
    }
}//package deltax.gui.base 
