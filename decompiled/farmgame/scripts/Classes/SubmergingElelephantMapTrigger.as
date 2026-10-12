package Classes
{
   import flash.events.Event;
   
   public class SubmergingElelephantMapTrigger extends MapTrigger
   {
      
      public static const STATE_IDLE:String = "built_1";
      
      public static const STATE_COMING_SOON:String = "built_0";
      
      private var m_assetPath:String = null;
      
      private var m_className:String = null;
      
      private var m_parameters:XML = null;
      
      public function SubmergingElelephantMapTrigger(itemName:String, stateToSet:String = "built_1")
      {
         super(itemName,stateToSet);
      }
      
      public function updateState(e:Event = null) : void
      {
         setState(STATE_IDLE);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         xmlData.featureName = name;
         this.m_parameters = xmlData;
         this.updateState();
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.updateState();
      }
      
      override public function onClick() : void
      {
         setState(STATE_COMING_SOON);
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}

