package Managers.InGameConsole
{
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Managers.FeatureCraftingManager;
   import com.adobe.serialization.json.JSON;
   
   public class ConsoleFeatureCraftingCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ConsoleFeatureCraftingCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "featureCrafting";
      }
      
      public function resetCraftingFeature(craftingSystem:String) : String
      {
         FeatureCraftingManager.instance.adminResetUserData(craftingSystem);
         sendTransaction("adminCall",{
            "adminController":"CPanelFeatureCraftingController",
            "adminCommand":"resetFeature",
            "craftingSystem":craftingSystem
         });
         return "Feature Successfully Reset!";
      }
      
      public function setPoints(systemName:String, points:int) : String
      {
         FeatureCraftingManager.instance.adminSetPoints(systemName,points);
         sendTransaction("adminCall",{
            "adminController":"CPanelFeatureCraftingController",
            "adminCommand":"setPoints",
            "craftingSystem":systemName,
            "points":points
         },null,true);
         return "Points successfully set!";
      }
      
      public function setMasteryHarvests(systemName:String, recipeName:String, harvestCount:int) : String
      {
         FeatureCraftingManager.instance.adminSetHarvestCount(systemName,recipeName,harvestCount);
         sendTransaction("adminCall",{
            "adminController":"CPanelFeatureCraftingController",
            "adminCommand":"setMasteryHarvests",
            "craftingSystem":systemName,
            "recipeName":recipeName,
            "harvestCount":harvestCount
         });
         return "Mastery successfully set!";
      }
      
      public function viewFeatureData(systemName:String) : String
      {
         var data:Object = {};
         var system:FeatureCraftingSystem = FeatureCraftingManager.instance.getSystem(systemName);
         if(system)
         {
            data = system.getUserData();
         }
         return com.adobe.serialization.json.JSON.encode(data);
      }
      
      public function getNewOrderBoard(systemName:String) : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelFeatureCraftingController",
            "adminCommand":"getNewOrderBoard",
            "craftingSystem":systemName
         },this.generateOnNewOrderBoard(systemName));
         return "Waiting on order board successfully set!";
      }
      
      private function generateOnNewOrderBoard(systemName:String) : Function
      {
         return function(result:Object):void
         {
            var system:* = FeatureCraftingManager.instance.getSystem(systemName);
            if(system)
            {
               system.evaluateServerResponseForNewOrders(result);
            }
         };
      }
   }
}

