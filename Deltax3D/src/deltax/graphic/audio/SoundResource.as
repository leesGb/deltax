//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.audio {
    import deltax.common.debug.*;
    import deltax.graphic.manager.*;
    import flash.utils.*;
    import flash.net.*;
    import flash.media.*;
    import deltax.common.error.*;

    public class SoundResource extends Sound implements IResource {

        private var m_name:String;
        private var m_loaded:Boolean = false;
        private var m_loadfailed:Boolean = false;
        private var m_refCount:int = 1;

        public function SoundResource(_arg1:String=null){
            ObjectCounter.add(this);
            this.name = (_arg1) ? _arg1 : "";
        }
        public function get name():String{
            return (this.m_name);
        }
        public function set name(_arg1:String):void{
            this.m_name = _arg1;
        }
        public function dispose():void{
            this.m_loaded = false;
        }
        public function get loaded():Boolean{
            return (this.m_loaded);
        }
        public function get loadfailed():Boolean{
            return (this.m_loadfailed);
        }
        public function set loadfailed(_arg1:Boolean):void{
            this.m_loadfailed = _arg1;
        }
        public function get dataFormat():String{
            return (URLLoaderDataFormat.BINARY);
        }
        public function parse(_arg1:ByteArray):int{
            var dataBytes:* = _arg1;
            if (this.m_refCount <= 0){
                return (-1);
            };
            this.m_loaded = true;
            try {
                loadCompressedDataFromByteArray(dataBytes, dataBytes.length);
            } catch(e:Error) {
                m_loaded = false;
                return (-1);
            };
            return (1);
        }
        public function onDependencyRetrieve(_arg1:IResource, _arg2:Boolean):void{
        }
        public function onAllDependencyRetrieved():void{
        }
        public function get type():String{
            return (ResourceType.SOUND);
        }
        public function get refCount():uint{
            return (this.m_refCount);
        }
        public function release():void{
            if (--this.m_refCount > 0){
                return;
            };
            if (this.m_refCount < 0){
                (Exception.CreateException(((this.name + ":after release refCount == ") + this.m_refCount)));
				return;
            };
            ResourceManager.instance.releaseResource(this, ResourceManager.DESTROY_NEVER);
        }
        public function reference():void{
            this.m_refCount++;
        }

    }
}//package deltax.graphic.audio 
