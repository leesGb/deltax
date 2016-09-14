//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render {
    import deltax.graphic.camera.*;
    import deltax.graphic.scenegraph.object.*;
    import flash.utils.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.scenegraph.traverse.*;

    public class EffectEntityNode extends EntityNode {

        public function EffectEntityNode(_arg1:Entity){
            super(_arg1);
        }
        public function get attachEffect():Effect{
            return ((entity as Effect));
        }
        override public function isInFrustum(_arg1:Camera3D, _arg2:Boolean):uint{
            if (this.attachEffect.refCount == 0){
                this.removeFromParent();
                return (ViewTestResult.FULLY_OUT);
            };
            return (super.isInFrustum(_arg1, _arg2));
        }
        override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
            var _local3:Effect = this.attachEffect;
            var _local4 = !((_arg1 == ViewTestResult.FULLY_OUT));
            if (_local4){
                if (!_local3.parentLinkObject){
                    if (!_local3.update(getTimer(), _arg2.camera, null)){
                        _local4 = false;
                    };
                };
            };
            var _local5:Boolean = _local3.movable;
            if (_local4){
                DeltaXEntityCollector.VISIBLE_EFFECT_COUNT++;
                if (!_local5){
                    DeltaXEntityCollector.VISIBLE_STATIC_EFFECT_COUNT++;
                };
            };
            DeltaXEntityCollector.TESTED_EFFECT_COUNT++;
            if (!_local5){
                DeltaXEntityCollector.TESTED_STATIC_EFFECT_COUNT++;
            };
        }

    }
}//package deltax.graphic.effect.render 
