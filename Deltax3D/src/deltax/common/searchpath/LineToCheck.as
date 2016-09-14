//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.searchpath {

    public class LineToCheck {

        public function check(_arg1:int, _arg2:int):Boolean{
            return (true);
        }
        public function LineTo(_arg1:int, _arg2:int, _arg3:int, _arg4:int):Boolean{
            var _local5:int = Math.abs((_arg3 - _arg1));
            var _local6:int = Math.abs((_arg4 - _arg2));
            var _local7 = (_local5 << 1);
            var _local8 = (_local6 << 1);
            var _local9:int = ((_arg3 < _arg1)) ? -1 : 1;
            var _local10:int = ((_arg4 < _arg2)) ? -1 : 1;
            if (!this.check(_arg1, _arg2)){
                return (false);
            };
            var _local11:int;
            var _local12:int = _arg1;
            var _local13:int = _arg2;
            if (_local6 > _local5){
                while (_local13 != _arg4) {
                    if ((_local11 - _local7) < -(_local6)){
                        _local12 = (_local12 + _local9);
                        _local11 = (_local11 + _local8);
                    };
                    _local13 = (_local13 + _local10);
                    _local11 = (_local11 - _local7);
                    if (!this.check(_local12, _local13)){
                        return (false);
                    };
                };
            } else {
                if (_local6 < _local5){
                    while (_local12 != _arg3) {
                        if ((_local11 - _local8) < -(_local5)){
                            _local13 = (_local13 + _local10);
                            _local11 = (_local11 + _local7);
                        };
                        _local12 = (_local12 + _local9);
                        _local11 = (_local11 - _local8);
                        if (!this.check(_local12, _local13)){
                            return (false);
                        };
                    };
                } else {
                    while (_local12 != _arg3) {
                        _local13 = (_local13 + _local10);
                        _local12 = (_local12 + _local9);
                        if (!this.check(_local12, _local13)){
                            return (false);
                        };
                    };
                };
            };
            return (true);
        }

    }
}//package deltax.common.searchpath 
