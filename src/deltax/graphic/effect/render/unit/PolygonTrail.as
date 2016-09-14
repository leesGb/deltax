//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import deltax.graphic.camera.*;
    import flash.display3D.*;
    import deltax.graphic.manager.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.texture.*;
    import deltax.common.math.*;
    import flash.display3D.textures.*;
    import deltax.graphic.shader.*;
    import deltax.graphic.effect.*;
    import deltax.graphic.effect.data.unit.*;
    import deltax.graphic.effect.util.*;
    import deltax.graphic.effect.data.unit.polytrail.*;

    public class PolygonTrail extends EffectUnit {

        private static var m_coordMatrix:Vector.<Matrix3D> = new Vector.<Matrix3D>();
;

        private var m_headTrail:TrailUnitNode;
        private var m_tailTrail:TrailUnitNode;
        private var m_parentColor:uint;
        private var m_trailCount:uint;

        public function PolygonTrail(_arg1:Effect, _arg2:EffectUnitData){
            super(_arg1, _arg2);
        }
        override public function release():void{
            EffectManager.instance.addLeavingEffectUnit(this, MathUtl.IDENTITY_MATRIX3D);
            m_effect = null;
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local12:TrailUnitNode;
            var _local13:Vector3D;
            var _local14:Vector3D;
            var _local4:PolygonTrailData = PolygonTrailData(m_effectUnitData);
            var _local5:Matrix3D = MathUtl.TEMP_MATRIX3D;
            var _local6:Number = calcCurFrame(_arg1);
            var _local7:Vector3D = MathUtl.TEMP_VECTOR3D;
            var _local8:Number = ((_local6 - _local4.startFrame) / _local4.frameRange);
            _local5.copyFrom(_arg3);
            if (effect){
                _local4.getOffsetByPos(_local8, _local7);
                VectorUtil.transformByMatrixFast(_local7, _local5, _local7);
                m_matWorld.copyFrom(_local5);
                m_matWorld.position = _local7;
            };
            var _local9:EffectManager = EffectManager.instance;
            if ((((_local4.m_blendMode == BlendMode.DISTURB_SCREEN)) && (!(_local9.screenDisturbEnable)))){
                return (false);
            };
            var _local10:DeltaXTexture = getTexture(_local8);
            if (!_local10){
                return (false);
            };
            m_textureProxy = _local10;
            var _local11:uint = uint((_local4.m_unitLifeTime * frameRatio));
            while (((this.m_headTrail) && ((this.m_headTrail.startTime > 0)))) {
                if (int((_arg1 - this.m_headTrail.startTime)) < _local11){
                    break;
                };
                _local12 = this.m_headTrail;
                this.m_headTrail = this.m_headTrail.nextNode;
                TrailUnitNode.free(_local12);
                this.m_trailCount--;
            };
            if (this.m_headTrail == null){
                this.m_tailTrail = null;
            };
            if (((((effect) && ((int((_arg1 - m_preFrameTime)) > 0)))) && ((m_preFrame < _local4.endFrame)))){
                _local13 = MathUtl.TEMP_VECTOR3D;
                _local14 = MathUtl.TEMP_VECTOR3D2;
                m_matWorld.copyColumnTo(3, _local13);
                _local14.copyFrom(_local4.m_rotate);
                VectorUtil.rotateByMatrix(_local14, m_matWorld, _local14);
                if (((((((((((((this.m_tailTrail) && ((this.m_tailTrail.position1_x == _local13.x)))) && ((this.m_tailTrail.position1_y == _local13.y)))) && ((this.m_tailTrail.position1_z == _local13.z)))) && ((this.m_tailTrail.position2_x == _local14.x)))) && ((this.m_tailTrail.position2_y == _local14.y)))) && ((this.m_tailTrail.position2_z == _local14.z)))){
                    this.m_tailTrail.startTime = _arg1;
                } else {
                    _local12 = TrailUnitNode.alloc();
                    if (_local12){
                        this.m_trailCount++;
                        _local12.position1_x = _local13.x;
                        _local12.position1_y = _local13.y;
                        _local12.position1_z = _local13.z;
                        _local12.position2_x = _local14.x;
                        _local12.position2_y = _local14.y;
                        _local12.position2_z = _local14.z;
                        _local12.startTime = _arg1;
                        _local12.nextNode = null;
                        if (this.m_tailTrail){
                            this.m_tailTrail.nextNode = _local12;
                            this.m_tailTrail = _local12;
                        } else {
                            this.m_headTrail = _local12;
                            this.m_tailTrail = _local12;
                        };
                    };
                };
            };
            m_preFrameTime = _arg1;
            m_preFrame = _local6;
            return (!((this.m_tailTrail == this.m_headTrail)));
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void{
			if(shaderType != ShaderManager.instance.getShaderTypeByProgram3D(m_shaderProgram)){
				this.m_shaderProgram = ShaderManager.instance.getProgram3D(this.shaderType);
			}			
			
            var _local6:TrailUnitNode;
            var _local7:TrailUnitNode;
            var _local19:uint;
            var _local20:uint;
            var _local21:uint;
            var _local31:Number;
            if (m_textureProxy == null){
                return;
            };
            var _local3:Texture = getColorTexture(_arg1);
            if ((((_local3 == null)) || ((this.m_headTrail == null)))){
                return;
            };
            activatePass(_arg1, _arg2);
            setDisturbState(_arg1);
            var _local4:Number = (m_textureProxy.width / Number(m_textureProxy.height));
            var _local5:TrailUnitNode = this.m_headTrail;
            var _local8:PolygonTrailData = PolygonTrailData(m_effectUnitData);
            var _local9:uint = ((_local8.m_strip == PolyTrailType.BLOCK)) ? 1 : 4;
            var _local10:Number = (1 / _local9);
            var _local11:uint = (_local8.textureCircle * _local9);
            var _local12:Number = (1 / _local11);
            var _local13:Vector.<Number> = _local8.getScaleBuffer(50);
            var _local14:Vector.<Number> = m_shaderProgram.getVertexParamCache();
            var _local15:uint = (m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.AMBIENTCOLOR) * 4);
            var _local16:uint = (m_shaderProgram.getVertexParamRegisterCount(DeltaXProgram3D.AMBIENTCOLOR) * 4);
            var _local17:uint = (_local15 + _local16);
            var _local18:uint = _local15;
            if (_local8.m_strip == PolyTrailType.STRETCH){
                _local10 = (_local10 / (this.m_trailCount * _local8.textureCircle));
            };
            _local20 = 0;
            _local21 = 7;
            while (_local20 < 50) {
                _local14[_local21] = _local13[_local20];
                _local20++;
                _local21 = (_local21 + 8);
            };
            var _local22:uint;
            if (_local8.m_widthAsTextureU){
                _local22 = (_local22 + 4);
            };
            if (_local8.m_invertTexV){
                _local22 = (_local22 + 2);
            };
            if (_local8.m_invertTexU){
                _local22 = (_local22 + 1);
            };
            if (_local8.m_strip == PolyTrailType.BLOCK){
                _local22 = (7 - _local22);
            };
            var _local23:uint = (DeltaXSubGeometryManager.Instance.rectCountInVertexBuffer - _local11);
            var _local24:uint;
            var _local25:uint;
            var _local26:Number = _local8.m_minTrailWidth;
            var _local27:Number = _local8.m_maxTrailWidth;
            var _local28:Number = (_local8.m_unitLifeTime * frameRatio);
            var _local29:Number = (((_local8.m_singleSide) && (!((_local8.m_strip == PolyTrailType.BLOCK))))) ? 0 : 1;
            var _local30:Number = ((_local8.m_simulateType == PolyTrailSimulateType.CURVE)) ? 1 : 0;
            m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(_arg1));
            m_shaderProgram.setSampleTexture(1, _local3);
            m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, _local29, (_local29 + 1), _local12, m_curAlpha);
            m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, _local26, (_local27 - _local26), (1 / _local28), m_preFrameTime);
            m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, 0, _local10, _local4, _local30);
            m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_coordMatrix[_local22]);
            _local14[_local18] = _local5.position1_x;
            _local18++;
            _local14[_local18] = _local5.position1_y;
            _local18++;
            _local14[_local18] = _local5.position1_z;
            _local18++;
            _local14[_local18] = _local5.startTime;
            _local18++;
            _local14[_local18] = _local5.position2_x;
            _local18++;
            _local14[_local18] = _local5.position2_y;
            _local18++;
            _local14[_local18] = _local5.position2_z;
            _local18 = (_local18 + 2);
            while (_local5) {
                _local14[_local18] = _local5.position1_x;
                _local18++;
                _local14[_local18] = _local5.position1_y;
                _local18++;
                _local14[_local18] = _local5.position1_z;
                _local18++;
                _local14[_local18] = _local5.startTime;
                _local18++;
                _local14[_local18] = _local5.position2_x;
                _local18++;
                _local14[_local18] = _local5.position2_y;
                _local18++;
                _local14[_local18] = _local5.position2_z;
                _local18 = (_local18 + 2);
                if ((((_local18 >= (_local17 - 8))) || ((_local24 > _local23)))){
                    _local6 = (_local5.nextNode) ? _local5.nextNode : _local5;
                    _local14[_local18] = _local6.position1_x;
                    _local18++;
                    _local14[_local18] = _local6.position1_y;
                    _local18++;
                    _local14[_local18] = _local6.position1_z;
                    _local18++;
                    _local14[_local18] = _local6.startTime;
                    _local18++;
                    _local14[_local18] = _local6.position2_x;
                    _local18++;
                    _local14[_local18] = _local6.position2_y;
                    _local18++;
                    _local14[_local18] = _local6.position2_z;
                    _local18 = (_local18 + 2);
                    _local25 = (_local25 + _local24);
                    m_shaderProgram.update(_arg1);
                    DeltaXSubGeometryManager.Instance.drawPackRect(_arg1, _local24);
                    _local18 = _local15;
                    _local24 = 0;
                    if (_local8.m_strip == PolyTrailType.STRETCH){
                        _local31 = (_local10 * _local25);
                        m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, _local31, _local10, _local4, _local30);
                    };
                    _local14[_local18] = _local7.position1_x;
                    _local18++;
                    _local14[_local18] = _local7.position1_y;
                    _local18++;
                    _local14[_local18] = _local7.position1_z;
                    _local18++;
                    _local14[_local18] = _local7.startTime;
                    _local18++;
                    _local14[_local18] = _local7.position2_x;
                    _local18++;
                    _local14[_local18] = _local7.position2_y;
                    _local18++;
                    _local14[_local18] = _local7.position2_z;
                    _local18 = (_local18 + 2);
                } else {
                    _local7 = _local5;
                    _local5 = _local5.nextNode;
                    _local24 = (_local24 + _local11);
                };
            };
            _local14[_local18] = _local7.position1_x;
            _local18++;
            _local14[_local18] = _local7.position1_y;
            _local18++;
            _local14[_local18] = _local7.position1_z;
            _local18++;
            _local14[_local18] = _local7.startTime;
            _local18++;
            _local14[_local18] = _local7.position2_x;
            _local18++;
            _local14[_local18] = _local7.position2_y;
            _local18++;
            _local14[_local18] = _local7.position2_z;
            _local18 = (_local18 + 2);
            _local24 = (_local24 - _local11);
            _local25 = (_local25 + _local24);
            m_shaderProgram.update(_arg1);
            DeltaXSubGeometryManager.Instance.drawPackRect(_arg1, _local24);
            deactivatePass(_arg1);
            EffectManager.instance.addTotalPolyTrailCount(_local25);
			renderCoordinate(_arg1);
        }
        override protected function get worldMatrixForRender():Matrix3D{
            return (MathUtl.IDENTITY_MATRIX3D);
        }
        override protected function get shaderType():uint{
            if (PolygonTrailData(m_effectUnitData).m_strip == PolyTrailType.BLOCK){
                return (ShaderManager.SHADER_POLYTRAIL_BLOCK);
            };
            return (ShaderManager.SHADER_POLYTRAIL_NORMAL);
        }

        m_coordMatrix[0] = new Matrix3D(Vector.<Number>([-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[1] = new Matrix3D(Vector.<Number>([1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[2] = new Matrix3D(Vector.<Number>([-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[3] = new Matrix3D(Vector.<Number>([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[4] = new Matrix3D(Vector.<Number>([0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[5] = new Matrix3D(Vector.<Number>([0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[6] = new Matrix3D(Vector.<Number>([0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
        m_coordMatrix[7] = new Matrix3D(Vector.<Number>([0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]));
    }
}//package deltax.graphic.effect.render.unit 

class TrailUnitNode {

    public static var nodePool:TrailUnitNode = create(2000);

    public var startTime:Number;
    public var position1_x:Number;
    public var position1_y:Number;
    public var position1_z:Number;
    public var position2_x:Number;
    public var position2_y:Number;
    public var position2_z:Number;
    public var nextNode:TrailUnitNode;

    public function TrailUnitNode(){
    }
    private static function create(_arg1:uint):TrailUnitNode{
        var _local4:TrailUnitNode;
        var _local2:TrailUnitNode;
        var _local3:uint;
        while (_local3 < 2000) {
            _local4 = new TrailUnitNode();
            _local4.nextNode = _local2;
            _local2 = _local4;
            _local3++;
        };
        return (_local2);
    }
    public static function alloc():TrailUnitNode{
        var _local1:TrailUnitNode = nodePool;
        nodePool = (nodePool) ? nodePool.nextNode : null;
        return (_local1);
    }
    public static function free(_arg1:TrailUnitNode):void{
        _arg1.nextNode = nodePool;
        nodePool = _arg1;
    }

}
