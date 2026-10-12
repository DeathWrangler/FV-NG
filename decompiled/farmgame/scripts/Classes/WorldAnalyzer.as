package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmGameSettingsManager;
   
   public class WorldAnalyzer
   {
      
      public function WorldAnalyzer()
      {
         super();
      }
      
      public static function getHarvestableCountByClass(className:Class) : int
      {
         return WorldAnalyzer.getHarvestableCount(Global.world.getObjectsByClass(className));
      }
      
      public static function getHarvestableCount(harvestableItems:Array) : int
      {
         return harvestableItems.filter(itemIsHarvestable).length;
      }
      
      private static function itemIsHarvestable(harvestObject:SimpleHarvestableResource, index:int = 0, array:Array = null) : Boolean
      {
         var retVal:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            retVal = Boolean(harvestObject.getItem()) && harvestObject.isHarvestable();
         }
         else
         {
            retVal = Boolean(harvestObject.getItem()) && Boolean(harvestObject.getItem().xml) && harvestObject.isHarvestable();
         }
         return retVal;
      }
      
      public static function getActionablePlots() : Array
      {
         var plot:Plot = null;
         var result:Array = [];
         var plots:Array = Global.world.getObjectsByClass(Plot);
         for(var plotIdx:int = 0; plotIdx < plots.length; plotIdx++)
         {
            plot = plots[plotIdx] as Plot;
            if(plot.isPlanted() == false)
            {
               result.push(plot);
            }
         }
         return result;
      }
      
      public static function getCropsLeftToMasterData() : Array
      {
         var checkDateGate:Boolean = false;
         var currentLevel:int = 0;
         var cropsLeftToMasterData:Array = [];
         var mastery:Object = Global.player.masteryCounters;
         var itemCode:String = null;
         var item:FarmItem = null;
         var masteryObject:Mastery = null;
         for(itemCode in mastery)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(item)
            {
               checkDateGate = false;
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  checkDateGate = Global.farmGameSettingsManager.checkDateGateDS(item,GlobalEngine.getTimer());
               }
               else
               {
                  checkDateGate = Global.farmGameSettingsManager.checkDateGate(item.xml,GlobalEngine.getTimer());
               }
               if(checkDateGate == true)
               {
                  masteryObject = Mastery.createMasteryForItem(item);
                  if(masteryObject.remainingCropsToNextLevel > 0)
                  {
                     currentLevel = masteryObject.currentLevel + 1;
                     if(cropsLeftToMasterData[currentLevel] == null)
                     {
                        cropsLeftToMasterData[currentLevel] = {};
                     }
                     if(cropsLeftToMasterData[currentLevel][masteryObject.remainingCropsToNextLevel] == null)
                     {
                        cropsLeftToMasterData[currentLevel][masteryObject.remainingCropsToNextLevel] = [];
                     }
                     cropsLeftToMasterData[currentLevel][masteryObject.remainingCropsToNextLevel].push(itemCode);
                  }
               }
            }
         }
         return cropsLeftToMasterData;
      }
   }
}

