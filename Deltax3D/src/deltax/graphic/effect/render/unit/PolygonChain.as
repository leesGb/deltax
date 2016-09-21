package deltax.graphic.effect.render.unit 
{
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    
    import deltax.common.math.MathUtl;
    import deltax.common.math.VectorUtil;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.effect.EffectManager;
    import deltax.graphic.effect.data.unit.EffectUnitData;
    import deltax.graphic.effect.data.unit.PolygonChainData;
    import deltax.graphic.effect.data.unit.polychain.PolyChainBindType;
    import deltax.graphic.effect.data.unit.polychain.PolyChainRenderType;
    import deltax.graphic.effect.data.unit.polychain.PolyChainTextureType;
    import deltax.graphic.effect.render.Effect;
    import deltax.graphic.effect.render.EffectUnitMsgID;
    import deltax.graphic.effect.util.BlendMode;
    import deltax.graphic.manager.DeltaXSubGeometryManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.model.Animation;
    import deltax.graphic.scenegraph.object.LinkableRenderable;
    import deltax.graphic.shader.DeltaXProgram3D;
    import deltax.graphic.texture.DeltaXTexture;

    public class PolygonChain extends EffectUnit 
	{

        private static const MAX_BIND_POS_COUNT_4X:uint = 64;

        private static var m_randNumber:Vector.<Number>;
        private static var m_destPosGenerateCompareFunctions:Vector.<Function>;

        private var m_setDestPosThisFrame:Boolean;
        private var m_curCustomName:String = "";
        private var m_bindDestPos:Vector3D;
        private var m_curTextureAdd:Number = 0;
        private var m_curAngle:Number = 0;
        private var m_ditheringBiasInfoList:Vector.<Vector.<DitheringBiasPair>>;
        private var m_preDitheringTime:uint;
        private var m_curDitheringTime:uint;
        private var m_preScalePercent:Number = 0;
        private var m_curScalePercent:Number = 0;
        private var m_bindDestPoses:Vector.<Number>;
        private var m_percent:Number;

        public function PolygonChain(_arg1:Effect, _arg2:EffectUnitData)
		{
            this.m_bindDestPos = new Vector3D();
            this.m_ditheringBiasInfoList = new Vector.<Vector.<DitheringBiasPair>>();
            this.m_bindDestPoses = new Vector.<Number>();
            super(_arg1, _arg2);
            var _local3:PolygonChainData = PolygonChainData(_arg2);
            this.m_curAngle = _local3.m_startAngle;
            this.m_curCustomName = _local3.customName;
            if (this.m_curCustomName.length > 0){
                EffectManager.instance.pushPolyChain(this.m_curCustomName, this);
            };
            this.checkBuildStaticValues();
        }
        private static function bindPosEmptyCompare(_arg1:LinkableRenderable, _arg2:EffectUnit):Boolean{
            return (true);
        }
        private static function bindPosParentCompare(_arg1:LinkableRenderable, _arg2:EffectUnit):Boolean{
            var _local3:LinkableRenderable = _arg2.effect.parentLinkObject;
            return (((((_local3) && (_arg1))) && ((_local3 == _arg1))));
        }
        private static function bindPosEffectCompare(_arg1:LinkableRenderable, _arg2:EffectUnit):Boolean{
            return ((_arg1 == _arg2.effect));
        }

        private function checkBuildStaticValues():void{
            var _local1:uint;
            if (!m_destPosGenerateCompareFunctions){
                m_destPosGenerateCompareFunctions = new Vector.<Function>(PolyChainBindType.COUNT, true);
                m_destPosGenerateCompareFunctions[PolyChainBindType.DEFAULT] = bindPosEmptyCompare;
                m_destPosGenerateCompareFunctions[PolyChainBindType.ONLY_SELF_EFFECT] = bindPosEffectCompare;
                m_destPosGenerateCompareFunctions[PolyChainBindType.ONLY_SELF_PARENT] = bindPosParentCompare;
            };
            if (!m_randNumber){
                m_randNumber = new Vector.<Number>(80, true);
                _local1 = 0;
                while (_local1 < m_randNumber.length) {
                    m_randNumber[_local1] = ((Math.random() * 2) - 1);
                    _local1++;
                };
            };
        }
        override public function release():void{
            if (this.m_curCustomName.length > 0){
                EffectManager.instance.popPolyChain(this.m_curCustomName, this);
            };
            super.release();
        }
        override public function sendMsg(_arg1:uint, _arg2:*, _arg3:*=null):void
		{
            if (_arg1 == EffectUnitMsgID.SET_POLYCHAIN_DEST_POS){
                if ((_arg2 is Vector3D)){
                    this.m_bindDestPos.copyFrom(Vector3D(_arg2));
                    this.m_setDestPosThisFrame = true;
                };
            };
        }
        override public function update(_arg1:uint, _arg2:Camera3D, _arg3:Matrix3D):Boolean{
            var _local4:PolygonChainData;
            var _local5:EffectManager;
            var _local6:Number;
            var _local9:Dictionary;
            _local4 = PolygonChainData(m_effectUnitData);
            if ((((m_preFrame > _local4.endFrame)) || ((_local4.m_chainCount <= 0)))){
                return (false);
            };
            _local5 = EffectManager.instance;
            if ((((_local4.m_blendMode == BlendMode.DISTURB_SCREEN)) && (!(_local5.screenDisturbEnable)))){
                return (false);
            };
            _local6 = calcCurFrame(_arg1);
            this.m_percent = ((_local6 - _local4.startFrame) / _local4.frameRange);
            var _local7:DeltaXTexture = getTexture(this.m_percent);
            if (!_local7){
                return (false);
            };
            m_textureProxy = _local7;
            if (this.m_curCustomName != _local4.customName){
                _local5.popPolyChain(this.m_curCustomName, null);
                this.m_curCustomName = _local4.customName;
                if (this.m_curCustomName.length > 0){
                    _local5.pushPolyChain(this.m_curCustomName, this);
                };
            };
            var _local8:Vector3D = MathUtl.TEMP_VECTOR3D;
            _local4.getOffsetByPos(this.m_percent, _local8);
            VectorUtil.transformByMatrixFast(_local8, _arg3, _local8);
            m_matWorld.identity();
            m_matWorld.position = _local8;
            if (_local4.m_uvSpeed > 0){
                this.m_curTextureAdd = (this.m_curTextureAdd + (((_local4.m_uvSpeed * (_local6 - m_preFrame)) * 0.001) * Animation.DEFAULT_FRAME_INTERVAL));
            } else {
                this.m_curTextureAdd = 0;
            };
            if ((_arg1 - this.m_curDitheringTime) >= _local4.m_ditheringInterval){
                this.m_preDitheringTime = this.m_curDitheringTime;
                this.m_preScalePercent = this.m_curScalePercent;
                this.m_curDitheringTime = _arg1;
                this.m_curScalePercent = this.m_percent;
            };
            if (this.m_setDestPosThisFrame){
                _local8.decrementBy(this.m_bindDestPos);
                this.m_bindDestPoses[0] = -(_local8.x);
                this.m_bindDestPoses[1] = -(_local8.y);
                this.m_bindDestPoses[2] = -(_local8.z);
                if (_local4.m_textureType == PolyChainTextureType.FILLSIZE){
                    this.m_bindDestPoses[3] = ((_local4.m_fitScale * _local8.length) / _local4.m_chainNodeCount);
                } else {
                    if (_local4.m_textureType == PolyChainTextureType.STRETCH){
                        this.m_bindDestPoses[3] = 1;
                    } else {
                        this.m_bindDestPoses[3] = _local4.m_chainNodeCount;
                    };
                };
                this.m_bindDestPoses.length = 4;
            } else {
                if (_local4.m_nextBindName.length > 0){
                    _local9 = _local5.getPolyChainListByName(_local4.m_nextBindName);
                    if (_local9){
                        this.makeDestPosAll(_local9, _local4, _local8);
                    };
                };
            };
            this.m_setDestPosThisFrame = false;
            m_preFrameTime = _arg1;
            m_preFrame = _local6;
            return ((this.m_bindDestPoses.length > 0));
        }
        override public function render(_arg1:Context3D, _arg2:Camera3D):void{
            var _local35:uint;
            var _local36:uint;
            var _local37:uint;
            var _local3:PolygonChainData = PolygonChainData(m_effectUnitData);
            if (m_textureProxy == null){
                return;
            };
            var _local4:Texture = getColorTexture(_arg1);
            if (_local4 == null){
                return;
            };
            var _local5:Vector3D = m_matWorld.position;
            var _local6:Vector.<Number> = _local3.m_sinCosInfo;
            var _local7:Vector.<Number> = _local3.getScaleBuffer(50);
            var _local8:Vector.<Number> = m_shaderProgram.getVertexParamCache();
            var _local9:uint = (m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.TEXTUREMATRIX) * 4);
            var _local10:uint = (m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.AMBIENTCOLOR) * 4);
            var _local11:uint = (m_shaderProgram.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLD) * 4);
            var _local12:uint = this.m_bindDestPoses.length;
            var _local13:uint = (_local12 / 3);
            var _local14:uint = _local3.m_chainNodeCount;
            var _local15:uint = (_local14 * _local3.m_chainCount);
            var _local16:uint = (_local15 * _local13);
            var _local17:uint = (((_local3.m_renderType == PolyChainRenderType.SMOOTH)) ? 8 : 1 * _local16);
            var _local18:uint = Math.min(_local17, 0x1000);
            var _local19:Number = _local3.m_chainNodeMinScope;
            var _local20:Number = _local3.m_chainNodeMaxScope;
            var _local21:Number = (_local20 - _local19);
            var _local22:Number = (_local3.m_changeScaleByTime) ? 0 : 1;
            var _local23:uint = (this.m_preDitheringTime & 4095);
            var _local24:uint = (this.m_curDitheringTime & 4095);
            var _local25:Number = (m_preFrameTime - this.m_curDitheringTime);
            var _local26:Number = (1 - _local22);
            var _local27:Number = (_local25 / _local3.m_ditheringInterval);
            var _local28:Number = (1 - _local27);
            var _local29:Number = (_local3.m_scaleAsDitheringScope) ? 0 : 1;
            var _local30:Number = (_local3.m_scaleAsDitheringScope) ? (1 / _local20) : 0;
            var _local31:Number = (1.000001 / _local15);
            var _local32:Number = (1.000001 / _local14);
            var _local33:uint = m_randNumber.length;
            var _local34:uint = _local6.length;
            _local35 = 0;
            while (_local35 < _local12) {
                _local8[_local10] = this.m_bindDestPoses[_local35];
                _local10++;
                _local35++;
                _local8[_local10] = this.m_bindDestPoses[_local35];
                _local10++;
                _local35++;
                _local8[_local10] = this.m_bindDestPoses[_local35];
                _local10++;
                _local35++;
                _local8[_local10] = this.m_bindDestPoses[_local35];
                _local10++;
                _local35++;
            };
            _local35 = 0;
            _local37 = (_local11 + 3);
            while (_local35 < _local33) {
                _local8[_local37] = m_randNumber[_local35];
                _local35++;
                _local37 = (_local37 + 4);
            };
            _local35 = 0;
            _local37 = _local11;
            while (_local35 < _local34) {
                _local8[_local37] = _local6[_local35];
                _local37++;
                _local35++;
                _local8[_local37] = _local6[_local35];
                _local37 = (_local37 + 3);
                _local35++;
            };
            _local35 = 0;
            _local37 = (_local11 + 2);
            while (_local35 < 50) {
                _local8[_local37] = _local7[_local35];
                _local35++;
                _local37 = (_local37 + 4);
            };
            if (_local3.m_widthAsTexU){
                _local8[_local9] = (_local3.m_invertTexU) ? -1 : 1;
                _local9 = (_local9 + 5);
                _local8[_local9] = (_local3.m_invertTexV) ? -1 : 1;
                _local9 = (_local9 + 1);
                _local8[_local9] = (_local3.m_invertTexV) ? -(this.m_curTextureAdd) : this.m_curTextureAdd;
            } else {
                _local9++;
                _local8[_local9] = (_local3.m_invertTexU) ? -1 : 1;
                _local9 = (_local9 + 3);
                _local8[_local9] = (_local3.m_invertTexV) ? -1 : 1;
                _local9 = (_local9 - 2);
                _local8[_local9] = (_local3.m_invertTexU) ? -(this.m_curTextureAdd) : this.m_curTextureAdd;
            };
            activatePass(_arg1, _arg2);
            setDisturbState(_arg1);
            m_shaderProgram.setSampleTexture(0, m_textureProxy.getTextureForContext(_arg1));
            m_shaderProgram.setSampleTexture(1, _local4);
            m_shaderProgram.setParamValue(DeltaXProgram3D.DIFFUSEMATERIAL, _local31, _local32, _local3.m_chainCount, m_curAlpha);
            m_shaderProgram.setParamValue(DeltaXProgram3D.EMISSIVEMATERIAL, (this.m_preScalePercent * _local26), (this.m_curScalePercent * _local26), _local19, _local21);
            m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARMATERIAL, _local23, _local24, (this.m_percent * _local26), ((_local22 * (_local14 - 1)) * _local32));
            m_shaderProgram.setParamValue(DeltaXProgram3D.SPECULARPOWER, _local5.x, _local5.y, _local5.z, _local3.m_chainWidth);
            m_shaderProgram.setParamValue(DeltaXProgram3D.BASEBRIGHTNESS, _local28, _local27, _local29, _local30);
            m_shaderProgram.update(_arg1);
            DeltaXSubGeometryManager.Instance.drawPackRect(_arg1, _local18);
            deactivatePass(_arg1);
			renderCoordinate(_arg1);
        }
        override protected function get worldMatrixForRender():Matrix3D{
            return (MathUtl.IDENTITY_MATRIX3D);
        }
        override protected function get shaderType():uint{
            return (ShaderManager.SHADER_POLYCHAIN_NORMAL);
        }
        private function makeDestPosAll(_arg1:Dictionary, _arg2:PolygonChainData, _arg3:Vector3D):void{
            var _local6:Matrix3D;
            var _local12:EffectUnit;
            var _local4:Number = (_arg2.m_maxBindRange * _arg2.m_maxBindRange);
            var _local5:uint;
            var _local7:Vector3D = MathUtl.TEMP_VECTOR3D2;
            var _local8:Vector3D = MathUtl.TEMP_VECTOR3D3;
            var _local9:Function = m_destPosGenerateCompareFunctions[_arg2.m_bindType];
            var _local10:LinkableRenderable = ((_arg2.m_bindType == PolyChainBindType.ONLY_SELF_PARENT)) ? this.effect.parentLinkObject : this.effect;
            var _local11:Number = (_arg2.m_fitScale / _arg2.m_chainNodeCount);
            for each (_local12 in _arg1) {
                if (((!((this == _local12))) && (_local9(_local10, _local12)))){
                    _local6 = _local12.worldMatrix;
                    _local6.copyColumnTo(3, _local7);
                    _local8.copyFrom(_local7);
                    _local7.decrementBy(_arg3);
                    if (_local7.lengthSquared < _local4){
                        this.m_bindDestPoses[_local5] = _local7.x;
                        _local5++;
                        this.m_bindDestPoses[_local5] = _local7.y;
                        _local5++;
                        this.m_bindDestPoses[_local5] = _local7.z;
                        _local5++;
                        if (_arg2.m_textureType == PolyChainTextureType.FILLSIZE){
                            this.m_bindDestPoses[_local5] = (_local7.length * _local11);
                        } else {
                            if (_arg2.m_textureType == PolyChainTextureType.STRETCH){
                                this.m_bindDestPoses[_local5] = 1;
                            } else {
                                this.m_bindDestPoses[_local5] = _arg2.m_chainNodeCount;
                            };
                        };
                        _local5++;
                    };
                };
                if (_local5 >= MAX_BIND_POS_COUNT_4X){
                    break;
                };
            };
            this.m_bindDestPoses.length = _local5;
        }

    }
}

class DitheringBiasPair {

    public var first:Number = 0;
    public var second:Number = 0;

    public function DitheringBiasPair(){
    }
    public function copyFrom(_arg1:DitheringBiasPair):void{
        this.first = _arg1.first;
        this.second = _arg1.second;
    }

}
