//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.effect.render.unit {
    import __AS3__.vec.*;
    
    import deltax.common.debug.*;
    import deltax.common.log.*;
    import deltax.common.math.*;
    import deltax.graphic.camera.*;
    import deltax.graphic.effect.*;
    import deltax.graphic.effect.data.unit.*;
    import deltax.graphic.effect.render.*;
    import deltax.graphic.effect.util.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.map.*;
    import deltax.graphic.model.*;
    import deltax.graphic.render.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.shader.*;
    import deltax.graphic.texture.*;
    import deltax.graphic.util.*;
    
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.geom.*;

    public class EffectUnit {

        private static const LIGHT_BLEND_FACTORS:Vector.<uint> = Vector.<uint>([4294901760, 4278190080, 4278190080, 4294901760, 3758096384, 3221225472, 2684354560, 2147483648, 1610612736, 1073741824, 536870912, 4294901760]);

        protected static var m_diffuseMaterialData:Vector.<Number> = Vector.<Number>([1, 1, 1, 1]);

        protected var m_effect:Effect;
        protected var m_effectUnitData:EffectUnitData;
        protected var m_effectUnitHandler:EffectUnitHandler;
        protected var m_curTexture:DeltaXTexture;
        protected var m_preFrame:Number = 0;
        protected var m_frameInterval:Number = 33;
        protected var m_preFrameTime:uint;
        protected var m_curAlpha:Number = 1;
        private var m_unitStartFrame:Number;
        private var m_trackFramePair:FramePair;
        private var m_delayTime:int;
        private var m_nodeID:int = -1;
        private var m_socketID:uint;
        private var m_unitState:uint = 1;
        private var m_renderDisabled:Boolean;
        private var m_linkedToParentUnit:Boolean;
        public var m_textureProxy:DeltaXTexture;
        protected var m_shaderProgram:DeltaXProgram3D;
        protected var m_matWorld:Matrix3D;
		
		public var showCoordinate:Boolean=false;		

        public function EffectUnit(_arg1:Effect, _arg2:EffectUnitData){
            this.m_trackFramePair = new FramePair();
            this.m_matWorld = new Matrix3D();
            super();
            ObjectCounter.add(this);
            this.m_effect = _arg1;
            this.m_effectUnitData = _arg2;
            this.m_effectUnitData.makeResValid(this.onTextureLoaded);
            this.m_unitStartFrame = this.m_effectUnitData.startFrame;
            this.m_textureProxy = DeltaXTextureManager.instance.createTexture(null);
            this.m_shaderProgram = ShaderManager.instance.getProgram3D(this.shaderType);
        }
        protected function onTextureLoaded(_arg1:BitmapDataResourceBase, _arg2:Boolean):void{
        }
        public function get renderDisabled():Boolean{
            return (this.m_renderDisabled);
        }
        public function set renderDisabled(_arg1:Boolean):void{
            this.m_renderDisabled = _arg1;
        }
        public function get effectUnitHandler():EffectUnitHandler{
            return (this.m_effectUnitHandler);
        }
        public function set effectUnitHandler(_arg1:EffectUnitHandler):void{
            this.m_effectUnitHandler = _arg1;
        }
        public function destroy():void{
            if (this.m_effectUnitHandler){
                this.m_effectUnitHandler = null;
            };
            if (this.m_curTexture){
                this.m_curTexture.release();
                this.m_curTexture = null;
            };
            this.m_textureProxy = null;
        }
        public function release():void{
            this.destroy();
            EffectManager.instance.removeRenderingEffectUnit(this);
        }
        public function get effect():Effect{
            return (this.m_effect);
        }
        public function get effectUnitData():EffectUnitData{
            return (this.m_effectUnitData);
        }
        public function get curTexture():DeltaXTexture{
            return (this.m_curTexture);
        }
        public function set curTexture(_arg1:DeltaXTexture):void{
            if (this.m_curTexture){
                this.m_curTexture.release();
            };
            this.m_curTexture = _arg1;
            if (this.m_curTexture){
                this.m_curTexture.reference();
            };
        }
        public function get preFrame():Number{
            return (this.m_preFrame);
        }
        public function get frameInterval():Number{
            return (this.m_frameInterval);
        }
        public function set frameInterval(_arg1:Number):void{
            this.m_frameInterval = _arg1;
        }
        public function get frameRatio():Number{
            return ((this.m_frameInterval / Animation.DEFAULT_FRAME_INTERVAL));
        }
        public function get preFrameTime():uint{
            return (this.m_preFrameTime);
        }
        public function get unitStartFrame():Number{
            return (this.m_unitStartFrame);
        }
        public function set unitStartFrame(_arg1:Number):void{
            this.m_unitStartFrame = _arg1;
        }
        public function get nodeID():int{
            return (this.m_nodeID);
        }
        public function get socketID():uint{
            return (this.m_socketID);
        }
        public function get unitState():uint{
            return (this.m_unitState);
        }
        public function set unitState(_arg1:uint):void{
            this.m_unitState = _arg1;
        }
        public function get linkedToParentUnit():Boolean{
            return (this.m_linkedToParentUnit);
        }
        public function set linkedToParentUnit(_arg1:Boolean):void{
            this.m_linkedToParentUnit = _arg1;
        }
        public function getTexture(_arg1:Number):DeltaXTexture{
            return ((this.m_curTexture) ? this.m_curTexture : this.m_effectUnitData.getTextureByPos(_arg1));
        }
        public function getColorTexture(_arg1:Context3D):Texture{
            var _local2:Texture = this.m_effectUnitData.getColorTexture().getTextureForContext(_arg1);
            if (_local2 == DeltaXTextureManager.defaultTexture3D){
                return (null);
            };
            return (_local2);
        }
        public function getColorByPos(_arg1:Number):uint{
            var _local2:uint = this.m_effectUnitData.getColorByPos(_arg1);
            if (this.m_curAlpha >= 1){
                return (_local2);
            };
            if (this.m_curAlpha == 0){
                _local2 = (_local2 & 0xFFFFFF);
            } else {
                Color.TEMP_COLOR.value = _local2;
                Color.TEMP_COLOR.A = (Color.TEMP_COLOR.A * this.m_curAlpha);
                _local2 = Color.TEMP_COLOR.value;
            };
            return (_local2);
        }
        public function onLinkedToParent(_arg1:LinkableRenderable):void{
            var _local2:String = ((this.m_effectUnitData.updatePos == EffectUnitUpdatePosType.FIXED)) ? "" : this.m_effectUnitData.attachName;
            var _local3:Array = _arg1.getLinkIDsByAttachName(_local2);
            this.m_nodeID = _local3[0];
            this.m_socketID = _local3[1];
        }
        public function onUnLinkedFromParent(_arg1:LinkableRenderable):void{
        }
        public function get presentRenderObject():LinkableRenderable{
            return (null);
        }
        public function checkTrackAniStart(_arg1:uint, _arg2:Number):void{
            var _local3:Number;
            var _local4:Number;
            var _local5:Number;
            var _local6:Number;
            if (this.m_unitState == EffectUnitState.CALC_START){
                _local3 = (this.m_delayTime / this.m_frameInterval);
                _local4 = ((_arg2 - this.m_trackFramePair.startFrame) + _local3);
                this.m_unitStartFrame = (_local4 + this.m_effectUnitData.startFrame);
                this.m_unitState = EffectUnitState.CHECK_START;
                this.m_delayTime = 0;
            };
            if (this.m_unitState == EffectUnitState.CHECK_START){
                _local5 = (this.m_unitStartFrame - this.m_effectUnitData.startFrame);
                if ((((_arg2 >= this.m_unitStartFrame)) && ((_arg2 >= (_local5 + this.m_trackFramePair.startFrame))))){
                    _local6 = (_arg2 - this.m_unitStartFrame);
                    this.m_preFrameTime = (_arg1 - uint((_local3 * this.m_frameInterval)));
                    this.m_preFrame = this.m_unitStartFrame;
                    this.m_unitState = EffectUnitState.RENDER;
                    this.onPlayStarted();
                };
            };
        }
        protected function onPlayStarted():void{
        }
        public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            return (false);
        }
        public function get worldMatrix():Matrix3D{
            return (this.m_matWorld);
        }
        public function getNodeMatrix(_arg1:Matrix3D, _arg2:uint, _arg3:uint):void{
            _arg1.copyFrom(this.worldMatrix);
        }
        protected function get worldMatrixForRender():Matrix3D{
            return (this.m_matWorld);
        }
        protected function setBlendMode(_arg1:uint, _arg2:Context3D, _arg3:Camera3D):void{
            var _local4:SceneEnv;
            var _local5:uint;
            var _local6:Vector3D;
            var _local7:Number;
            var _local8:Number;
            var _local9:Number;
            var _local10:Color;
            var _local11:Number;
            this.m_shaderProgram.setParamValue(DeltaXProgram3D.ALPHAREF, 1E-6, 0, 0, 0);
            if ((((_arg1 < BlendMode.MULTIPLY_1)) || ((_arg1 > BlendMode.MULTIPLY_7)))){
                this.m_shaderProgram.setParamColor(DeltaXProgram3D.FACTOR, LIGHT_BLEND_FACTORS[_arg1]);
            };
            if ((((_arg1 == BlendMode.NONE)) || ((_arg1 == BlendMode.DISTURB_SCREEN)))){
                if ((((_arg1 == BlendMode.DISTURB_SCREEN)) && (!(EffectManager.instance.screenDisturbEnable)))){
                    _arg2.setBlendFactors(Context3DBlendFactor.ZERO, Context3DBlendFactor.ZERO);
                } else {
                    _arg2.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
                };
            } else {
                _local4 = DeltaXRenderer.instance.curEnviroment;
                _local5 = _local4.m_fogColor;
                switch (_arg1){
                    case BlendMode.ADD:
                        _arg2.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
                        break;
                    case BlendMode.MULTIPLY:
                        _arg2.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
                        break;
                    case BlendMode.LIGHT:
                        _arg2.setBlendFactors(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE);
                        break;
                    case BlendMode.MULTIPLY_1:
                    case BlendMode.MULTIPLY_2:
                    case BlendMode.MULTIPLY_3:
                    case BlendMode.MULTIPLY_4:
                    case BlendMode.MULTIPLY_5:
                    case BlendMode.MULTIPLY_6:
                    case BlendMode.MULTIPLY_7:
                        if (_local5 > 0){
                            _local6 = _arg3.position;
                            _local7 = Vector3D.distance(_local6, this.worldMatrix.position);
                            _local8 = _local4.m_fogStart;
                            _local9 = _local4.m_fogEnd;
                            _local10 = Color.TEMP_COLOR;
                            _local10.value = LIGHT_BLEND_FACTORS[_arg1];
                            if ((((_local7 > _local8)) && ((_local7 <= _local9)))){
                                _local11 = _local10.A;
                                _local11 = (_local11 * MathUtl.limit(((_local7 - _local9) / (_local8 - _local9)), 0, 1));
                                _local10.A = _local11;
                            };
                            this.m_shaderProgram.setParamColor(DeltaXProgram3D.FACTOR, _local10.value);
                        } else {
                            this.m_shaderProgram.setParamColor(DeltaXProgram3D.FACTOR, LIGHT_BLEND_FACTORS[_arg1]);
                        };
                        _arg2.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
                        break;
                };
            };
        }
        protected function failedOnRenderWhileDisposed():void{
            if (((this.effect) && (this.effect.effectData))){
                dtrace(LogLevel.FATAL, "Error: effectUnit is released: ", this, this.effect.name, this.effect.effectData.effectGroup.name.split("/").pop());
            } else {
                dtrace(LogLevel.FATAL, "Error: effectUnit is released: ");
            };
        }
        public function render(_arg1:Context3D, _arg2:Camera3D):void{
        }
        protected function setDisturbState(_arg1:Context3D):void{
            var _local2:EffectManager;
            if (this.m_effectUnitData.blendMode == BlendMode.DISTURB_SCREEN){
                _local2 = EffectManager.instance;
                if (!_local2.screenDisturbEnable){
                    return;
                };
                this.m_shaderProgram.setSampleTexture(1, _local2.mainRenderTarget);
                this.m_shaderProgram.setVertexNumberParameterByName("colorScale", m_diffuseMaterialData);
            };
        }
        protected function deactivatePass(_arg1:Context3D):void{
            this.m_shaderProgram.deactivate(_arg1);
        }
        protected function get shaderType():uint{
            if ((((this.m_effectUnitData.blendMode == BlendMode.DISTURB_SCREEN)) && (EffectManager.instance.screenDisturbEnable))){
                return (ShaderManager.SHADER_DISTURB);
            };
            return ((this.m_effectUnitData.enableLight) ? ShaderManager.SHADER_LIGHT : ShaderManager.SHADER_DEFAULT);
        }
        protected function activatePass(_arg1:Context3D, _arg2:Camera3D):void{
            _arg1.setProgram(this.m_shaderProgram.getProgram3D(_arg1));
            this.setBlendMode(this.blendMode, _arg1, _arg2);
            _arg1.setCulling(Context3DTriangleFace.NONE);
            this.setDepthTest(_arg1, this.m_effectUnitData.depthTestMode);
        }
        protected function setDepthTest(_arg1:Context3D, _arg2:uint, _arg3:String="less"):void{
            if (_arg2 == DepthTestMode.NONE){
                _arg1.setDepthTest(false, Context3DCompareMode.ALWAYS);
            } else {
                _arg1.setDepthTest(!((_arg2 == DepthTestMode.TEST_ONLY)), _arg3);
            };
        }
        protected function get blendMode():uint{
            return (this.m_effectUnitData.blendMode);
        }
        public function calcCurFrame(_arg1:uint):Number{
            var _local2:Number = this.m_effectUnitData.endFrame;
            var _local3:int = (_arg1 - this.m_preFrameTime);
            if (_local3 <= 0){
                return (this.m_preFrame);
            };
            var _local4:Number = (this.m_preFrame + (_local3 / this.m_frameInterval));
            if (this.m_preFrame >= _local2){
                return (_local4);
            };
            if (_local4 > _local2){
                return (_local2);
            };
            return (_local4);
        }
        public function sendMsg(_arg1:uint, _arg2, _arg3=null):void{
        }
        public function onParentUpdate(_arg1:uint):void{
        }
        public function setTrackAni(_arg1:int, _arg2:FramePair):void{
            this.m_unitState = EffectUnitState.CALC_START;
            this.m_delayTime = _arg1;
            this.m_trackFramePair.copyFrom(_arg2);
        }
        public function set curAlpha(_arg1:Number):void{
            this.m_curAlpha = _arg1;
        }
        public function onParentRenderBegin(_arg1:uint, _arg2:Boolean):void{
        }
        public function onParentRenderEnd(_arg1:uint, _arg2:Boolean):void{
        }
		
		protected function renderCoordinate(cotex3D:Context3D):void{
			if(m_effect && m_effect.coordObject){
				if(!showCoordinate) {
					return;
				}else{
//					RenderBox.Render(cotex3D,m_matWorld,0,0,0,75,3,3);
//					RenderBox.Render(cotex3D,m_matWorld,0,0,0,3,125,3);
//					RenderBox.Render(cotex3D,m_matWorld,0,0,0,3,3,175);					
					m_effect.coordObject.worldMatrix.copyFrom(m_matWorld);
										
//					var _local6:Number=m_matWorld.position.normalize();
//					var l7:Vector3D=MathUtl.TEMP_VECTOR3D;
//					var m_startPos:Vector3D = MathUtl.TEMP_VECTOR3D3;
//					m_startPos.setTo(0,0,0);
//					var m_controlPos1:Vector3D=new Vector3D(150,0,0);					
//					var m_endPos:Vector3D=MathUtl.TEMP_VECTOR3D2;
//					m_endPos.setTo(200,0,200);
//					var tmp:Vector3D = MathUtl.TEMP_VECTOR3D4;
//					for(var n:Number=0;n<=1;n=n+0.05){
//						MathUtl.bezierInterpolate3D(m_startPos, m_controlPos1, m_controlPos1, m_endPos, n, l7);
//						RenderBox.Render(cotex3D,m_matWorld,l7.x,l7.y,l7.z,l7.x+10,l7.y+10,l7.z+10);
//					}
				}
			}
			
		}

    }
}//package deltax.graphic.effect.render.unit 
