package deltax.common.respackage.res 
{
    import flash.display.Loader;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    import deltax.common.resource.FileRevisionManager;
    import deltax.common.respackage.common.LoaderCommon;

    public class ResURLLoaderObject extends ResObject 
	{

		public function ResURLLoaderObject()
		{
			//
		}
		
        override public function Load(loader:Loader, urlloader:URLLoader, req:URLRequest):void
		{
			trace("load===============",this.m_resUrl);
            m_dataLoadState = LoaderCommon.LOADSTATE_LOADING;
			req.url = FileRevisionManager.instance.getVersionedURL(this.m_resUrl);
			req.url = encodeURI(req.url);
            if (this.m_param && this.m_param.hasOwnProperty("dataFormat"))
			{
				urlloader.dataFormat = this.m_param["dataFormat"];
            }
			urlloader.load(req);
        }
		
        override protected function applyComplete():void
		{
            var f:Function = this.m_callBackFunObject["onComplete"];
            if (f != null)
			{
                this.m_param = ((this.m_param) || ({}));
                if (this.m_param.hasOwnProperty("data"))
				{
                    throw new Error(LoaderCommon.ERROR_DATA);
                }
				
                this.m_param["data"] = m_loadedData;
                f.apply(null, [m_param]);
            }
			
            this.dispose();
        }

    }
} 
