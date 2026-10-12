package Classes
{
   import Engine.Managers.StatsManager;
   
   public class GypsyTraderMapTrigger extends MapTrigger
   {
      
      public function GypsyTraderMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function onClick() : void
      {
         GypsyTrader.getInstance(name).showUI();
         StatsManager.count("NPC","Clicks",name);
      }
   }
}

