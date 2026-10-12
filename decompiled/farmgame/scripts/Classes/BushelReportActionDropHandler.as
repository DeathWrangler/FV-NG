package Classes
{
   import Classes.Constants.Experiments;
   import Events.DynamicObjectEvent;
   import Managers.ActionDropsManager;
   import Managers.Crafting.CraftingManager;
   import Widgets.Windows.BushelReportWindow;
   
   public class BushelReportActionDropHandler
   {
      
      private static var s_featureName:String;
      
      public function BushelReportActionDropHandler()
      {
         super();
      }
      
      public static function registerActionDropsListener(initParams:Object, params:XML) : void
      {
         s_featureName = params.featureName;
         ActionDropsManager.getInstance().addEventListener(ActionDropsManager.EVENT_ACTION_DROPS_UPDATED,refreshActionDropStatus);
      }
      
      public static function canPlayerSeeFeature() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUSHEL_REPORT) > 1;
      }
      
      private static function refreshActionDropStatus(event:DynamicObjectEvent) : void
      {
         var actionDropsData:Object = null;
         var actionDropName:String = null;
         var bushelReport:Object = null;
         var reportSize:int = 0;
         var i:int = 0;
         var newHarvestQuantities:Object = null;
         var harvestSize:int = 0;
         var j:int = 0;
         var harvestInfo:Object = null;
         if(event.data)
         {
            actionDropsData = event.data;
            if(actionDropsData != null)
            {
               for(actionDropName in actionDropsData)
               {
                  if(actionDropName == s_featureName)
                  {
                     if(actionDropsData[s_featureName]["dropTypeFuncResult"])
                     {
                        bushelReport = actionDropsData[s_featureName]["dropTypeFuncResult"];
                        if(bushelReport)
                        {
                           reportSize = int(bushelReport.length);
                           for(i = 0; i < reportSize; i++)
                           {
                              if(bushelReport[i])
                              {
                                 CraftingManager.handleBushelFound(bushelReport[i]);
                              }
                           }
                           if(bushelReport["newHarvestQuantities"])
                           {
                              newHarvestQuantities = bushelReport["newHarvestQuantities"];
                              harvestSize = int(newHarvestQuantities.length);
                              for(j = 0; j < harvestSize; j++)
                              {
                                 harvestInfo = newHarvestQuantities[j];
                                 Global.player.setHarvestCountForSeedSinceLastBushelDrop(harvestInfo["itemCode"],harvestInfo["quantity"]);
                              }
                           }
                           BushelReportWindow.conditionallyRefreshWindow();
                        }
                     }
                  }
               }
            }
         }
      }
   }
}

