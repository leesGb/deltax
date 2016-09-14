//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.animation.skeleton {
    import flash.geom.*;
    import deltax.common.math.*;

    public class JointPose {

        private static var UNITY_SCALE:Vector3D = new Vector3D(1, 1, 1);

		public var name : String; // intention is that this should be used only at load time, not in the main loop
		
		public var jointIndex:int;
		
        public var orientation:Quaternion;
        public var translation:Vector3D;
        public var uniformScale:Number = 1;

        public function JointPose(){
            this.orientation = new Quaternion();
            this.translation = new Vector3D();
            super();
        }
        public function toMatrix3D(_arg1:Matrix3D=null):Matrix3D{
            _arg1 = ((_arg1) || (new Matrix3D()));
            this.orientation.toMatrix3D(_arg1);
            if (this.uniformScale != 1){
                _arg1.appendScale(this.uniformScale, this.uniformScale, this.uniformScale);
            };
            _arg1.appendTranslation(this.translation.x, this.translation.y, this.translation.z);
            return (_arg1);
        }
        public function copyFrom(_arg1:JointPose):void{
            var _local2:Quaternion = _arg1.orientation;
            var _local3:Vector3D = _arg1.translation;
            this.orientation.x = _local2.x;
            this.orientation.y = _local2.y;
            this.orientation.z = _local2.z;
            this.orientation.w = _local2.w;
            this.translation.x = _local3.x;
            this.translation.y = _local3.y;
            this.translation.z = _local3.z;
            this.uniformScale = _arg1.uniformScale;
        }

    }
}//package deltax.graphic.animation.skeleton 
