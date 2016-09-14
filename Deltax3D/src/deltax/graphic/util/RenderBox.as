//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.util {
    import deltax.common.*;
    import deltax.common.math.*;
    import deltax.graphic.manager.*;
    import deltax.graphic.scenegraph.object.*;
    import deltax.graphic.shader.*;
    import deltax.graphic.texture.*;
    
    import flash.display3D.*;
    import flash.geom.*;
    import flash.utils.*;

    public class RenderBox {

        private static var m_boudingBox:DeltaXSubGeometry;
        private static var m_emptyTexture:DeltaXTexture;

        public static function Render(_arg1:Context3D, _arg2:Matrix3D, _arg3:Number, _arg4:Number, _arg5:Number, _arg6:Number, _arg7:Number, _arg8:Number,selected:Boolean = false):void{
            var _local11:ByteArray;
            var _local12:ByteArray;
            if (m_boudingBox == null)
			{
                m_emptyTexture = DeltaXTextureManager.instance.createTexture(null);
                m_boudingBox = new DeltaXSubGeometry(((3 * 4) + 4));
                _local11 = new LittleEndianByteArray((m_boudingBox.sizeofVertex * 8));
                _local12 = new LittleEndianByteArray(((12 * 3) * 2));
                _local11.writeFloat(-0.5);
                _local11.writeFloat(-0.5);
                _local11.writeFloat(0.5);
                _local11.writeUnsignedInt(2147483903);
                _local11.writeFloat(-0.5);
                _local11.writeFloat(0.5);
                _local11.writeFloat(0.5);
                _local11.writeUnsignedInt(2147549183);
                _local11.writeFloat(-0.5);
                _local11.writeFloat(-0.5);
                _local11.writeFloat(-0.5);
                _local11.writeUnsignedInt(2147483648);
                _local11.writeFloat(-0.5);
                _local11.writeFloat(0.5);
                _local11.writeFloat(-0.5);
                _local11.writeUnsignedInt(2147548928);
                _local11.writeFloat(0.5);
                _local11.writeFloat(-0.5);
                _local11.writeFloat(0.5);
                _local11.writeUnsignedInt(2164195583);
                _local11.writeFloat(0.5);
                _local11.writeFloat(0.5);
                _local11.writeFloat(0.5);
                _local11.writeUnsignedInt(2164260863);
                _local11.writeFloat(0.5);
                _local11.writeFloat(-0.5);
                _local11.writeFloat(-0.5);
                _local11.writeUnsignedInt(2164195328);
                _local11.writeFloat(0.5);
                _local11.writeFloat(0.5);
                _local11.writeFloat(-0.5);
                _local11.writeUnsignedInt(2164260608);
                _local12.writeShort(0);
                _local12.writeShort(1);
                _local12.writeShort(2);
                _local12.writeShort(2);
                _local12.writeShort(1);
                _local12.writeShort(3);
                _local12.writeShort(4);
                _local12.writeShort(7);
                _local12.writeShort(5);
                _local12.writeShort(4);
                _local12.writeShort(6);
                _local12.writeShort(7);
                _local12.writeShort(2);
                _local12.writeShort(3);
                _local12.writeShort(6);
                _local12.writeShort(6);
                _local12.writeShort(3);
                _local12.writeShort(7);
                _local12.writeShort(3);
                _local12.writeShort(1);
                _local12.writeShort(7);
                _local12.writeShort(7);
                _local12.writeShort(1);
                _local12.writeShort(5);
                _local12.writeShort(4);
                _local12.writeShort(5);
                _local12.writeShort(0);
                _local12.writeShort(0);
                _local12.writeShort(5);
                _local12.writeShort(1);
                _local12.writeShort(0);
                _local12.writeShort(2);
                _local12.writeShort(4);
                _local12.writeShort(4);
                _local12.writeShort(2);
                _local12.writeShort(6);
                m_boudingBox.vertexData = _local11;
                m_boudingBox.indiceData = _local12;
            };
            var shader:DeltaXProgram3D = ShaderManager.instance.getProgram3D(ShaderManager.SHADER_DEBUG);
            _arg1.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            _arg1.setCulling(Context3DTriangleFace.NONE);
            _arg1.setDepthTest(true, Context3DCompareMode.LESS);
            _arg1.setProgram(shader.getProgram3D(_arg1));
            var _local10:Matrix3D = MathUtl.TEMP_MATRIX3D;
            _local10.copyFrom(_arg2);
            _local10.prependTranslation(((_arg6 + _arg3) * 0.5), ((_arg7 + _arg4) * 0.5), ((_arg8 + _arg5) * 0.5));
            _local10.prependScale((_arg6 - _arg3), (_arg7 - _arg4), (_arg8 - _arg5));
			shader.setParamMatrix(DeltaXProgram3D.WORLD, _local10, true);
			shader.update(_arg1);
			shader.setVertexBuffer(_arg1, m_boudingBox.getVertexBuffer(_arg1));
			if(selected)
			{
				_arg1.setVertexBufferAt(1, m_boudingBox.getVertexBuffer(_arg1), 0, Context3DVertexBufferFormat.BYTES_4);
			}
            _arg1.drawTriangles(m_boudingBox.getIndexBuffer(_arg1), 0, m_boudingBox.numTriangles);
			shader.deactivate(_arg1);
        }

    }
}//package deltax.graphic.util 
