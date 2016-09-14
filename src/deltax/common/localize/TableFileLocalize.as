//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.localize {
    import deltax.common.*;

    public class TableFileLocalize extends TableFile {

        override public function getString(_arg1:uint, _arg2:uint, _arg3:String="", _arg4:Boolean=false):String{
            var _local5:String = super.getString(_arg1, _arg2, _arg3, _arg4);
            if (_local5.charAt(0) == "號"){
                return (StringDictionary.instance.getStringNameByID(_local5));
            };
            return (_local5);
        }

    }
}//package deltax.common.localize 
