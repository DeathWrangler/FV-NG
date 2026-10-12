package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.ContingencyBuildableRewardGrantWindow;
   import Widgets.Windows.ContingencyBuildableRewardWindow;
   
   public class ContingencyBuildableBuilding extends FeatureBuilding implements IMessagingFeature
   {
      
      public function ContingencyBuildableBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var rewardObjects:Array = null;
         var rewardObj:Object = null;
         if(result.hasOwnProperty("harvestRewardObjects"))
         {
            rewardObjects = result.harvestRewardObjects;
            for each(rewardObj in rewardObjects)
            {
               harvester.onHarvestComplete(rewardObj);
            }
            this.displayHarvestReward(rewardObjects);
         }
      }
      
      private function displayHarvestReward(rewardObjects:Array) : void
      {
         UI.displayPopup(new ContingencyBuildableRewardWindow(getItemName(),rewardObjects));
      }
      
      override public function expandToNextStorageLevel() : Boolean
      {
         var itemCode:String = null;
         var partItem:FarmItem = null;
         var qtyNeeded:Number = NaN;
         var buildingPart:BuildingPart = null;
         var parts:int = 0;
         var result:Boolean = false;
         var expansionParts:Object = this.nextExpansionPartsNeeded();
         var partsAdded:int = 0;
         if(expansionParts != null)
         {
            for(itemCode in expansionParts)
            {
               partItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               qtyNeeded = Number(expansionParts[itemCode]);
               buildingPart = new BuildingPart(partItem.name);
               partsAdded += qtyNeeded;
               for(parts = 0; parts < qtyNeeded; parts++)
               {
                  this.addItem(buildingPart,0,false,false);
               }
            }
            if(partsAdded <= 0)
            {
               completeExpansionLevel();
            }
            result = true;
         }
         if(result)
         {
            if(expand)
            {
               if(expand.hasReachedMaxExpansionLevel() && m_item.code == "24vw" && this.isBonusHarvestExpired() == false)
               {
                  this.grantBonusReward();
               }
            }
         }
         return result;
      }
      
      public function grantBonusReward() : void
      {
         if(!Global.player.getSeenFlag("ContingencyBuildable0719BonusRewardGranted"))
         {
            Global.player.addGift("unicorn_glitterrose","0",1);
            Global.player.addGift("pkg_unwither_1","0",5);
            Global.player.addGift("fuel1","0",5);
            Global.player.addGift("consume_turbo_charger","0",5);
            TransactionManager.addTransaction(new TGenericTransaction("ContingencyBuildableBuildingService","ContingencyBuildableGrantBonus",this.onGrantReward,["ContingencyBuildable0719BonusRewardGranted"]));
            UI.displayPopup(new ContingencyBuildableRewardGrantWindow("assets/dialogs/FV_GingerbreadCastle2019/FV_Gingerbread_reward2019.swf"));
            StatsManager.count("contingency_buildable","bonus_reward");
         }
      }
      
      public function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag("ContingencyBuildable0719BonusRewardGranted");
         }
      }
      
      public function isBonusHarvestExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("07/14/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
   }
}

