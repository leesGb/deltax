//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.respackage.res {
    import flash.display.*;
    import flash.net.*;
    import deltax.common.resource.*;
    import deltax.common.respackage.common.*;

    public class ResURLLoaderObject extends ResObject {

        override public function Load(_arg1:Loader, _arg2:URLLoader, _arg3:URLRequest):void{
            m_dataLoadState = LoaderCommon.LOADSTATE_LOADING;
            _arg3.url = FileRevisionManager.instance.getVersionedURL(this.m_resUrl);
            _arg3.url = encodeURI(_arg3.url);
            if (((this.m_param) && (this.m_param.hasOwnProperty("dataFormat")))){
                _arg2.dataFormat = this.m_param["dataFormat"];
            };
            _arg2.load(_arg3);
        }
        override protected function applyComplete():void{
            var _local1:Function = this.m_callBackFunObject["onComplete"];
            if (_local1 != null){
                this.m_param = ((this.m_param) || ({}));
                if (this.m_param.hasOwnProperty("data")){
                    throw (new Error(LoaderCommon.ERROR_DATA));
                };
                this.m_param["data"] = m_loadedData;
                _local1.apply(null, [m_param]);
            };
            this.dispose();
        }

    }
}//package deltax.common.respackage.res 
