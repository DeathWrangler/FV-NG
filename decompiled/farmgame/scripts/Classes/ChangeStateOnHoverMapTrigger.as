package Classes
{
   import Managers.WorldSeasonsManager;
   
   public class ChangeStateOnHoverMapTrigger extends MapTrigger
   {
      
      private const STATE_BUILT_EA:String = "built_0";
      
      private const STATE_BUILT_GA:String = "built_1";
      
      public function ChangeStateOnHoverMapTrigger(itemName:String, stateToSet:String = "built_0")
      {
         super(itemName,stateToSet);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         var isEAUser:Boolean = WorldSeasonsManager.getInstance().isEAUser(Global.worldManager.currentWorldType);
         if(!isEAUser)
         {
            this.updateState(this.STATE_BUILT_GA);
         }
      }
      
      override public function onClick() : void
      {
      }
      
      override public function setHighlighted(highlighted:Boolean, color:uint = 16755200) : void
      {
      }
      
      public function updateState(value:String) : void
      {
         setState(value);
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}

