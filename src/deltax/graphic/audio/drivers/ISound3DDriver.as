//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.audio.drivers {
    import flash.media.*;

    public interface ISound3DDriver {

        function get sourceSound():Sound;
        function set sourceSound(_arg1:Sound):void;
        function get scale():Number;
        function set scale(_arg1:Number):void;
        function get volume():Number;
        function set volume(_arg1:Number):void;
        function get mute():Boolean;
        function set mute(_arg1:Boolean):void;
        function update():void;
        function play():void;
        function pause():void;
        function stop():void;

    }
}//package deltax.graphic.audio.drivers 
