package deltax.graphic.scenegraph.object 
{
    import flash.geom.Matrix3D;
    import flash.utils.Dictionary;
    
    import deltax.common.ReferencedObject;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.model.FramePair;

	/**
	 * 链接可渲染对象接口
	 * @author lees
	 * @date 2016/03/02
	 */	
	
    public interface LinkableRenderable extends ReferencedObject 
	{
		/***/
        function get equivalentEntity():Entity;
		/***/
		function get worldMatrix():Matrix3D;
		/***/
		function get parentLinkObject():LinkableRenderable;
		/***/
		function get preRenderTime():uint;
		/***/
		function get frameInterval():Number;
		/***/
		function set frameInterval(va:Number):void;
		/***/
        function addLinkObject(va:LinkableRenderable, linkName:String, linkType:uint=0, frameSync:Boolean=false, time:int=-1):void;
		/***/
        function removeLinkObject(linkName:String, linkType:uint=0):void;
		/***/
        function clearLinks(linkType:uint):void;
		/***/
        function getLinkObjects(linkType:uint):Dictionary;
		/***/
        function getLinkObject(linkName:String, linkType:uint):LinkableRenderable;
		/***/
        function checkNodeParent(idx:uint, subIdx:uint):Boolean;
		/***/
        function onLinkedToParent(va:LinkableRenderable, linkName:String, linkType:uint, frameSync:Boolean):void;
		/***/
        function onUnLinkedFromParent(va:LinkableRenderable):void;
		/***/
        function getNodeMatrix(mat:Matrix3D, idx:uint, subIdx:uint):Boolean;
		/***/
        function onParentUpdate(time:uint):void;
		/***/
        function onParentRenderBegin(time:uint):void;
		/***/
        function onParentRenderEnd(time:uint):void;
		/***/
        function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean;
		/***/
        function getLinkIDsByAttachName(attachName:String):Array;
		/***/
        function getNodeCurFrames(frames:Vector.<Number>, ends:Vector.<Boolean>, idxs:Vector.<uint>):void;
		/***/
        function getNodeCurFramePair(idx:uint, fp:FramePair=null):FramePair;
		/***/
        function getNodeCurAniName(idx:uint):String;
		/***/
        function getNodeCurAniIndex(idx:uint):int;
		/***/
        function getNodeCurAniPlayType(idx:uint):uint;
		/***/
        function setNodeAni(aniName:String, idx:uint, fp:FramePair, type:uint=0, time:uint=200, idxs:Vector.<uint>=null, arg:uint=0):void;

    }
} 
