package deltax.graphic.animation 
{
    import deltax.*;
    import deltax.common.math.*;
    import deltax.graphic.animation.skeleton.*;
    import deltax.graphic.model.*;
    import deltax.graphic.render.pass.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.shader.*;
    
    import flash.display3D.*;
    import flash.geom.*;
    import flash.utils.*;

    public class EnhanceSkeletonAnimationState extends AnimationStateBase 
	{

        private static const MAX_VERTEX_CONSTANT_REGISTER:Number = 128;

        private static var m_matTemp:Matrix3D = new Matrix3D();
        private static var m_curSkeletalMatrice:Vector.<Matrix3D> = new Vector.<Matrix3D>();
        private static var m_ainimateStack:Vector.<EnhanceSkeletonAnimationNode> = new Vector.<EnhanceSkeletonAnimationNode>();
        private var m_animationGroup:AnimationGroup;
        private var m_animationOnSkeleton:Array;
        private var m_curFrame:uint = 0;
        private var m_curSkeletonFrame:Vector.<uint>;
        private var m_curSkeletonPose:Vector.<Number>;
        private var m_skeletalGlobalMatrices:Vector.<Number>;
        private var m_skeletalRelativeToView:Vector.<Number>;
        private var m_curRenderingMesh:RenderObject;
        private var m_skeletonMask:SkeletonMask;
        private var m_worldViewInvert:Matrix3D;

        public function EnhanceSkeletonAnimationState(_arg1:AnimationGroup):void
		{
            this.m_skeletonMask = new SkeletonMask();
            this.m_worldViewInvert = new Matrix3D();
            this.m_animationGroup = _arg1;
            this.m_animationOnSkeleton = [];
            this.init();
        }
		
        public function get animationOnSkeleton():Array
		{
            return (this.m_animationOnSkeleton);
        }
		
        public function getSkeletonAnimationNode(_arg1:uint):EnhanceSkeletonAnimationNode
		{
            return (EnhanceSkeletonAnimationNode(this.m_animationOnSkeleton[_arg1]));
        }
		
        public function init():void
		{
            var _local2:int;
            var _local3:int;
            var _local4:uint;
            var _local1:uint = this.m_animationGroup.skeletalCount;
            if (_local1)
			{
                this.m_skeletalGlobalMatrices = new Vector.<Number>((_local1 * 16), true);
                _local2 = 0;
                while (_local2 < _local1) 
				{
                    MathUtl.IDENTITY_MATRIX3D.copyRawDataTo(this.m_skeletalGlobalMatrices, (_local2 * 16));
                    _local2++;
                }
                this.m_skeletalRelativeToView = this.m_skeletalGlobalMatrices.concat();
                _local4 = m_curSkeletalMatrice.length;
                m_curSkeletalMatrice.length = Math.max(_local4, (this.m_skeletalRelativeToView.length / 16));
                _local2 = _local4;
                while (_local2 < m_curSkeletalMatrice.length) 
				{
                    m_curSkeletalMatrice[_local2] = new Matrix3D();
                    _local2++;
                }
                this.m_curSkeletonPose = new Vector.<Number>((_local1 * ((4 + 3) + 1)), true);
                this.m_curSkeletonFrame = new Vector.<uint>(_local1, true);
            }
        }
		
        public function get worldViewInvert():Matrix3D
		{
            return (this.m_worldViewInvert);
        }
		
        public function get animationGroup():AnimationGroup
		{
            return (this.m_animationGroup);
        }
		
        override public function clone():AnimationStateBase
		{
            return (new EnhanceSkeletonAnimationState(this.m_animationGroup));
        }
		
        public function updateSkeletonMask():void
		{
            this.m_skeletonMask.Clear();
        }
		
        public function updatePose(_arg1:Matrix3D, _arg2:RenderObject=null):void
		{
            this.m_worldViewInvert.copyFrom(_arg1);
            this.m_worldViewInvert.invert();
            if (_arg2)
			{
                this.m_curRenderingMesh = _arg2;
            }
            if (this.m_curRenderingMesh)
			{
                this.calcSkeletalMatrices(_arg1);
            }
            _stateInvalid = false;
        }
		
        delta function forceInvalidState():void
		{
            _stateInvalid = true;
        }
		
        private function calcSkeletalMatrices(_arg1:Matrix3D):void
		{
            var _local2:uint;
            var _local5:Vector.<SubGeometry>;
            var _local6:EnhanceSkinnedSubGeometry;
            var _local7:ByteArray;
            var _local8:uint;
            var _local9:Skeletal;
            var _local10:int;
            var _local11:uint;
            var _local12:uint;
            var _local13:uint;
            var _local14:uint;
            var _local15:EnhanceSkeletonAnimationNode;
            if (!this.m_skeletonMask.HaveSkeletal(0))
			{
                this.m_skeletonMask.Add(0);
                if (!this.m_animationGroup)
				{
                    return;
                }
                _local5 = this.m_curRenderingMesh.geometry.subGeometries;
                _local2 = 0;
                while (_local2 < _local5.length) 
				{
                    _local6 = EnhanceSkinnedSubGeometry(_local5[_local2]);
                    _local7 = _local6.associatePiece.local2GlobalIndex;
                    _local8 = 0;
                    while (_local8 < _local7.length) 
					{
                        this.m_skeletonMask.Add(_local7[_local8]);
                        _local8++;
                    }
                    _local2++;
                }
                _local2 = 1;
                while (_local2 < 0x0100) 
				{
                    if (!this.m_skeletonMask.HaveSkeletal(_local2))
					{
						//
                    } else 
					{
                        _local9 = this.m_animationGroup.getSkeletalByID(_local2);
                        if (_local9 == null)
						{
							//
                        } else 
						{
                            _local10 = _local9.m_parentID;
                            while (((((_local10 != 0))) && (!(this.m_skeletonMask.HaveSkeletal(_local10))))) 
							{
                                this.m_skeletonMask.Add(_local10);
                                _local10 = this.m_animationGroup.getSkeletalByID(_local10).m_parentID;
                            }
                        }
                    }
                    _local2++;
                }
            }
            this.m_curFrame++; //by hmh 貌似没什么用
            var _local3:Vector.<uint> = this.m_animationGroup.skeletonInfoforCalculate;
            m_ainimateStack[0] = this.getSkeletonAnimationNode(0);
            this.calcCurrentSkeletal(m_ainimateStack[0], 0, _arg1);
            var _local4:uint = _local3.length;
            _local2 = 1;
			//trace("calcSkeletalMatrices===========================" + this.m_animationGroup.name)
            while (_local2 < _local4) 
			{//本地矩阵转换为全局矩阵？，跟父骨计算
                _local11 = _local3[_local2];
                _local12 = (_local11 & 0xFF);//本骨骼索引
                if (!this.m_skeletonMask.HaveSkeletal(_local12))
				{
					//
                } else 
				{
                    _local13 = ((_local11 >>> 8) & 0xFF);//父骨骼索引
                    _local14 = (_local11 >>> 16);//id
					//trace(","+_local14 + ":" +  _local12 + "--parent-->" + _local13);
                    _local15 = this.m_animationOnSkeleton[_local12];
                    if (_local15 == null)
					{
                        _local15 = m_ainimateStack[(_local14 - 1)];
                    }
                    m_ainimateStack[_local14] = _local15;
                    this.calcCurrentSkeletal(_local15, _local12, m_curSkeletalMatrice[_local13]);
                }
                _local2++;
            }
            if (this.m_curRenderingMesh)
			{
                this.m_curRenderingMesh.onSkeletonUpdated();
            }
            _local4 = m_ainimateStack.length;
            _local2 = 0;
            while (_local2 < _local4) 
			{
                m_ainimateStack[_local2] = null;
                _local2++;
            }
        }
		
        private function calcCurrentSkeletal(_arg1:EnhanceSkeletonAnimationNode, _arg2:uint, _arg3:Matrix3D):void 
		{
            var _local6:uint;
            var _local7:Vector3D;
            var _local8:Matrix3D;
            var _local9:uint;
            var _local10:uint;
            var _local11:uint;
            var _local12:JointPose;
            var _local13:Matrix3D;
            var _local14:Vector3D;
            var _local15:Number;
            var _local16:uint;
            var _local17:Quaternion;
            var _local18:Quaternion;
            var _local19:Number;
            var _local4:uint = (_arg2 << 4);
            var _local5:FigureUnit = this.m_curRenderingMesh.getCurFigureUnit(_arg2);
            this.m_curSkeletonFrame[_arg2] = this.m_curFrame;
			//对全局的矩阵变化进行计算
            if ((((_arg2 == 0)) || ((_arg1 == null)))) 
			{
                _local8 = m_curSkeletalMatrice[_arg2];
                _local8.identity();
                if (_local5)
				{
                    _local7 = _local5.m_scale;
                    _local8.appendScale(_local7.x, _local7.y, _local7.z);
                }
				
				if(_arg1)
				{
					_local11 = uint(_arg1.m_frameOrWeight);//第几帧
					_arg1.m_animation.fillSkeletonMatrix(_local11, _arg2, _local8);		
				}
				
                _local8.append(_arg3);
                _local8.copyRawDataTo(this.m_skeletalRelativeToView, _local4);
                _local8.copyRawDataTo(this.m_skeletalGlobalMatrices, _local4, true);
                return;
            }
            _local13 = m_curSkeletalMatrice[_arg2];//本骨骼的矩阵
			//_arg1.m_frameOrWeight = 0; //by hmh
            if (_arg1.m_frameOrWeight >= 0)
			{
                _local11 = uint(_arg1.m_frameOrWeight);//第几帧
                _local15 = _arg1.m_animation.fillSkeletonMatrix(_local11, _arg2, _local13);
            } else 
			{
                _local16 = (_arg2 * 8);
                _local14 = MathUtl.TEMP_VECTOR3D;
                _local17 = MathUtl.TEMP_QUATERNION;
                _local18 = MathUtl.TEMP_QUATERNION2;
                _local15 = _arg1.m_animation.fillSkeletonPose(_arg1.m_initFrame, _arg2, _local14, _local18);
                _local19 = -(_arg1.m_frameOrWeight);
                var _temp1 = _local16;
                _local16 = (_local16 + 1);
                _local17.x = this.m_curSkeletonPose[_temp1];
                var _temp2 = _local16;
                _local16 = (_local16 + 1);
                _local17.y = this.m_curSkeletonPose[_temp2];
                var _temp3 = _local16;
                _local16 = (_local16 + 1);
                _local17.z = this.m_curSkeletonPose[_temp3];
                var _temp4 = _local16;
                _local16 = (_local16 + 1);
                _local17.w = this.m_curSkeletonPose[_temp4];
                _local17.slerp(_local18, _local17, _local19);
                var _temp5 = _local16;
                _local16 = (_local16 + 1);
                _local14.x = (_local14.x + (_local19 * (this.m_curSkeletonPose[_temp5] - _local14.x)));
                var _temp6 = _local16;
                _local16 = (_local16 + 1);
                _local14.y = (_local14.y + (_local19 * (this.m_curSkeletonPose[_temp6] - _local14.y)));
                var _temp7 = _local16;
                _local16 = (_local16 + 1);
                _local14.z = (_local14.z + (_local19 * (this.m_curSkeletonPose[_temp7] - _local14.z)));
                _local15 = (_local15 + (_local19 * (this.m_curSkeletonPose[_local16] - _local15)));
                _local16 = (_local16 - 7);
                var _temp8 = _local16;
                _local16 = (_local16 + 1);
                var _local20 = _temp8;
                this.m_curSkeletonPose[_local20] = _local17.x;
                var _temp9 = _local16;
                _local16 = (_local16 + 1);
                var _local21 = _temp9;
                this.m_curSkeletonPose[_local21] = _local17.y;
                var _temp10 = _local16;
                _local16 = (_local16 + 1);
                var _local22 = _temp10;
                this.m_curSkeletonPose[_local22] = _local17.z;
                var _temp11 = _local16;
                _local16 = (_local16 + 1);
                var _local23 = _temp11;
                this.m_curSkeletonPose[_local23] = _local17.w;
                var _temp12 = _local16;
                _local16 = (_local16 + 1);
                var _local24 = _temp12;
                this.m_curSkeletonPose[_local24] = _local14.x;
                var _temp13 = _local16;
                _local16 = (_local16 + 1);
                var _local25 = _temp13;
                this.m_curSkeletonPose[_local25] = _local14.y;
                var _temp14 = _local16;
                _local16 = (_local16 + 1);
                var _local26 = _temp14;
                this.m_curSkeletonPose[_local26] = _local14.z;
                this.m_curSkeletonPose[_local16] = _local15;
                _local17.toMatrix3D(_local13);
                _local13.appendTranslation(_local14.x, _local14.y, _local14.z);
            }
			
            if (_local5)
			{
                _local14 = _local5.m_offset;
                _local13.appendTranslation(_local14.x, _local14.y, _local14.z);
                _local13.append(_arg3);// append parent 
                m_matTemp.copyFrom(_local13);
                _local7 = MathUtl.TEMP_VECTOR3D;
                _local7.copyFrom(_local5.m_scale);
                _local7.scaleBy(_local15);
                m_matTemp.prependScale(_local7.x, _local7.y, _local7.z);
            } else 
			{
                _local13.append(_arg3);
                m_matTemp.copyFrom(_local13);
                m_matTemp.prependScale(_local15, _local15, _local15);
            }
            m_matTemp.copyRawDataTo(this.m_skeletalRelativeToView, _local4, false);
			m_matTemp.prepend(this.m_animationGroup.m_gammaSkeletals[_arg2].m_inverseBindPose);
            m_matTemp.copyRawDataTo(this.m_skeletalGlobalMatrices, _local4, true);
        }
		
        public function initBlendInfo(_arg1:uint, _arg2:Animation, _arg3:uint):void
		{
            var _local4:uint = (_arg1 * 8);
            var _local5:Vector3D = MathUtl.TEMP_VECTOR3D;
            var _local6:Quaternion = MathUtl.TEMP_QUATERNION;
            var _local7:Number = _arg2.fillSkeletonPose(_arg3, _arg1, _local5, _local6);
            var _temp1 = _local4;
            _local4 = (_local4 + 1);
            var _local10 = _temp1;
            this.m_curSkeletonPose[_local10] = _local6.x;
            var _temp2 = _local4;
            _local4 = (_local4 + 1);
            var _local11 = _temp2;
            this.m_curSkeletonPose[_local11] = _local6.y;
            var _temp3 = _local4;
            _local4 = (_local4 + 1);
            var _local12 = _temp3;
            this.m_curSkeletonPose[_local12] = _local6.z;
            var _temp4 = _local4;
            _local4 = (_local4 + 1);
            var _local13 = _temp4;
            this.m_curSkeletonPose[_local13] = _local6.w;
            var _temp5 = _local4;
            _local4 = (_local4 + 1);
            var _local14 = _temp5;
            this.m_curSkeletonPose[_local14] = _local5.x;
            var _temp6 = _local4;
            _local4 = (_local4 + 1);
            var _local15 = _temp6;
            this.m_curSkeletonPose[_local15] = _local5.y;
            var _temp7 = _local4;
            _local4 = (_local4 + 1);
            var _local16 = _temp7;
            this.m_curSkeletonPose[_local16] = _local5.z;
            this.m_curSkeletonPose[_local4] = _local7;
            var _local8:Vector.<uint> = this.m_animationGroup.getSkeletalByID(_arg1).m_childIds;
            var _local9:uint;
            while (((_local8) && ((_local9 < _local8.length)))) 
			{
                this.initBlendInfo(_local8[_local9], _arg2, _arg3);
                _local9++;
            }
        }
		
        public function copySkeletalRelativeToLocalMatrix(_arg1:uint, _arg2:Matrix3D):void
		{
            var _local3:Vector.<uint>;
            var _local4:int;
            var _local5:int;
            var _local6:EnhanceSkeletonAnimationNode;
            var _local7:int;
            var _local8:uint;
            if (((this.m_animationGroup) && (!((this.m_curSkeletonFrame[_arg1] == this.m_curFrame)))))
			{
                _local3 = new Vector.<uint>();
                _local4 = _arg1;
                do  
				{
                    _local3.push(_local4);
                    _local4 = this.m_animationGroup.getSkeletalByID(_local4).m_parentID;
                } 
				while (((_local4>=0) && (!((this.m_curSkeletonFrame[_local4] == this.m_curFrame)))));
                _local5 = _local4;
                _local6 = this.m_animationOnSkeleton[_local5];
                while ((((_local6 == null)) && (_local5))) 
				{//_local50的时候就退出了
                    _local5 = this.m_animationGroup.getSkeletalByID(_local5).m_parentID;
                    _local6 = this.m_animationOnSkeleton[_local5];
                }
                _local7 = (_local3.length - 1);
                while (_local7 >= 0 && _local4>=0) 
				{
                    _local8 = _local3[_local7];
                    if (this.m_animationOnSkeleton[_local8])
					{
                        _local6 = this.m_animationOnSkeleton[_local8];
                    }
                    this.calcCurrentSkeletal(_local6, _local8, m_curSkeletalMatrice[_local4]);
                    _local4 = _local8;
                    _local7--;
                }
            }
            _arg2.copyRawDataFrom(this.m_skeletalRelativeToView, (_arg1 * 16), false);
            _arg2.append(this.worldViewInvert);
        }
		
        override public function setRenderState(_arg1:Context3D, _arg2:MaterialPassBase, _arg3:IRenderable):void
		{
			//
        }
		
        public function setEnhanceRenderState(context3d:Context3D, material:MaterialPassBase, subMesh:IRenderable):void
		{
            var skeletalIndex:uint;
            var vertexIndex:uint;
            var skeletalCount:uint = this.m_animationGroup.skeletalCount;
            if (this.m_skeletalGlobalMatrices.length == 0)
			{
                if (skeletalCount > 0)
				{
                    this.init();
                } else 
				{
                    return;
                }
            }
            var eSubGeometry:EnhanceSkinnedSubGeometry = EnhanceSkinnedSubGeometry(SubMesh(subMesh).subGeometry);
            var sourceEntity:RenderObject = (SubMesh(subMesh).sourceEntity as RenderObject);
            this.m_curRenderingMesh = sourceEntity;
            var program3d:DeltaXProgram3D = SkinnedMeshPass(material).program3D;
            var vParamRsterStartIndex:int = (program3d.getVertexParamRegisterStartIndex(DeltaXProgram3D.WORLDVIEW) << 4);
            var vParamRsterCount:int = program3d.getVertexParamRegisterCount(DeltaXProgram3D.WORLDVIEW);
            var vParamCacheList:Vector.<Number> = program3d.getVertexParamCache();
            var indexData:ByteArray = eSubGeometry.associatePiece.local2GlobalIndex;
            var dataLength:uint = indexData.length;
            var startIndex:uint = vParamRsterStartIndex;
            var dataIndex:uint;
            while (dataIndex < dataLength) 
			{
				skeletalIndex = indexData[dataIndex];
                if (skeletalIndex >= skeletalCount)
				{
					skeletalIndex = MathUtl.max(0, (skeletalCount - 1));
                }
				skeletalIndex = (skeletalIndex << 4);
				vertexIndex = 0;
                while (vertexIndex < 12) 
				{
					vParamCacheList[startIndex++] = this.m_skeletalGlobalMatrices[(skeletalIndex + vertexIndex)];
					vertexIndex++;
                }
				dataIndex++;
            }
        }

    }
}