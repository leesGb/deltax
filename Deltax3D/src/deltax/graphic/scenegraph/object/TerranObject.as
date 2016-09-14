//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.scenegraph.object {
    import deltax.graphic.map.*;
    import flash.geom.*;
    import __AS3__.vec.*;
    import deltax.graphic.material.*;
    import deltax.graphic.scenegraph.partition.*;
    import deltax.graphic.model.*;
    import deltax.common.math.*;
    import deltax.common.resource.*;
    import deltax.*;

    public class TerranObject extends RenderObject {

        private static var TEMP_AABBPOINTS:Vector.<Number> = new Vector.<Number>();
;

        private var m_modelInfo:RegionModelInfo;
        private var m_metaRegion:MetaRegion;

        public function TerranObject(_arg1:MaterialBase=null, _arg2:Geometry=null){
            super(_arg1, _arg2);
            m_selectable = false;
            m_movable = false;
        }
        public function create(_arg1:MetaRegion, _arg2:RegionModelInfo, _arg3:TerrainTileSetUnit):void{
            var _local4:ObjectCreateParams;
            var _local5:uint = _arg3.PartCount;
            var _local6:TerranObject = this;
            var _local7:uint;
            while (_local7 < _local5) {
                if (_local7){
                    _local6 = new TerranObject();
                };
                _local4 = _arg3.m_createObjectInfos[_local7];
                _local6.loadObject(_local4, _arg1, _arg2);
                if (_local7){
                    addChild(_local6);
                    _local6.release();
                };
                _arg1.delta::metaScene.addLoadingTerrianObject(_local6);
                _local7++;
            };
        }
        private function loadObject(_arg1:ObjectCreateParams, _arg2:MetaRegion, _arg3:RegionModelInfo):void{
            var _local4:PieceGroup;
            var _local5:String;
            var _local6:ObjectCreateItemInfo;
            this.m_modelInfo = _arg3;
            this.m_metaRegion = _arg2;
            var _local7:uint = _arg1.m_createItemInfos.length;
            var _local8:MetaScene = _arg2.delta::m_metaScene;
            var _local9:String = Enviroment.ResourceRootPath;
            var _local10:uint;
            while (_local10 < _local7) {
                _local6 = _arg1.m_createItemInfos[_local10];
                _local5 = (_local9 + _local8.getDependentResName(_local6.m_itemType, _local6.m_fileNameIndex));
                switch (_local6.m_itemType){
                    case MetaScene.DEPEND_RES_TYPE_MESH:
                        addMesh(_local5, null, uint(_local6.m_param));
                        break;
                    case MetaScene.DEPEND_RES_TYPE_ANI:
                        setAniGroupByName(_local5);
                        setFigure(Vector.<uint>([_arg3.m_figure]), Vector.<Number>([1]));
                        break;
                    case MetaScene.DEPEND_RES_TYPE_EFFECT:
                        addEffect(_local5, String(_local6.m_param), _local10.toString(), RenderObjLinkType.CENTER, false);
                        break;
                };
                _local10++;
            };
            this.castsShadows = ((_arg3.m_flag & RegionModelInfo.FLAG_CAST_SHADOW) > 0);
            this.calTransform(0, 0, 0);
        }
        override protected function onPieceGroupLoaded(_arg1:PieceGroup, _arg2:Boolean):void{
            if (!_arg2){
                return (super.onPieceGroupLoaded(_arg1, _arg2));
            };
            var _local3:Vector3D = _arg1.orgCenter;
            var _local4:Vector3D = _arg1.orgExtension;
            var _local5:Vector3D = _local3.clone();
            _local3.clone().x = (_local5.x - (_local4.x * 0.5));
            _local5.y = (_local5.y - (_local4.y * 0.5));
            _local5.z = (_local5.z - (_local4.z * 0.5));
            this.calTransform(-(_local3.x), -(_local5.y), -(_local3.z));
            invalidateBounds();
            super.onPieceGroupLoaded(_arg1, _arg2);
        }
        override protected function updateBounds():void{
            super.updateBounds();
            this.sceneTransform.transformVectors(_bounds.aabbPoints, TEMP_AABBPOINTS);
            _bounds.fromVertices(TEMP_AABBPOINTS);
        }
        private function calTransform(_arg1:Number, _arg2:Number, _arg3:Number):void{
            var _local4:Matrix3D = MathUtl.TEMP_MATRIX3D2;
            _local4.identity();
            _local4.appendTranslation(_arg1, _arg2, _arg3);
            var _local5:Number = 1;
            if ((this.m_modelInfo.m_flag & RegionModelInfo.FLAG_UNIFORM_SCALE)){
                _local5 = Math.pow(RegionModelInfo.OBJ_SCALE_POW_BASE, this.m_modelInfo.m_uniformScalar);
            };
            if ((this.m_modelInfo.m_flag & RegionModelInfo.FLAG_XMIRROR)){
                _local4.appendScale(-(_local5), _local5, _local5);
            } else {
                _local4.appendScale(_local5, _local5, _local5);
            };
            var _local6:Number = ((Math.PI * 2) / 0x0100);
            _local4.append(Matrix3DUtils.SetRotateZ(MathUtl.TEMP_MATRIX3D, (this.m_modelInfo.m_rotationZ * _local6)));
            _local4.append(Matrix3DUtils.SetRotateX(MathUtl.TEMP_MATRIX3D, (this.m_modelInfo.m_rotationX * _local6)));
            _local4.append(Matrix3DUtils.SetRotateY(MathUtl.TEMP_MATRIX3D, (this.m_modelInfo.m_rotationY * _local6)));
            var _local7:int = ((this.m_modelInfo.m_gridIndex % MapConstants.REGION_SPAN) + this.m_metaRegion.regionLeftBottomGridX);
            var _local8:int = ((this.m_modelInfo.m_gridIndex / MapConstants.REGION_SPAN) + this.m_metaRegion.regionLeftBottomGridZ);
            var _local9:MetaScene = this.m_metaRegion.delta::m_metaScene;
            var _local10:Boolean = _local9.isGridValid((_local7 - 1), (_local8 - 1));
            var _local11:int = (_local10) ? _local9.getGridHeight((_local7 - 1), (_local8 - 1)) : 0;
            var _local12:Number = ((_local7 * MapConstants.GRID_SPAN) + this.m_modelInfo.m_x);
            var _local13:Number = (_local11 + this.m_modelInfo.m_y);
            var _local14:Number = ((_local8 * MapConstants.GRID_SPAN) + this.m_modelInfo.m_z);
            _local4.appendTranslation(_local12, _local13, _local14);
            this.transform = _local4;
        }
        override public function onAniLoaded(_arg1:String):void{
            playAni(_arg1, true, Math.random());
        }
        override public function get materialInfo():RenderObjectMaterialInfo{
            var _local1:RenderObjectMaterialInfo = new RenderObjectMaterialInfo();
            _local1.shadowMask = (0xFF0000 >>> (this.shadowLevel * 8));
            _local1.invertCullMode = !(((this.m_modelInfo.m_flag & RegionModelInfo.FLAG_XMIRROR) == 0));
            _local1.diffuse = this.m_modelInfo.m_diffuse;
            return (_local1);
        }
        public function get shadowLevel():uint{
            return (((this.m_modelInfo.m_flag & 12) >>> 2));
        }
        override protected function createEntityPartitionNode():EntityNode{
            return (new TerrainObjectNode(this));
        }

    }
}//package deltax.graphic.scenegraph.object 
