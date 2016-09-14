//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.StartUpParams {

    public class StartUpParams {

        public static var m_params:Object;

        public static function getParam(_arg1:String):String{
            if (m_params == null){
                return (null);
            };
            if (!m_params.hasOwnProperty(_arg1)){
                return (null);
            };
            if (!m_params[_arg1]){
                return (null);
            };
            return (m_params[_arg1].toString());
        }
        public static function get developVersion():Boolean{
            return true//((((m_params == null)) || ((m_params["develop"] == 1))));
        }

    }
}//package deltax.common.StartUpParams 
