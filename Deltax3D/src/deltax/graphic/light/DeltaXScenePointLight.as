//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.light {
    import deltax.graphic.map.*;
    import flash.utils.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.util.*;

    public class DeltaXScenePointLight extends DeltaXPointLight {

        private static const eShowStage_Diffuse:uint = 0;
        private static const eShowStage_DiffuseToDynamic:uint = 1;
        private static const eShowStage_Dynamic:uint = 2;
        private static const eShowStage_DynamicToDiffuse:uint = 3;
        private static const eShowStage_Count:uint = 4;

        private var m_lightInfo:RegionLightInfo;
        private var m_preChangeTime:uint = 0;
        private var m_curShowStage:uint;

        public function DeltaXScenePointLight(_arg1:RegionLightInfo){
            this.m_lightInfo = _arg1;
            color = _arg1.m_colorInfos[0].m_color;
            setAttenuation(0, _arg1.m_attenuation0);
            setAttenuation(1, _arg1.m_attenuation1);
            setAttenuation(2, _arg1.m_attenuation2);
            fallOff = _arg1.m_range;
        }
        override protected function createEntityPartitionNode():EntityNode{
            return (new DeltaXScenePointLightNode(this));
        }
        private function GetDiffuse(_arg1:uint=2, _arg2:Number=0):uint{
            return (this.m_lightInfo.getColor(_arg1));
        }
        private function GetDynColor(_arg1:uint=2, _arg2:Number=0):uint{
            return (this.m_lightInfo.getDynamicColor(_arg1));
        }
        public function onAcceptTraverser(_arg1:Boolean):void{
            var _local5:Number;
            var _local6:Number;
            var _local7:Color;
            var _local8:Color;
            if (!_arg1){
                return;
            };
            var _local2:uint = this.GetDiffuse();
            var _local3:Boolean = (((((((this.m_lightInfo.m_dyn_BrightTime == 0)) && ((this.m_lightInfo.m_dyn_ChangeTime == 0)))) && ((this.m_lightInfo.m_dyn_DarkTime == 0)))) || ((this.m_lightInfo.m_dyn_ChangeProbability == 0)));
            if (this.GetDynColor() == 4278190080){
                _local3 = true;
            };
            var _local4:uint = getTimer();
            _local7 = Color.TEMP_COLOR;
            _local8 = Color.TEMP_COLOR2;
            if (this.m_preChangeTime == 0){
                this.m_preChangeTime = _local4;
                this.m_curShowStage = eShowStage_Diffuse;
                _local3 = true;
            };
            var _local9:Number = (128 / 1000);
            while (!(_local3)) {
                if (this.m_curShowStage == eShowStage_Diffuse){
                    if ((((((_local4 - this.m_preChangeTime) * _local9) > this.m_lightInfo.m_dyn_BrightTime)) || ((this.m_lightInfo.m_dyn_BrightTime < 5)))){
                        if ((Math.random() * 0x0100) < this.m_lightInfo.m_dyn_ChangeProbability){
                            this.m_curShowStage = eShowStage_DiffuseToDynamic;
                        };
                        this.m_preChangeTime = _local4;
                    } else {
                        _local3 = true;
                    };
                } else {
                    if (this.m_curShowStage == eShowStage_DiffuseToDynamic){
                        _local5 = ((_local4 - this.m_preChangeTime) * _local9);
                        if ((((_local5 > this.m_lightInfo.m_dyn_ChangeTime)) || ((this.m_lightInfo.m_dyn_ChangeTime < 5)))){
                            this.m_preChangeTime = _local4;
                            this.m_curShowStage = eShowStage_Dynamic;
                        } else {
                            _local6 = (_local5 / this.m_lightInfo.m_dyn_ChangeTime);
                            _local7.value = this.GetDynColor();
                            _local8.value = _local2;
                            _local2 = _local7.interpolate(_local8, _local6);
                            _local3 = true;
                        };
                    } else {
                        if (this.m_curShowStage == eShowStage_Dynamic){
                            _local5 = ((_local4 - this.m_preChangeTime) * _local9);
                            if ((((_local5 > this.m_lightInfo.m_dyn_DarkTime)) || ((this.m_lightInfo.m_dyn_DarkTime < 5)))){
                                this.m_preChangeTime = _local4;
                                this.m_curShowStage = eShowStage_DynamicToDiffuse;
                            } else {
                                _local2 = this.GetDynColor();
                                _local3 = true;
                            };
                        } else {
                            if (this.m_curShowStage == eShowStage_DynamicToDiffuse){
                                _local5 = ((_local4 - this.m_preChangeTime) * _local9);
                                if ((((_local5 > this.m_lightInfo.m_dyn_ChangeTime)) || ((this.m_lightInfo.m_dyn_ChangeTime < 5)))){
                                    this.m_preChangeTime = _local4;
                                    this.m_curShowStage = eShowStage_Diffuse;
                                } else {
                                    _local6 = (_local5 / this.m_lightInfo.m_dyn_ChangeTime);
                                    _local8.value = this.GetDynColor();
                                    _local7.value = _local2;
                                    _local2 = _local7.interpolate(_local8, _local6);
                                    _local3 = true;
                                };
                            } else {
                                this.m_preChangeTime = _local4;
                                this.m_curShowStage = eShowStage_Diffuse;
                                _local3 = true;
                            };
                        };
                    };
                };
            };
            color = _local2;
        }

    }
}//package deltax.graphic.light 

import deltax.graphic.scenegraph.partition.*;
import deltax.graphic.scenegraph.traverse.*;
import deltax.graphic.light.*;
class DeltaXScenePointLightNode extends LightNode {

    public function DeltaXScenePointLightNode(_arg1:DeltaXScenePointLight){
        super(_arg1);
    }
    override protected function onVisibleTestResult(_arg1:uint, _arg2:PartitionTraverser):void{
        DeltaXScenePointLight(_entity).onAcceptTraverser(!((_arg1 == ViewTestResult.FULLY_OUT)));
        super.onVisibleTestResult(_arg1, _arg2);
    }

}
