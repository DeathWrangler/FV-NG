package Classes
{
   public class MapTrigger extends MapResource
   {
      
      public static const STATE_STATIC:String = "static";
      
      public static const STATE_ANIMATION:String = "animation";
      
      protected const STATE_CONSTRUCT_0:String = "construct_0";
      
      protected const STATE_CONSTRUCT_1:String = "construct_1";
      
      protected const STATE_BUILT_0:String = "built_0";
      
      protected const MAP_TRIGGER:String = "mapTrigger";
      
      protected var m_stateToSet:String = "static";
      
      private var m_name:String = "";
      
      private var m_dialogUrl:String = "";
      
      public function MapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName);
         setState(stateToSet);
         setOuter(Global.world);
         m_typeName = this.MAP_TRIGGER;
         this.m_stateToSet = stateToSet;
      }
      
      override public function loadObject(data:Object) : void
      {
         if(!data)
         {
            data = {
               "position":{
                  "x":0,
                  "y":0,
                  "z":0
               },
               "state":this.m_stateToSet
            };
         }
         super.loadObject(data);
         if(data.hasOwnProperty("state"))
         {
            setState(data["state"]);
         }
         this.attach();
      }
      
      public function set name(newName:String) : void
      {
         this.m_name = newName;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function set dialogUrl(dialogUrl:String) : void
      {
         this.m_dialogUrl = dialogUrl;
      }
      
      public function get dialogUrl() : String
      {
         return this.m_dialogUrl;
      }
      
      public function loadXmlData(xmlData:XML) : void
      {
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         switch(state)
         {
            case STATE_STATIC:
            case STATE_ANIMATION:
            case this.STATE_CONSTRUCT_0:
            case this.STATE_CONSTRUCT_1:
            case this.STATE_BUILT_0:
               imageName = state;
               break;
            default:
               imageName = super.getCurrentImageName();
         }
         return imageName;
      }
      
      override public function isUsingPerPixelPick() : Boolean
      {
         return true;
      }
      
      override public function isMovable() : Boolean
      {
         var movable:Boolean = super.isMovable();
         var cantMoveRuntimeGate:Boolean = Boolean(Global.flashHotParams["MAP_TRIGGER_UNMOVABLE"]);
         if(cantMoveRuntimeGate == true)
         {
            movable = false;
         }
         return movable;
      }
   }
}

