package Classes
{
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.ZItem.FarmItem;
   import DataSources.BaseDataSource;
   import Display.UI;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.HangingGardensCraftingShopRecipeQueueManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TStoreItem;
   import Widgets.Windows.Crafting.HangingGardensCraftingShopWindow;
   
   public class HangingGardensCraftingShopBuilding extends FixedFeatureBuilding
   {
      
      private var m_buildingType:String = null;
      
      private const ovenSeenSession:String = "HangingGardensOvenStateCheck";
      
      public function HangingGardensCraftingShopBuilding(buildingType:String = null)
      {
         this.m_buildingType = buildingType;
         super(buildingType);
      }
      
      override public function onClick() : void
      {
         var upgradeLevel:String = null;
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeDataSource:BaseDataSource = null;
         var upgradeData:XML = null;
         var unlockConst:String = null;
         var unlockRecipesNeeded:int = 0;
         var totalNumRecipesCompleted:int = 0;
         if(!Global.player.getSeenSessionFlag(this.ovenSeenSession))
         {
            if(isDynamicPartsExperimentOn())
            {
               buildingExpansionData = this.getNextBuildingExpansionData();
               if(buildingExpansionData)
               {
                  upgradeLevel = buildingExpansionData.level.toString();
               }
            }
            else if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = getNextExpansionDataSource();
               if(upgradeDataSource)
               {
                  upgradeLevel = upgradeDataSource.getString("level");
               }
            }
            else
            {
               upgradeData = this.getNextExpansionData();
               if(upgradeData)
               {
                  upgradeLevel = upgradeData.attribute("level").toString();
               }
            }
            if(upgradeLevel)
            {
               unlockConst = HangingGardensCraftingShopRecipeQueueManager.UNLOCK_PREFIX + upgradeLevel;
               unlockRecipesNeeded = int(HangingGardensCraftingShopRecipeQueueManager[unlockConst]);
               totalNumRecipesCompleted = Global.player.craftingState.getNumOfRecipesToCompleteByType(CraftingConstants.HANGING_GARDENS_CRAFTINGSHOP_SKILL);
               if(totalNumRecipesCompleted >= unlockRecipesNeeded)
               {
                  this.expandWithoutCash();
               }
            }
            Global.player.setSeenSessionFlag(this.ovenSeenSession);
         }
         var craftingShopWindow:HangingGardensCraftingShopWindow = new HangingGardensCraftingShopWindow(this);
         UI.displayPopup(craftingShopWindow,false,"hanging_gardens_crafting_shop");
         FarmStatsManager.count("craftshop",this.m_buildingType,"click");
      }
      
      public function expandWithoutCash(callBack:Function = null) : void
      {
         var itemCode:String = null;
         var partItem:FarmItem = null;
         var qtyNeeded:Number = NaN;
         var buildingPart:BuildingPart = null;
         var parts:int = 0;
         m_completeNowInProgress = true;
         var expansionParts:Object = this.nextExpansionPartsNeeded();
         if(expansionParts != null)
         {
            for(itemCode in expansionParts)
            {
               partItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               qtyNeeded = Number(expansionParts[itemCode]);
               buildingPart = new BuildingPart(partItem.name);
               for(parts = 0; parts < qtyNeeded; parts++)
               {
                  this.addItem(buildingPart,0,false,false);
                  addTransaction(new TStoreItem(this,buildingPart,0,buildingPart.getId(),true,""));
               }
            }
         }
         if(expand)
         {
            expand.conditionallySwapOnFullyExpanded();
         }
         m_completeNowInProgress = false;
      }
   }
}

