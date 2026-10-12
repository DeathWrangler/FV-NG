package Classes.consumables
{
   import Classes.Consumable;
   import Classes.HarvestYieldsGroup;
   import Classes.HarvestableResource;
   import Classes.Mastery;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Managers.AOEManager;
   import Widgets.Constants.Market.Currency;
   
   public class CHarvestAllOfType extends Consumable
   {
      
      protected var m_objectsToBeHarvested:Array = null;
      
      public function CHarvestAllOfType(itemName:String)
      {
         super(itemName);
      }
      
      override public function canUse() : Boolean
      {
         var harvestable:SimpleHarvestableResource = null;
         var harvestables:Array = this.getHarvestables();
         var canUse:Boolean = false;
         for(var index:int = 0; index < harvestables.length; index++)
         {
            harvestable = harvestables[index] as SimpleHarvestableResource;
            if(this.canHarvest(harvestable))
            {
               canUse = true;
               break;
            }
         }
         return canUse;
      }
      
      protected function canHarvest(harvestableResource:SimpleHarvestableResource) : Boolean
      {
         return false;
      }
      
      override public function onUse() : void
      {
         var harvestable:SimpleHarvestableResource = null;
         var coinMultiplier:int = 0;
         var avatarStatus:String = null;
         var harvestableItem:HarvestableItem = null;
         var totalCoinYield:uint = 0;
         var totalMasteryYield:int = 0;
         var totalXPYield:int = 0;
         var aoeCoinMult:Number = 0;
         var harvestYieldGroup:HarvestYieldsGroup = new HarvestYieldsGroup();
         var harvestCoins:int = 0;
         var objectToBeHarvested:Array = this.getObjectsToBeHarvested();
         for each(harvestable in objectToBeHarvested)
         {
            harvestable.harvest(HarvestableResource.ENERGY_SOURCE_AVATAR,0,true,false);
            harvestableItem = harvestable.getItem() as HarvestableItem;
            if(harvestableItem)
            {
               harvestCoins = harvestableItem.coinYield;
               aoeCoinMult = harvestable.coinBonusMultiplier;
               if(aoeCoinMult > 1)
               {
                  harvestCoins = Math.round(harvestCoins * aoeCoinMult);
               }
               totalCoinYield += harvestCoins;
               totalXPYield += harvestable.xpBonusCumulative;
               totalMasteryYield += Mastery.createMasteryForItem(harvestableItem).calculateMasteryYield();
               harvestYieldGroup.applyHarvestYieldsForItem(harvestableItem);
            }
         }
         coinMultiplier = Global.player.getWorldCurrencyMultiplier(Currency.COINS);
         Global.player.updateWorldCurrency(Currency.COINS,totalCoinYield,true);
         Global.player.xp += totalXPYield;
         avatarStatus = harvestYieldGroup.getDooberStatus();
         if(totalMasteryYield)
         {
            avatarStatus += ZLocUtils.t("FarmGame","Status_HarvestPlotMastery",{
               "coinNum":totalCoinYield * coinMultiplier,
               "masteryNum":totalMasteryYield
            });
         }
         else
         {
            avatarStatus += ZLocUtils.t("FarmGame","Status_HarvestPlot",{"coinNum":totalCoinYield * coinMultiplier});
         }
         if(totalXPYield > 0)
         {
            avatarStatus += ZLocUtils.t("FarmGame","Status_HarvestPlotXP",{"xpNum":totalXPYield});
         }
         Global.player.avatar.displayStatus(avatarStatus);
         this.displayHarvestResults(totalCoinYield * coinMultiplier,totalMasteryYield);
      }
      
      public function getObjectsToBeHarvested() : Array
      {
         var harvestables:Array = null;
         var harvestable:SimpleHarvestableResource = null;
         if(this.m_objectsToBeHarvested == null)
         {
            this.m_objectsToBeHarvested = new Array();
            harvestables = this.getHarvestables();
            for each(harvestable in harvestables)
            {
               if(this.canHarvest(harvestable))
               {
                  this.m_objectsToBeHarvested.push(harvestable);
               }
            }
         }
         return this.m_objectsToBeHarvested;
      }
      
      private function getAOETargestsToObjects(harvestAbleObjects:Array) : Object
      {
         var harvestable:SimpleHarvestableResource = null;
         var aoeResourceIds:Array = null;
         var aoeTargets:Object = {};
         for each(harvestable in harvestAbleObjects)
         {
            aoeResourceIds = AOEManager.getInstance().getAoeResourceIdsAffecting(harvestable);
            if(aoeResourceIds.length > 0)
            {
               aoeTargets[harvestable.getId()] = aoeResourceIds;
            }
         }
         return aoeTargets;
      }
      
      override public function extraTransactionParams() : Object
      {
         var obj:Object = super.extraTransactionParams();
         obj["aoeSources"] = this.getAOETargestsToObjects(this.getObjectsToBeHarvested());
         return obj;
      }
      
      protected function getHarvestables() : Array
      {
         return new Array();
      }
      
      protected function displayHarvestResults(totalCoinYield:uint, totalMasteryYield:int = 0) : void
      {
      }
   }
}

