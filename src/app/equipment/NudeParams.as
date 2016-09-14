package app.equipment 
{
    

    public class NudeParams {

		public static const NUDE_PART_TYPE_NAMES:Vector.<String> = Vector.<String>(["hair", "head", "body", "trousers", "foot"]);

        public var nudePartIDs:Vector.<uint>;

        public function NudeParams(){
            this.nudePartIDs = new Vector.<uint>(NudePartType.COUNT, true);
            super();
        }
    }
} 
