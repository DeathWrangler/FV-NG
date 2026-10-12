package Transactions
{
   import Classes.FeatureBuilding;
   import Managers.FarmStatsManager;
   
   public class TSawCraftshopV4MOTD extends TSawMOTD
   {
      
      private static const USER_FLOW_COMPLETED_BUILDING:int = 0;
      
      private static const USER_FLOW_CONSTRUCT_BUILDING:int = 1;
      
      private static const USER_FLOW_FORCE_PLACE:int = 2;
      
      protected var m_callbackData:Object = {};
      
      public function TSawCraftshopV4MOTD(currentMOTD:Object = null, callbackData:Object = null)
      {
         super(currentMOTD);
         this.m_callbackData = callbackData;
      }
      
      override protected function onComplete(result:Object) : void
      {
         var completedCraftshops:Array = null;
         var craftshop:FeatureBuilding = null;
         switch(this.m_callbackData.userFlow)
         {
            case USER_FLOW_FORCE_PLACE:
               FarmStatsManager.count("craftshop","motd","force_place");
               Global.world.enterForcePlaceMode(this.m_callbackData.gift,true);
               break;
            case USER_FLOW_CONSTRUCT_BUILDING:
               FarmStatsManager.count("craftshop","motd","auto_complete");
            case USER_FLOW_COMPLETED_BUILDING:
               if(this.m_callbackData.userFlow == USER_FLOW_COMPLETED_BUILDING)
               {
                  FarmStatsManager.count("craftshop","motd","already_complete");
               }
               completedCraftshops = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopFinished());
               if(completedCraftshops.length > 0)
               {
                  craftshop = completedCraftshops[0] as FeatureBuilding;
                  craftshop.displayStorageDialog();
               }
         }
      }
   }
}

