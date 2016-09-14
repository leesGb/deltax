//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import __AS3__.vec.*;
    
    import deltax.common.math.*;
    import deltax.graphic.camera.*;
    import deltax.graphic.effect.*;
    import deltax.graphic.effect.data.unit.*;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.effect.util.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.model.*;
    import deltax.graphic.shader.*;
    import deltax.graphic.texture.*;
    
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.geom.*;

    public class Billboard extends EffectUnit {

        private static const GRID_UNIT_SIZE_INV:Number = 0.015625;

        private var m_halfWidth:Number = 0;
        private var m_widthRatio:Number = 0;
        private var m_percent:Number = 0;
        private var m_curAngle:Number = 0;
        private var m_speed:Vector3D;
        private var m_renderType:uint;

        public function Billboard(_arg1:Effect, _arg2:EffectUnitData){
            this.m_speed = new Vector3D(0, 0, 1);
            this.m_renderType = BillboardRenderType.NEED_CREATE;
            super(_arg1, _arg2);
			
			if (BillboardData(m_effectUnitData).m_synRotate){
				this.m_curAngle = BillboardData(m_effectUnitData).m_startAngle;			
			}
        }
        public function get widthRatio():Number{
            return (this.m_widthRatio);
        }
        public function set widthRatio(_arg1:Number):void{
            this.m_widthRatio = _arg1;
        }
        public function get halfWidth():Number{
            return (this.m_halfWidth);
        }
        public function set halfWidth(_arg1:Number):void{
            this.m_halfWidth = _arg1;
        }
        private function get isAttachGroundOrWater():Boolean{
            var _local1:BillboardData = BillboardData(m_effectUnitData);
            var _local2:uint = _local1.m_faceType;
            return ((((((((_local2 == FaceType.ATTACH_TO_TERRAIN)) || ((_local2 == FaceType.ATTACH_TO_TERRAIN_NO_ROTATE)))) || ((_local2 == FaceType.ATTACH_TO_WATER)))) || ((_local2 == FaceType.ATTACH_TO_WATER_NO_ROTATE))));
        }
        override protected function get worldMatrixForRender():Matrix3D{
            return ((this.isAttachGroundOrWater) ? MathUtl.IDENTITY_MATRIX3D : m_matWorld);
        }
        override protected function get shaderType():uint{
            if (this.isAttachGroundOrWater){
                return (ShaderManager.SHADER_BILLBOARD_ATCHTERR);
            };
            return (ShaderManager.SHADER_BILLBOARD_NORMAL);
        }
        override protected function onPlayStarted():void{
            super.onPlayStarted();
            var _local1:BillboardData = BillboardData(m_effectUnitData);
            if (_local1.m_synRotate){
                this.m_curAngle = _local1.m_startAngle;
            };
            this.m_renderType = BillboardRenderType.NEED_CREATE;
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local4:BillboardData;
            var _local13:Billboard;
            var _local14:Vector3D;
            var _local15:Number;
            var _local16:Vector3D;
            var _local17:Vector3D;
            var _local18:Number;
            var _local19:Number;
            var _local20:Number;
            var _local21:Vector3D;
            var _local22:Vector3D;
            var _local23:Vector3D;
            var _local24:Vector3D;
            var _local25:Vector3D;
            var _local26:Matrix3D;
            var _local27:Number;
            var _local28:Vector3D;
            var _local29:Number;
            var _local30:Matrix3D;
            _local4 = BillboardData(m_effectUnitData);
            if (m_preFrame > _local4.endFrame){
                return (false);
            };
            if (_local4.blendMode == BlendMode.DISTURB_SCREEN){
                return (false);
            };
            var _local5:Number = calcCurFrame(_arg1);
            var _local6:EffectManager = EffectManager.instance;
            if (((_local4.m_bindOnlyStart) && (!((this.m_renderType == BillboardRenderType.NEED_RENDER))))){
                if (this.m_renderType == BillboardRenderType.NEED_CREATE){
                    _local13 = new Billboard(this.effect, _local4);
                    _local13.checkTrackAniStart(_arg1, _local5);
                    _local13.frameInterval = frameInterval;
                    _local13.m_renderType = BillboardRenderType.NEED_RENDER;
                    _local6.addLeavingEffectUnit(_local13, _arg3);
                    this.m_renderType = BillboardRenderType.NEED_RESTART;
                };
                return (false);
            };
            this.m_percent = ((_local5 - _local4.startFrame) / _local4.frameRange);
            var _local7:DeltaXTexture = getTexture(this.m_percent);
            if (!_local7){
                return (false);
            };
            m_textureProxy = _local7;
            var _local8:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local4.getOffsetByPos(this.m_percent, _local8);
            var _local9:Number = _local4.getScaleByPos(this.m_percent);
            this.m_halfWidth = (_local4.m_minSize + ((_local4.m_maxSize - _local4.m_minSize) * _local9));
            this.m_widthRatio = _local4.m_widthRatio;
            this.m_curAngle = (this.m_curAngle + (((_local4.m_angularVelocity * (_local5 - m_preFrame)) * 0.001) * Animation.DEFAULT_FRAME_INTERVAL));
            m_preFrameTime = _arg1;
            m_preFrame = _local5;
            var _local10:uint = _local4.m_faceType;
            var _local11:Boolean = (((_local10 == FaceType.ATTACH_TO_TERRAIN)) || ((_local10 == FaceType.ATTACH_TO_TERRAIN_NO_ROTATE)));
            var _local12:Boolean = (((_local10 == FaceType.ATTACH_TO_WATER)) || ((_local10 == FaceType.ATTACH_TO_WATER_NO_ROTATE)));
            if (((_local12) || (_local11))){
                m_matWorld.copyFrom(_arg3);
                if ((((_local4.m_blendMode == BlendMode.DISTURB_SCREEN)) && (!(_local6.screenFilterEnable)))){
                    return (false);
                };
                _local14 = MathUtl.TEMP_VECTOR3D;
                m_matWorld.copyColumnTo(0, _local14);
                _local15 = _local14.length;
                m_matWorld.copyColumnTo(1, _local14);
                _local15 = (_local15 + _local14.length);
                m_matWorld.copyColumnTo(2, _local14);
                _local15 = (_local15 + _local14.length);
                this.m_halfWidth = (this.m_halfWidth * (_local15 / 3));
            } else {
                _local16 = m_matWorld.position;
                if ((((_local10 == FaceType.VELOCITY_DIR)) || ((_local10 == FaceType.PARALLEL_VELOCITY_DIR)))){
                    m_matWorld.identity();
                    m_matWorld.position = _arg3.position;
                } else {
                    m_matWorld.copyFrom(_arg3);
                };
                _local8 = m_matWorld.transformVector(_local8);
                _local17 = MathUtl.TEMP_VECTOR3D;
                if ((((_local10 == FaceType.SIZE_BY_CAMERA_NORMAL)) || ((_local10 == FaceType.CAMERA_NORMAL)))){
                    m_matWorld.copyColumnTo(0, _local17);
                    _local18 = _local17.length;
                    m_matWorld.copyColumnTo(1, _local17);
                    _local19 = _local17.length;
                    m_matWorld.copyColumnTo(2, _local17);
                    _local20 = _local17.length;
                    m_matWorld.identity();
                    m_matWorld.appendScale(_local18, _local19, _local20);
                    m_matWorld.position = _local8;
                    m_matWorld.prepend(DeltaXCamera3D(_arg2).billboardMatrix);
                } else if(_local10 == FaceType.CAMERA_GAME){
					m_matWorld.copyColumnTo(0, _local17);
					_local18 = _local17.length;
					m_matWorld.copyColumnTo(1, _local17);
					_local19 = _local17.length;
					m_matWorld.copyColumnTo(2, _local17);
					_local20 = _local17.length;
					m_matWorld.identity();
					m_matWorld.appendScale(_local18, _local19, _local20);
					m_matWorld.position = _local8;
					//m_matWorld.prepend(DeltaXCamera3D(_arg2).billboardMatrix);
					var billMartix:Matrix3D = MathUtl.TEMP_MATRIX3D;
					DeltaXCamera3D(_arg2).billboardMatrix.copyToMatrix3D(billMartix);
					//m_matWorld.prepend(billMartix);
					var v3:Vector.<Vector3D> = billMartix.decompose(Orientation3D.EULER_ANGLES);
					var q:Quaternion=new Quaternion();
					q.fromEulerAngles(0,v3[1].y,0);
					q.toMatrix3D(billMartix);
					m_matWorld.prepend(billMartix);
					//m_matWorld.recompose(v3,Orientation3D.AXIS_ANGLE);
				}else {
                    if ((((_local10 == FaceType.WORLD_NORMAL)) || ((_local10 == FaceType.PARALLEL_WORLD_NORMAL)))){
                        m_matWorld.copyColumnTo(0, _local17);
                        _local18 = _local17.length;
                        m_matWorld.copyColumnTo(1, _local17);
                        _local19 = _local17.length;
                        m_matWorld.copyColumnTo(2, _local17);
                        _local20 = _local17.length;
                        m_matWorld.identity();
                        m_matWorld.appendScale(_local18, _local19, _local20);
                    };
                    m_matWorld.position = _local8;
                };
                _local21 = MathUtl.TEMP_VECTOR3D;
                _local21.copyFrom(_local4.m_normal);
                if ((((_local10 == FaceType.VELOCITY_DIR)) || ((_local10 == FaceType.PARALLEL_VELOCITY_DIR)))){
                    m_matWorld.copyColumnTo(3, _local21);
                    _local21.decrementBy(_local16);
                    _local27 = _local21.length;
                    if (_local27 < 0.0001){
                        _local21.copyFrom(this.m_speed);
                    } else {
                        _local21.scaleBy((1 / _local27));
                    };
                    this.m_speed.copyFrom(_local21);
                };
                _local22 = DeltaXCamera3D(_arg2).lookDirection;
                _local23 = MathUtl.TEMP_VECTOR3D2;
                _local23.copyFrom(Vector3D.X_AXIS);
                _local24 = MathUtl.TEMP_VECTOR3D3;
                _local24.copyFrom(Vector3D.Y_AXIS);
                if ((((((_local10 == FaceType.PARALLEL_LOCAL_NORMAL)) || ((_local10 == FaceType.PARALLEL_WORLD_NORMAL)))) || ((_local10 == FaceType.PARALLEL_VELOCITY_DIR)))){
                    _local23.copyFrom(_local21);
                    _local23.normalize();
                    VectorUtil.crossProduct(_local21, _local22, _local24);
                    _local24.normalize();
                } else {
                    if (_local10 == FaceType.SIZE_BY_CAMERA_NORMAL){
                        _local28 = MathUtl.TEMP_VECTOR3D4;
                        _local28.copyFrom(_local8);
                        _local28.decrementBy(_arg2.scenePosition);
                        _local28.normalize();
                        _local29 = VectorUtil.crossProduct(_local28, _local22, MathUtl.TEMP_VECTOR3D5).length;
                        this.m_percent = MathUtl.limit(_local29, 0, 1);
                    } else {
                        _local27 = _local21.length;
                        if ((((_local27 > 0.001)) && ((((((Math.abs(_local21.x) > 0.001)) || ((Math.abs(_local21.y) > 0.001)))) || ((Math.abs((_local21.z - 1)) > 0.001)))))){
                            VectorUtil.crossProduct(_local21, Vector3D.Z_AXIS, _local23);
                            _local23.normalize();
                            VectorUtil.crossProduct(_local23, _local21, _local24);
                        };
                    };
                };
                if ((((_local4.m_angularVelocity > 1E-5)) || ((_local4.m_startAngle > 1E-5)))){
                    _local30 = MathUtl.TEMP_MATRIX3D;
                    _local30.identity();
                    if (_local4.m_angularVelocity == 0){
                        _local25 = MathUtl.TEMP_VECTOR3D4;
                        VectorUtil.crossProduct(_local23, _local24, _local25);
                        _local30.appendRotation((-(this.m_curAngle) * MathConsts.RADIANS_TO_DEGREES), _local25);
                    } else {									
                        _local30.appendRotation((-(this.m_curAngle) * MathConsts.RADIANS_TO_DEGREES), _local4.m_rotateAxis);						
                    };
                    m_matWorld.prepend(_local30);
                };
                if ((((_local4.m_blendMode == BlendMode.DISTURB_SCREEN)) && (!(_local6.screenDisturbEnable)))){
                    return (false);
                };
                _local26 = MathUtl.TEMP_MATRIX3D;
                _local26.identity();
                _local23.w = (_local24.w = 0);
                _local26.copyColumnFrom(0, _local23);
                _local26.copyColumnFrom(1, _local24);
                if (!_local25){
                    _local25 = MathUtl.TEMP_VECTOR3D4;
                    VectorUtil.crossProduct(_local23, _local24, _local25);
                };
                _local25.w = 0;
                _local26.copyColumnFrom(2, _local25);
                m_matWorld.prepend(_local26);
            };
            return (((!((_local4.m_minSize == 0))) || (!((_local4.m_maxSize == 0)))));
        }
        private function defaultGetHeightFun(_arg1:uint, _arg2:uint):Number{
            return (0);
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void{
			if(shaderType != ShaderManager.instance.getShaderTypeByProgram3D(m_shaderProgram)){
				this.m_shaderProgram = ShaderManager.instance.getProgram3D(this.shaderType);
			}
			
            var _local9:EffectSystemListener;
            var _local10:Vector3D;
            var _local11:Vector3D;
            var _local12:int;
            var _local13:int;
            var _local14:int;
            var _local15:int;
            var _local16:int;
            var _local17:int;
            var _local18:uint;
            var _local19:Function;
            var _local20:Vector.<Number>;
            var _local21:uint;
            var _local22:int;
            var _local23:Vector.<uint>;
            var _local24:Number;
            var _local25:int;
            var _local26:int;
            var _local27:uint;
            var _local28:uint;
            if (!m_textureProxy){
                return;
            };
            var _local3:Texture = getColorTexture(_arg1);
            if (_local3 == null){
                return;
            };
            var _local4:BillboardData = BillboardData(m_effectUnitData);
            var _local5:EffectManager = EffectManager.instance;
            var _local6:uint = _local4.m_faceType;
            var _local7:Boolean = (((_local6 == FaceType.ATTACH_TO_TERRAIN)) || ((_local6 == FaceType.ATTACH_TO_TERRAIN_NO_ROTATE)));
            var _local8:Boolean = (((_local6 == FaceType.ATTACH_TO_WATER)) || ((_local6 == FaceType.ATTACH_TO_WATER_NO_ROTATE)));
            if (((_local8) || (_local7))){
                _local9 = _local5.listener;
                _local10 = MathUtl.TEMP_VECTOR3D;
                _local4.getOffsetByPos(this.m_percent, _local10);
                _local11 = MathUtl.TEMP_VECTOR3D2;
                VectorUtil.transformByMatrix(_local10, m_matWorld, _local11);	
				_local11.y = 0;
				m_matWorld.position = _local11;
				
                _local12 = int(Math.floor(((_local11.x - this.m_halfWidth) * GRID_UNIT_SIZE_INV)));
                _local13 = (int(Math.floor(((_local11.x + this.m_halfWidth) * GRID_UNIT_SIZE_INV))) + 1);
                _local14 = (int(Math.floor(((_local11.z + this.m_halfWidth) * GRID_UNIT_SIZE_INV))) + 1);
                _local15 = int(Math.floor(((_local11.z - this.m_halfWidth) * GRID_UNIT_SIZE_INV)));
                _local16 = (_local13 - _local12);
                _local17 = (_local14 - _local15);
                if ((((_local16 == 0)) || ((_local17 == 0)))){
                    return;
                };
                _local18 = ((_local16 > _local17)) ? _local16 : _local17;
                if (_local18 > 20){
                    _local28 = ((_local18 - 20) >> 1);
                    _local12 = (_local12 + _local28);
                    _local15 = (_local15 + _local28);
                    _local18 = 20;
                };
                if (!_local9){
                    _local19 = this.defaultGetHeightFun;
                } else {
                    if (_local8){
                        _local19 = _local9.getWaterHeightByGridFun();
                    } else {
                        _local19 = _local9.getTerrainLogicHeightByGridFun();
                    };
                };
                _local19 = ((_local19) || (this.defaultGetHeightFun));
                _local20 = m_shaderProgram.getVertexParamCache();
                _local21 = (m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.TEXTUREMATRIX) * 4);
                _local22 = ((_local18 + 1) * (_local18 + 1));
                _local23 = DeltaXSubGeometryManager.Instance.index2Pos;
                _local24 = ((((_local6 == FaceType.ATTACH_TO_TERRAIN)) || ((_local6 == FaceType.ATTACH_TO_WATER)))) ? 1 : 0;
                _local27 = 0;
                while (_local27 < _local22) {
                    _local25 = ((_local23[_local27] & 0xFF) + _local12);
                    _local26 = ((_local23[_local27] >> 8) + _local15);
                    _local20[_local21] = _local19(_local25, _local26);
                    _local27++;
                    _local21++;
                };
                activatePass(_arg1, _arg2);
                setDisturbState(_arg1);
                m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_matWorld, true);
                m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, _local12, _local15, this.m_halfWidth, m_curAlpha);
                m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, _local24, this.m_curAngle, this.m_percent, 0);
                m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(_arg1));
                m_shaderProgram.setSampleTexture(1, _local3);
                m_shaderProgram.update(_arg1);
                DeltaXSubGeometryManager.Instance.drawPackRect2(_arg1, (_local18 * _local18));
                deactivatePass(_arg1);
            } else {
                activatePass(_arg1, _arg2);
                setDisturbState(_arg1);
                m_shaderProgram.setParamMatrix(DeltaXProgram3D.WORLD, m_matWorld, true);
                m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, this.m_percent, this.m_halfWidth, this.m_widthRatio, m_curAlpha);
                m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(_arg1));
                m_shaderProgram.setSampleTexture(1, _local3);
                m_shaderProgram.update(_arg1);
                DeltaXSubGeometryManager.Instance.drawPackRect2(_arg1, 1);
                deactivatePass(_arg1);
            };
			
			renderCoordinate(_arg1);
        }

    }
}//package deltax.graphic.effect.render.unit 

class BillboardRenderType {

    public static const NEED_RESTART:uint = 0;
    public static const NEED_CREATE:uint = 1;
    public static const NEED_RENDER:uint = 2;

    public function BillboardRenderType(){
    }
}
