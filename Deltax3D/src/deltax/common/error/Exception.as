package deltax.common.error 
{
    import com.stimuli.string.printf;
    
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.net.sendToURL;
    import flash.system.Capabilities;
    
    import deltax.common.StartUpParams.StartUpParams;

    public class Exception 
	{

        private static var m_throwError:Boolean = Capabilities.isDebugger;

        public static function CreateException(_arg1:String):void
		{
            trace("Exception: ", _arg1);
        }
		
        public static function get throwError():Boolean
		{
            return (((m_throwError) || (Capabilities.isDebugger)));
        }
        public static function set throwError(_arg1:Boolean):void
		{
            m_throwError = _arg1;
        }
		
        public static function sendCrashLog(_arg1:Error):void
		{
            var serverName:* = null;
            var accountName:* = null;
            var charName:* = null;
            var date:* = null;
            var dateStr:* = null;
            var errorStr:* = null;
            var variables:* = null;
            var urlRequest:* = null;
            var e:* = _arg1;
            try {
                serverName = ((StartUpParams.getParam("server_name")) || ("null"));
                accountName = ((StartUpParams.getParam("account")) || ("null"));
                charName = ((StartUpParams.getParam("charName")) || ("null"));
                dateStr = printf("%04d-%02d-%02d %02d:%02d:%02d", date.fullYear, (date.month + 1), date.date, date.hours, date.minutes, date.seconds);
                errorStr = e.message;
                if (Capabilities.isDebugger)
				{
                    errorStr = (errorStr + ("\n" + e.getStackTrace()));
                }
                variables = new URLVariables();
                variables.decode(((((((((("server=" + serverName) + "&account=") + accountName) + "&charname=") + charName) + "&date=") + dateStr) + "&error=") + errorStr));
                urlRequest = new URLRequest("http://item.kunlun.com/fscrash/d.html");
                urlRequest.method = URLRequestMethod.GET;
                urlRequest.data = variables;
                sendToURL(urlRequest);
            } catch(error:Error) 
			{
                trace("...sendCrashLog failed", error.message);
            }
        }

    }
}