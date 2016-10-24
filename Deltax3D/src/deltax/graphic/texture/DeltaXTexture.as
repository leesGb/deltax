//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.graphic.texture {
    import deltax.common.debug.*;
    import flash.display3D.*;
    import deltax.graphic.manager.*;
    import deltax.common.*;
    import __AS3__.vec.*;
    import flash.utils.*;
    import flash.display3D.textures.*;

    public class DeltaXTexture implements ReferencedObject {

        protected var m_name:String;
        protected var m_refCount:uint = 1;
        protected var m_bitmapData:Object;
        protected var m_width:uint;
        protected var m_height:uint;
        protected var m_texture:Object;
        protected var m_preUseTime:int;

        public function DeltaXTexture(_arg1, _arg2:String){
            var _local3:BitmapDataResource3D;
            super();
            ObjectCounter.add(this);
            this.m_name = _arg2;
            this.m_texture = null;
            if (this.m_name == null){
                throw (new Error("can not create texture without name."));
            };
            if ((((_arg1 is Vector.<BitmapMergeInfo>)) && ((Vector.<BitmapMergeInfo>(_arg1)[0].bitmapResName == _arg2)))){
                _arg1 = Vector.<BitmapMergeInfo>(_arg1)[0].bitmapResName;
            };
            if ((_arg1 is BitmapDataResource3D)){
                _local3 = BitmapDataResource3D(_arg1);
                if (((!(_local3.bitmapData)) && (((_local3.loaded) || (_local3.loadfailed))))){
                    _local3 = BitmapDataResource3D.DEFAULT_BITMAP_RESOURCE;
                };
                _local3.reference();
                this.m_bitmapData = _local3;
                this.m_width = _local3.width;
                this.m_height = _local3.height;
                return;
            };
            this.m_width = 0;
            this.m_height = 0;
            if ((_arg1 is String)){
                this.m_bitmapData = ResourceManager.instance.getResource(String(_arg1), ResourceType.TEXTURE3D, null);
                return;
            };
            if (!(_arg1 is Vector.<BitmapMergeInfo>)){
                throw (new Error("new DeltaXTexture with invalid bitmapInfo."));
            };
            this.m_bitmapData = _arg1;
        }
        public function get bitmapData():ByteArray{
            if ((this.m_bitmapData is ByteArray)){
                return (ByteArray(this.m_bitmapData));
            };
            if ((this.m_bitmapData is BitmapDataResource3D)){
                return (BitmapDataResource3D(this.m_bitmapData).bitmapData);
            };
            return (null);
        }
        public function get isLoaded():Boolean{
            return ((this.m_texture is Texture));
        }
        public function get preUseTime():int{
            return (this.m_preUseTime);
        }
        public function get name():String{
            return (this.m_name);
        }
        public function get width():uint{
            return (this.m_width);
        }
        public function get height():uint{
            return (this.m_height);
        }
        public function reference():void{
            this.m_refCount++;
        }
        public function dispose():void{
        }
        public function release():void{
            if (--this.m_refCount){
                return;
            };
            this.freeTexture();
            DeltaXTextureManager.instance.unregisterTexture(this);
            if ((this.m_bitmapData is ByteArray)){
                TextureMemoryManager.Instance.free(ByteArray(this.m_bitmapData));
            } else {
                if ((this.m_bitmapData is GenerateBitmapDataStep)){
                    GenerateBitmapDataStep(this.m_bitmapData).free();
                } else {
                    if ((this.m_bitmapData is BitmapDataResource3D)){
                        BitmapDataResource3D(this.m_bitmapData).release();
                    };
                };
            };
            this.m_bitmapData = null;
        }
        public function get refCount():uint{
            return (this.m_refCount);
        }
        private function generateMipMaps(_arg1:Context3D):Boolean{
            if (this.m_texture == null){
                this.m_texture = new GenerateMipMapStep(_arg1, this.bitmapData, this.width, this.height);
            };
            var _local2:uint = DeltaXTextureManager.instance.getRemainTime(this);
            var _local3:Texture = GenerateMipMapStep(this.m_texture).downSample(_local2);
            if (!_local3){
                return (false);
            };
            this.m_texture = _local3;
            return (true);
        }
        private function generateBitmapData():Boolean{
            if ((this.m_bitmapData is ByteArray)){
                return (true);
            };
            if ((this.m_bitmapData is BitmapDataResource3D)){
                if (BitmapDataResource3D(this.m_bitmapData).loadfailed){
                    this.m_bitmapData.release();
                    this.m_bitmapData = BitmapDataResource3D.DEFAULT_BITMAP_RESOURCE;
                };
                if (BitmapDataResource3D(this.m_bitmapData).loaded){
                    this.m_width = BitmapDataResource3D(this.m_bitmapData).width;
                    this.m_height = BitmapDataResource3D(this.m_bitmapData).height;
                    return (true);
                };
                return (false);
            };
            if (!(this.m_bitmapData is GenerateBitmapDataStep)){
                this.m_bitmapData = new GenerateBitmapDataStep(Vector.<BitmapMergeInfo>(this.m_bitmapData), this.width, this.height);
            };
            var _local1:GenerateBitmapDataStep = GenerateBitmapDataStep(this.m_bitmapData);
            var _local2:uint = DeltaXTextureManager.instance.getRemainTime(this);
            var _local3:Object = _local1.Merge(_local2);
            if (!_local3){
                return (false);
            };
            this.m_bitmapData = _local3;
            this.m_width = _local1.width;
            this.m_height = _local1.height;
            return (true);
        }
        public function getTextureForContext(_arg1:Context3D):Texture{
            var _local2:Boolean;
            this.m_preUseTime = getTimer();
            if (!(this.m_texture is Texture)) {
                if (!this.m_bitmapData){
                    return (DeltaXTextureManager.defaultTexture3D);
                };
                DeltaXTextureManager.instance.checkUsage();
                if (!DeltaXTextureManager.instance.textureCreateBegin(this)){
                    return (DeltaXTextureManager.defaultTexture3D);
                };
                _local2 = this.generateBitmapData();
                if (!_local2){
                    DeltaXTextureManager.instance.textureCreateEnd(this);
                    return (DeltaXTextureManager.defaultTexture3D);
                };
                _local2 = this.generateMipMaps(_arg1);
                if (!_local2){
                    DeltaXTextureManager.instance.textureCreateEnd(this);
                    return (DeltaXTextureManager.defaultTexture3D);
                };
                DeltaXTextureManager.instance.textureCreateEnd(this);
				//trace("create_texture_b:" + this.name);
            };
            return (Texture(this.m_texture));
        }
        public function onLostDevice():void{
            this.freeTexture();
        }
        public function freeTexture():void{
            if (!this.m_texture){
                return;
            };
            if ((this.m_texture is GenerateMipMapStep)){
                if (this.m_refCount != 0){
                    return;
                };
                GenerateMipMapStep(this.m_texture).free();
                this.m_texture = null;
                return;
            };
            DeltaXTextureManager.instance.decrease3DTextureCount((((this.width * this.height) * 4) * 1.4));
            this.m_texture.dispose();
            this.m_texture = null;
        }

    }
}//package deltax.graphic.texture 

import flash.display3D.*;
import deltax.graphic.manager.*;
import flash.geom.*;
import __AS3__.vec.*;
import flash.utils.*;
import flash.display3D.textures.*;

class TextureMergeInfo {

    public var textureRange:Rectangle;
    public var bitmapResource:BitmapDataResource3D;

    public function TextureMergeInfo(){
    }
}

import deltax.graphic.texture.*;
class GenerateBitmapDataStep {

    private var m_bitmapGroup:Vector.<TextureMergeInfo>;
    private var m_mergeRect:Vector.<Rectangle>;
    private var m_mergeData:Object;
    private var m_curIndex:uint;
    private var m_lineDes:uint;
    private var m_width:uint;
    private var m_height:uint;
    private var m_needBlend:Boolean;
    private var m_curMergeRect:Rectangle;
    private var m_loadedTextureCount:uint;

    public function GenerateBitmapDataStep(_arg1:Vector.<BitmapMergeInfo>, _arg2:uint, _arg3:uint){
        var _local5:BitmapDataResource3D;
        this.m_mergeRect = new Vector.<Rectangle>();
        super();
        this.m_bitmapGroup = new Vector.<TextureMergeInfo>(_arg1.length, true);
        var _local4:int;
        while (_local4 < this.m_bitmapGroup.length) {
            _local5 = (ResourceManager.instance.getResource(_arg1[_local4].bitmapResName, ResourceType.TEXTURE3D, this.onTextureLoad) as BitmapDataResource3D);
            if (!_local5){
                _arg1.length--;
                _local4--;
            } else {
                this.m_bitmapGroup[_local4] = new TextureMergeInfo();
                this.m_bitmapGroup[_local4].textureRange = _arg1[_local4].textureRange;
                this.m_bitmapGroup[_local4].bitmapResource = _local5;
                this.m_bitmapGroup[_local4].bitmapResource.reference();
            };
            _local4++;
        };
        this.m_width = 0;
        this.m_height = 0;
        this.m_curIndex = 0;
        this.m_lineDes = 0;
        this.m_curMergeRect = null;
        this.m_mergeData = null;
        this.m_loadedTextureCount = 0;
    }
    public function get width():uint{
        return (this.m_width);
    }
    public function get height():uint{
        return (this.m_height);
    }
    private function onTextureLoad(_arg1:IResource, _arg2:Boolean):void{
        _arg1.release();
        if (this.m_bitmapGroup == null){
            return;
        };
		trace("onTextureLoad:" + _arg1.name);
        var _local3 = -1;
        var _local4:int;
        while ((((_local3 < 0)) && ((_local4 < this.m_bitmapGroup.length)))) {
            if (this.m_bitmapGroup[_local4].bitmapResource == _arg1){
                _local3 = _local4;
            };
            _local4++;
        };
        if (_local3 < 0){
            throw (new Error("onTextureLoad with invalid resource"));
        };
        if (!_arg2){
            this.m_bitmapGroup.splice(_local3, 1);
        } else {
            this.m_loadedTextureCount++;
            this.m_width = Math.max(this.m_bitmapGroup[_local3].bitmapResource.width, this.m_width);
            this.m_height = Math.max(this.m_bitmapGroup[_local3].bitmapResource.height, this.m_height);
        };
        if (this.m_loadedTextureCount == this.m_bitmapGroup.length){
            if (this.m_loadedTextureCount == 0){
                this.m_mergeData = BitmapDataResource3D.DEFAULT_BITMAP_RESOURCE;
            } else {
                if (this.m_loadedTextureCount == 1){
                    this.m_mergeData = this.m_bitmapGroup[0].bitmapResource;
                } else {
                    this.m_mergeData = TextureMemoryManager.Instance.alloc(((this.m_width * this.m_height) * 4));
                };
            };
        };
    }
    public function free():void{
        if (((this.m_mergeData) && ((this.m_mergeData is ByteArray)))){
            TextureMemoryManager.Instance.free(ByteArray(this.m_mergeData));
        };
        var _local1:uint;
        while (_local1 < this.m_bitmapGroup.length) {
            this.m_bitmapGroup[_local1].bitmapResource.release();
            _local1++;
        };
        this.m_bitmapGroup = null;
        this.m_mergeRect = null;
    }
    public function Merge(_arg1:uint):Object{
        var _local5:TextureMergeInfo;
        var _local6:uint;
        var _local7:uint;
        var _local8:uint;
        var _local9:uint;
        var _local10:uint;
        var _local11:uint;
        var _local12:uint;
        if (this.m_mergeData == null){
            return (null);
        };
        if ((this.m_mergeData is BitmapDataResource3D)){
            this.m_width = BitmapDataResource3D(this.m_mergeData).width;
            this.m_height = BitmapDataResource3D(this.m_mergeData).height;
            return (this.m_mergeData);
        };
        var _local2:uint = getTimer();
        var _local3:ByteArray = ByteArray(this.m_mergeData);
        while (this.m_curIndex < this.m_bitmapGroup.length) {
            _local5 = this.m_bitmapGroup[this.m_curIndex];
            _local6 = _local5.bitmapResource.width;
            _local7 = _local5.bitmapResource.height;
            _local8 = (Math.floor(((_local5.textureRange.left * this.m_width) / 32)) * 32);
            _local9 = (Math.floor(((_local5.textureRange.top * this.m_height) / 32)) * 32);
            _local10 = (Math.ceil(((_local5.textureRange.right * this.m_width) / 32)) * 32);
            _local11 = (Math.ceil(((_local5.textureRange.bottom * this.m_height) / 32)) * 32);
            if ((((_local10 > _local6)) || ((_local11 > _local7)))){
            } else {
                if (this.m_curMergeRect == null){
                    this.m_needBlend = false;
                    _local12 = 0;
                    while (((!(this.m_needBlend)) && ((_local12 < this.m_mergeRect.length)))) {
                        this.m_curMergeRect = this.m_mergeRect[_local12];
                        this.m_needBlend = (((Math.min(_local10, this.m_curMergeRect.right) > Math.max(_local8, this.m_curMergeRect.left))) && ((Math.min(_local11, this.m_curMergeRect.bottom) > Math.max(_local9, this.m_curMergeRect.top))));
                        _local12++;
                    };
                    this.m_curMergeRect = new Rectangle(_local8, _local9, (_local10 - _local8), (_local11 - _local9));
                    this.m_mergeRect.push(this.m_curMergeRect);
                };
                if (!this.mergeBitmap(_local3, this.m_width, _local5.bitmapResource.bitmapData, _local5.bitmapResource.width, this.m_curMergeRect, this.m_needBlend, _local2, _arg1)){
                    return (null);
                };
                this.m_curMergeRect = null;
                this.m_lineDes = 0;
            };
            this.m_curIndex++;
        };
        var _local4:uint;
        while (_local4 < this.m_bitmapGroup.length) {
            this.m_bitmapGroup[_local4].bitmapResource.release();
            _local4++;
        };
        return (this.m_mergeData);
    }
    private function mergeBitmap(_arg1:ByteArray, _arg2:uint, _arg3:ByteArray, _arg4:uint, _arg5:Rectangle, _arg6:Boolean, _arg7:uint, _arg8:uint):Boolean{
        var _local14:uint;
        var _local15:uint;
        var _local16:uint;
        var _local17:uint;
        var _local18:uint;
        var _local19:uint;
        var _local20:uint;
        var _local21:uint;
        var _local22:uint;
        var _local23:uint;
        var _local9:uint = (((_arg4 * (_arg5.top + this.m_lineDes)) + _arg5.left) * 4);
        var _local10:uint = (((_arg2 * (_arg5.top + this.m_lineDes)) + _arg5.left) * 4);
        var _local11:uint = _arg5.width;
        var _local12:uint = _arg5.height;
        var _local13:uint = (0x2000 / _local11);
        if (_arg6){
            while (this.m_lineDes < _local12) {
                if (((((this.m_lineDes % _local13) == 0)) && (((getTimer() - _arg7) >= _arg8)))){
                    return (false);
                };
                _local14 = _local9;
                _local15 = _local10;
                _local16 = 0;
                while (_local16 < _local11) {
                    _local23 = _arg1[(_local15 + 3)];
                    _local22 = _arg3[(_local14 + 3)];
                    if ((((_local23 == 0)) || ((_local22 == 0xFF)))){
                        _arg1.position = _local15;
                        _arg1.writeBytes(_arg3, _local14, 4);
                        _local14 = (_local14 + 4);
                        _local15 = (_local15 + 4);
                    } else {
                        if (_local22 != 0){
                            _local17 = ((_local22 * _local23) / 0xFF);
                            _local18 = ((_local22 + _local23) - _local17);
                            _local21 = _arg1[_local15];
                            var _temp1 = _local15;
                            _local15 = (_local15 + 1);
                            var _local24 = _temp1;
                            var _temp2 = _local14;
                            _local14 = (_local14 + 1);
                            _arg1[_local24] = ((((_arg3[_temp2] * _local22) + (_local21 * _local23)) - (_local21 * _local17)) / _local18);
                            _local20 = _arg1[_local15];
                            var _temp3 = _local15;
                            _local15 = (_local15 + 1);
                            var _local25 = _temp3;
                            var _temp4 = _local14;
                            _local14 = (_local14 + 1);
                            _arg1[_local25] = ((((_arg3[_temp4] * _local22) + (_local20 * _local23)) - (_local20 * _local17)) / _local18);
                            _local19 = _arg1[_local15];
                            var _temp5 = _local15;
                            _local15 = (_local15 + 1);
                            var _local26 = _temp5;
                            var _temp6 = _local14;
                            _local14 = (_local14 + 1);
                            _arg1[_local26] = ((((_arg3[_temp6] * _local22) + (_local19 * _local23)) - (_local19 * _local17)) / _local18);
                            _local14++;
                            var _temp7 = _local15;
                            _local15 = (_local15 + 1);
                            var _local27 = _temp7;
                            _arg1[_local27] = _local18;
                        } else {
                            _local14 = (_local14 + 4);
                            _local15 = (_local15 + 4);
                        };
                    };
                    _local16++;
                };
                _local9 = (_local9 + (_arg4 * 4));
                _local10 = (_local10 + (_arg2 * 4));
                this.m_lineDes++;
            };
        } else {
            while (this.m_lineDes < _local12) {
                if (((((this.m_lineDes % _local13) == 0)) && (((getTimer() - _arg7) >= _arg8)))){
                    return (false);
                };
                _arg1.position = _local10;
                _arg1.writeBytes(_arg3, _local9, (_local11 * 4));
                _local9 = (_local9 + (_arg4 * 4));
                _local10 = (_local10 + (_arg2 * 4));
                this.m_lineDes++;
            };
        };
        return (true);
    }

}
class GenerateMipMapStep {

    private var m_bitmapDataSrc:ByteArray;
    private var m_bitmapDataDes:ByteArray;
    private var m_widthDes:uint;
    private var m_heightDes:uint;
    private var m_levelDes:uint;
    private var m_lineDes:uint;
    private var m_pixelDes4:uint;
    private var m_texture:Texture;

    public function GenerateMipMapStep(_arg1:Context3D, _arg2:ByteArray, _arg3:uint, _arg4:uint){
        this.m_bitmapDataSrc = _arg2;
        this.m_widthDes = (_arg3 >>> 1);
        this.m_heightDes = (_arg4 >>> 1);
        this.m_levelDes = 1;
        this.m_lineDes = 0;
        this.m_pixelDes4 = 0;
        this.m_texture = _arg1.createTexture(_arg3, _arg4, Context3DTextureFormat.BGRA, false);
        this.m_texture.uploadFromByteArray(_arg2, 0, 0);
        this.m_bitmapDataDes = TextureMemoryManager.Instance.alloc(((this.m_widthDes * this.m_widthDes) * 4));
        DeltaXTextureManager.instance.increase3DTextureCount((((_arg3 * _arg4) * 4) * 1.4));
    }
    public function free():void{
        this.m_texture.dispose();
        TextureMemoryManager.Instance.free(this.m_bitmapDataDes);
        this.m_texture = null;
    }
    public function downSample(_arg1:uint):Texture{
        var _local3:int;
        var _local4:int;
        var _local5:int;
        var _local6:int;
        var _local7:int;
        var _local8:uint;
        var _local9:uint;
        var _local10:int;
        var _local2:uint = getTimer();
        while ((((this.m_widthDes >= 1)) || ((this.m_heightDes >= 1)))) {
            _local3 = Math.max(this.m_widthDes, 1);
            _local4 = Math.max(this.m_heightDes, 1);
            _local5 = Math.max((this.m_widthDes << 1), 1);
            _local6 = (_local5 << 3);
            _local7 = (this.m_heightDes) ? ((_local5 << 2) - 8) : -8;
            _local9 = (0x2000 / _local3);
            while (this.m_lineDes < _local4) {
                if (((((this.m_lineDes) && (((this.m_lineDes % _local9) == 0)))) && (((getTimer() - _local2) >= _arg1)))){
                    return (null);
                };
                _local10 = 0;
                while (_local10 < _local3) {
                    _local8 = 0;
                    this.m_bitmapDataSrc.position = ((this.m_lineDes * _local6) + (_local10 << 3));
                    _local8 = (_local8 + ((this.m_bitmapDataSrc.readUnsignedInt() >>> 2) & 1061109567));
                    if (this.m_widthDes == 0){
                        this.m_bitmapDataSrc.position = (this.m_bitmapDataSrc.position - 4);
                    };
                    _local8 = (_local8 + ((this.m_bitmapDataSrc.readUnsignedInt() >>> 2) & 1061109567));
                    this.m_bitmapDataSrc.position = (this.m_bitmapDataSrc.position + _local7);
                    _local8 = (_local8 + ((this.m_bitmapDataSrc.readUnsignedInt() >>> 2) & 1061109567));
                    if (this.m_widthDes == 0){
                        this.m_bitmapDataSrc.position = (this.m_bitmapDataSrc.position - 4);
                    };
                    _local8 = (_local8 + ((this.m_bitmapDataSrc.readUnsignedInt() >>> 2) & 1061109567));
                    this.m_bitmapDataDes.position = this.m_pixelDes4;
                    this.m_bitmapDataDes.writeUnsignedInt(_local8);
                    _local10++;
                    this.m_pixelDes4 = (this.m_pixelDes4 + 4);
                };
                this.m_lineDes++;
            };
            this.m_texture.uploadFromByteArray(this.m_bitmapDataDes, 0, this.m_levelDes);
            this.m_bitmapDataSrc = this.m_bitmapDataDes;
            this.m_pixelDes4 = 0;
            this.m_lineDes = 0;
            this.m_levelDes++;
            this.m_widthDes = (this.m_widthDes >> 1);
            this.m_heightDes = (this.m_heightDes >> 1);
        };
        TextureMemoryManager.Instance.free(this.m_bitmapDataDes);
        return (this.m_texture);
    }

}
