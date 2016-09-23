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
		/**
		 * 相同的实体对象
		 */
        function get equivalentEntity():Entity;
		/**
		 * 世界矩阵
		 */
		function get worldMatrix():Matrix3D;
		/**
		 * 父类链接对象
		 */
		function get parentLinkObject():LinkableRenderable;
		/**
		 * 上一次渲染时间
		 */
		function get preRenderTime():uint;
		/**
		 * 帧间隔
		 */
		function get frameInterval():Number;
		function set frameInterval(va:Number):void;
		/**
		 * 添加链接对象
		 * @param va								链接对象
		 * @param linkName					链接名
		 * @param linkType						链接类型
		 * @param frameSync					帧异步
		 * @param time							延迟时间
		 */		
        function addLinkObject(va:LinkableRenderable, linkName:String, linkType:uint=0, frameSync:Boolean=false, time:int=-1):void;
		/**
		 * 移除链接对象
		 * @param linkName			链接名
		 * @param linkType				链接类型
		 */
		function removeLinkObject(linkName:String, linkType:uint=0):void;
		/**
		 * 清除该类型的所有链接对象
		 * @param linkType					链接类型
		 */		
        function clearLinks(linkType:uint):void;
		/**
		 * 获取指定类型的连接对象列表
		 * @param linkType							链接类型
		 * @return 
		 */		
        function getLinkObjects(linkType:uint):Dictionary;
		/**
		 * 获取指定类型与名字的链接对象
		 * @param linkName						链接名
		 * @param linkType							链接类型
		 * @return 
		 */		
        function getLinkObject(linkName:String, linkType:uint):LinkableRenderable;
		/**
		 * 检测节点的父类是否存在
		 * @param idx									索引
		 * @param subIdx								子索引
		 * @return 
		 */		
        function checkNodeParent(idx:uint, subIdx:uint):Boolean;
		/**
		 * 链接到父类
		 * @param va									链接对象
		 * @param linkName						链接名
		 * @param linkType							链接类型
		 * @param frameSync						帧异步
		 */		
        function onLinkedToParent(va:LinkableRenderable, linkName:String, linkType:uint, frameSync:Boolean):void;
		/**
		 * 从父类中移除链接对象
		 * @param va									链接对象
		 */		
        function onUnLinkedFromParent(va:LinkableRenderable):void;
		/**
		 * 获取节点的矩阵
		 * @param mat									矩阵
		 * @param idx									索引
		 * @param subIdx								子索引
		 * @return 
		 */		
        function getNodeMatrix(mat:Matrix3D, idx:uint, subIdx:uint):Boolean;
		/**
		 * 父类更新
		 * @param time								当前时间
		 */		
        function onParentUpdate(time:uint):void;
		/**
		 * 父类渲染开始
		 * @param time								当前时间
		 */		
        function onParentRenderBegin(time:uint):void;
		/**
		 * 父类渲染结束
		 * @param time								当前时间
		 */		
        function onParentRenderEnd(time:uint):void;
		/**
		 * 对象更新
		 * @param time								当前时间
		 * @param camera							摄像机
		 * @param mat									矩阵
		 * @return 
		 */		
        function update(time:uint, camera:Camera3D, mat:Matrix3D):Boolean;
		/**
		 * 获取指定粘附名的链接ID列表
		 * @param attachName
		 * @return 
		 */		
        function getLinkIDsByAttachName(attachName:String):Array;
		/**
		 * 获取节点当前帧信息
		 * @param frames							帧列表
		 * @param ends								结束列表
		 * @param idxs									索引列表
		 */		
        function getNodeCurFrames(frames:Vector.<Number>, ends:Vector.<Boolean>, idxs:Vector.<uint>):void;
		/**
		 * 获取节点当前帧的配套信息
		 * @param idx									索引
		 * @param fp									帧配套信息
		 * @return 
		 */		
        function getNodeCurFramePair(idx:uint, fp:FramePair=null):FramePair;
		/**
		 * 获取节点当前动作名
		 * @param idx									索引
		 * @return 
		 */		
        function getNodeCurAniName(idx:uint):String;
		/**
		 * 获取节点当前动作的索引
		 * @param idx									索引
		 * @return 
		 */		
        function getNodeCurAniIndex(idx:uint):int;
		/**
		 * 获取节点当前动作播放类型
		 * @param idx									索引
		 * @return 
		 */		
        function getNodeCurAniPlayType(idx:uint):uint;
		/**
		 * 设置节点动作
		 * @param aniName							动作名
		 * @param idx									索引
		 * @param fp									帧配套
		 * @param type								类型
		 * @param time								延迟时间
		 * @param idxs									索引列表
		 * @param va									
		 */		
        function setNodeAni(aniName:String, idx:uint, fp:FramePair, type:uint=0, time:uint=200, idxs:Vector.<uint>=null, va:uint=0):void;

    }
} 
