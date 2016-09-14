package app.equipment 
{
    import deltax.common.debug.*;
    import deltax.graphic.scenegraph.object.*;

    public class EquipItemInUse {

        public var equipName:String;
        public var renderObject:RenderObject;
        public var fxIDs:Vector.<String>;

        public function EquipItemInUse(){
            this.fxIDs = new Vector.<String>();
            super();
            ObjectCounter.add(this);
        }
    }
}
