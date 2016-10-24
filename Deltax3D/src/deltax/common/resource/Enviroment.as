package deltax.common.resource 
{
    import deltax.common.*;
    import deltax.common.localize.*;

    public final class Enviroment 
	{
		public static var RootPath:String = "";
        public static var ResourceRootPath:String = "";
        public static var ConfigRootPath:String = "";
		public static var CGUIFlaPath:String = "";
        public static var PackedDataRootPath:String = "";
        public static var LanguageRelativeDir:String = "";
        public static var CurLanguage:String = "CN";
        public static var LoadFromPackageFirst:Boolean = false;

        public static function convertURLForQueryPackage(_arg1:String):String{
            var _local2:String = Util.makeGammaString(_arg1).replace(Enviroment.ResourceRootPath, "");
            return (_local2.replace(Enviroment.ConfigRootPath, ""));
        }
        public static function getPathRelativeToRoot(_arg1:String):String{
            return (_arg1.replace((ResourceRootPath + "/"), ""));
        }
        public static function convertToLocalizedUrl(_arg1:String):String{
            var _local2:String;
            var _local3:String;
            var _local4:int;
            var _local5:int;
            if (CurLanguage != Language.CN){
                _local2 = convertURLForQueryPackage(_arg1);
                _local3 = LocalizedFileMap.getFileLanguageDir(_local2);
                if (_local3 == CurLanguage){
                    _local4 = _arg1.indexOf(ResourceRootPath);
                    if (_local4 >= 0){
                        return (((ResourceRootPath + LanguageRelativeDir) + _arg1.substr((_local4 + ResourceRootPath.length))));
                    };
                    _local5 = _arg1.indexOf(ConfigRootPath);
                    if (_local5 >= 0){
                        return (((ConfigRootPath + LanguageRelativeDir) + _arg1.substr((_local5 + ConfigRootPath.length))));
                    };
                };
            };
            return (_arg1);
        }

    }
}