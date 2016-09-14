//Created by Action Script Viewer - http://www.buraks.com/asv
package com.stimuli.string {

    public function printf(_arg1:String, ... _args):String{
        var _local6:Match;
        var _local11:*;
        var _local12:String;
        var _local13:String;
        var _local14:String;
        var _local15:String;
        var _local16:int;
        var _local17:String;
        var _local19:Match;
        var _local21:String;
        var _local22:Number;
        var _local3:RegExp = /%(?!^%)(\((?P<var_name>[\w]+[\w_\d]+)\))?(?P<padding>[0-9]{1,2})?(\.(?P<precision>[0-9]+))?(?P<formater>[sxofaAbBcdHIjmMpSUwWxXyYZ])/ig;
        if (_arg1 == null){
            return ("");
        };
        var _local4:Array = [];
        var _local5:Object = _local3.exec(_arg1);
        var _local7:int;
        var _local8:int;
        var _local9:int = _args.length;
        var _local10:Boolean = !(Boolean(_arg1.match(/%\(\s*[\w\d_]+\s*\)/)));
        while (Boolean(_local5)) {
            _local6 = new Match();
            _local6.startIndex = _local5.index;
            _local6.length = String(_local5[0]).length;
            _local6.endIndex = (_local6.startIndex + _local6.length);
            _local6.content = String(_local5[0]);
            _local12 = _local5.formater;
            _local13 = _local5.var_name;
            _local14 = _local5.precision;
            _local15 = _local5.padding;
            if (_local15){
                if (_local15.length == 1){
                    _local16 = int(_local15);
                    _local17 = " ";
                } else {
                    _local16 = int(_local15.substr(-1, 1));
                    _local17 = _local15.substr(-2, 1);
                    if (_local17 != "0"){
                        _local16 = (_local16 * int(_local17));
                        _local17 = " ";
                    };
                };
            };
            if (_local10){
                _local11 = _args[_local4.length];
            } else {
                _local11 = ((_args[0] == null)) ? undefined : _args[0][_local13];
            };
            if (_local11 == undefined){
                _local11 = "";
            };
            if (_local11 != undefined){
                if (_local12 == STRING_FORMATTER){
                    _local6.replacement = padString(_local11.toString(), _local16, _local17);
                } else {
                    if (_local12 == FLOAT_FORMATER){
                        if (_local14){
                            _local6.replacement = padString(Number(_local11).toFixed(int(_local14)), _local16, _local17);
                        } else {
                            _local6.replacement = padString(_local11.toString(), _local16, _local17);
                        };
                    } else {
                        if (_local12 == INTEGER_FORMATER){
                            _local6.replacement = padString(int(_local11).toString(), _local16, _local17);
                        } else {
                            if (_local12 == OCTAL_FORMATER){
                                _local6.replacement = ("0" + int(_local11).toString(8));
                            } else {
                                if (_local12 == HEXA_FORMATER){
                                    _local6.replacement = ("0x" + int(_local11).toString(16));
                                } else {
                                    if (DATES_FORMATERS.indexOf(_local12) > -1){
                                        switch (_local12){
                                            case DATE_DAY_FORMATTER:
                                                _local6.replacement = _local11.date;
                                                break;
                                            case DATE_FULLYEAR_FORMATTER:
                                                _local6.replacement = _local11.fullYear;
                                                break;
                                            case DATE_YEAR_FORMATTER:
                                                _local6.replacement = _local11.fullYear.toString().substr(2, 2);
                                                break;
                                            case DATE_MONTH_FORMATTER:
                                                _local6.replacement = (_local11.month + 1);
                                                break;
                                            case DATE_HOUR24_FORMATTER:
                                                _local6.replacement = _local11.hours;
                                                break;
                                            case DATE_HOUR_FORMATTER:
                                                _local22 = _local11.hours;
                                                _local6.replacement = (_local22 - 12).toString();
                                                break;
                                            case DATE_HOUR_AMPM_FORMATTER:
                                                _local6.replacement = ((_local11.hours >= 12)) ? "p.m" : "a.m";
                                                break;
                                            case DATE_TOLOCALE_FORMATTER:
                                                _local6.replacement = _local11.toLocaleString();
                                                break;
                                            case DATE_MINUTES_FORMATTER:
                                                _local6.replacement = _local11.minutes;
                                                break;
                                            case DATE_SECONDS_FORMATTER:
                                                _local6.replacement = _local11.seconds;
                                                break;
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
                _local4.push(_local6);
            };
            _local7++;
            if (_local7 > 10000){
                break;
            };
            _local8++;
            _local5 = _local3.exec(_arg1);
        };
        if (_local4.length == 0){
            return (_arg1);
        };
        var _local18:Array = [];
        var _local20:String = _arg1.substr(0, _local4[0].startIndex);
        for each (_local6 in _local4) {
            if (_local19){
                _local20 = _arg1.substring(_local19.endIndex, _local6.startIndex);
            };
            _local18.push(_local20);
            _local18.push(_local6.replacement);
            _local19 = _local6;
        };
        _local18.push(_arg1.substr(_local6.endIndex, (_arg1.length - _local6.endIndex)));
        return (_local18.join(""));
    }
}//package com.stimuli.string 

const BAD_VARIABLE_NUMBER:String = "The number of variables to be replaced and template holes don't match";
const STRING_FORMATTER:String = "s";
const FLOAT_FORMATER:String = "f";
const INTEGER_FORMATER:String = "d";
const OCTAL_FORMATER:String = "o";
const HEXA_FORMATER:String = "x";
const DATES_FORMATERS:String = "aAbBcDHIjmMpSUwWxXyYZ";
const DATE_DAY_FORMATTER:String = "D";
const DATE_FULLYEAR_FORMATTER:String = "Y";
const DATE_YEAR_FORMATTER:String = "y";
const DATE_MONTH_FORMATTER:String = "m";
const DATE_HOUR24_FORMATTER:String = "H";
const DATE_HOUR_FORMATTER:String = "I";
const DATE_HOUR_AMPM_FORMATTER:String = "p";
const DATE_MINUTES_FORMATTER:String = "M";
const DATE_SECONDS_FORMATTER:String = "S";
const DATE_TOLOCALE_FORMATTER:String = "c";
var version:String = "$Id$";
class Match {

    public var startIndex:int;
    public var endIndex:int;
    public var length:int;
    public var content:String;
    public var replacement:String;
    public var before:String;

    public function Match(){
    }
    public function toString():String{
        return ((((((((((("Match [" + this.startIndex) + " - ") + this.endIndex) + "] (") + this.length) + ") ") + this.content) + ", replacement:") + this.replacement) + ";"));
    }

}
const padString:Function = function (_arg1:String, _arg2:int, _arg3:String=" "):String{
        var _local4:int;
        if (_arg3 == null){
            return (_arg1);
        };
        var _local5:Array = [];
        _local4 = 0;
        while (_local4 < (Math.abs(_arg2) - _arg1.length)) {
            _local5.push(_arg3);
            _local4++;
        };
        if (_arg2 < 0){
            _local5.unshift(_arg1);
        } else {
            _local5.push(_arg1);
        };
        return (_local5.join(""));
    };
