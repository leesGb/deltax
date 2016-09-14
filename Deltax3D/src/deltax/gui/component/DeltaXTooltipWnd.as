//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.gui.component {
    import flash.display.*;
    import deltax.graphic.manager.*;
    import deltax.gui.base.*;
    import deltax.common.resource.*;

    public class DeltaXTooltipWnd extends DeltaXRichWnd {

        private var m_lastTargetComponent:InteractiveObject;

        public function DeltaXTooltipWnd(){
            this.initContentWnd(null);
        }
        public function set defaultTooltipRes(_arg1:String):void{
            (ResourceManager.instance.getResource((Enviroment.ResourceRootPath + _arg1), ResourceType.GUI, this.onDefaultTooltipResLoaded) as WindowResource);
        }
        private function onDefaultTooltipResLoaded(_arg1:WindowResource, _arg2:Boolean):void{
            if (((_arg1) && (_arg2))){
                this.initContentWnd(_arg1.createParam);
            };
        }
        private function initContentWnd(_arg1:WindowCreateParam):void{
        }

    }
}//package deltax.gui.component 
