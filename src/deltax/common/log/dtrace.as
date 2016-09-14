//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common.log {

    public function dtrace(_arg1:uint, ... _args):void{
        if (!LogManager.instance.enable){
            trace.apply(null, _args);
            return;
        };
        _args.unshift(_arg1);
        LogManager.instance.log.apply(null, _args);
    }
}//package deltax.common.log 
