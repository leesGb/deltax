package deltax.appframe.event {
    import flash.events.*;
    import deltax.appframe.*;
    import deltax.common.debug.*;

    public class ShellLogicObjectEvent extends Event {

        public static const SYNC_DATA_UPDATED:String = "sync_data_updated";

        public var object:ShellLogicObject;
        public var syncListIndex:int = -1;
        public var syncBlockIndexInList:int = -1;

        public function ShellLogicObjectEvent(_arg1:ShellLogicObject, _arg2:String, _arg3:int=-1, _arg4:int=-1, _arg5:Boolean=false, _arg6:Boolean=false){
            ObjectCounter.add(this);
            super(_arg2, _arg5, _arg6);
            this.object = _arg1;
            this.syncListIndex = _arg3;
            this.syncBlockIndexInList = _arg4;
        }
    }
}
