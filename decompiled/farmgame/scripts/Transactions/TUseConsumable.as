package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.Consumable;
   import Classes.SimpleHarvestableResource;
   import Classes.consumables.*;
   import Display.UI;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.Promotions.EmailCampaignInactiveWindow;
   import Widgets.Windows.Promotions.EmailCampaignWindow;
   import Widgets.Windows.Promotions.FuelBoostWindow;
   import flash.utils.getQualifiedClassName;
   import gs.TweenLite;
   
   public class TUseConsumable extends TWorldState
   {
      
      protected var m_params:Object;
      
      protected var m_itemName:String;
      
      private var m_consumable:Consumable;
      
      private var m_targetsSetBusy:Array;
      
      private var m_allowReshopping:Boolean = true;
      
      private var m_consumableTypes:Array;
      
      public function TUseConsumable(consumable:Consumable, isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1)
      {
         var paramKey:String = null;
         var uid:String = null;
         var i:int = 0;
         var sRepopGift:String = null;
         var nRepopGift:Number = NaN;
         this.m_consumableTypes = [CCoins,CCash,CCrafted,CBushel,CXP,CQuestProgress,CUnwither,CInstagrow,CAnimalInstagrow,CInstantGrowFlight,CHaitiBiscuit,CWalkSpeed,CFuel,CTurbo,CAvatarSize,CMasteryTimed,CHarvestTrees,CHarvestBuildings,CHarvestAnimals,CHarvestBlooms,CHarvestOrchards,CHarvestGardens,CFishingBait,CToiletPaper,CTrickLicense,CSlotMachineToken,CPetsKibble,CMysteryBoxGameDart,CFertilizeAll,CVehiclePart,CPigSlop,CTruffle,CAnimalLovePotion,CSocialRaffleTicket,CXPBook,CRewardConsumable,CRewardConsumeAll,CHalloweenUSARedeemConsumable,CTuscanyBoosterConsumable,CRussiaBoosterConsumable,COrganicFertilizer,FuelBoostWindow,EmailCampaignWindow,EmailCampaignInactiveWindow];
         super(consumable);
         this.m_consumable = consumable;
         this.m_itemName = this.m_consumable.getItem().name;
         this.m_params = new Object();
         this.m_params.isGift = isGift;
         this.m_params.isFree = isFree;
         this.m_params.storageId = storageId;
         this.m_params.itemCount = itemCount;
         this.m_allowReshopping = allowReshopping;
         if(userID == "")
         {
            uid = Global.player.uid;
            if(isNaN(Number(uid)))
            {
               uid = "0";
            }
            userID = uid;
         }
         this.m_params.targetUser = String(userID);
         var canUse:Boolean = this.m_consumable.canUse();
         if(canUse && this.m_consumable.isOptimistic())
         {
            for(i = 0; i < itemCount; i++)
            {
               this.m_consumable.onUse();
            }
         }
         var extraParams:Object = this.m_consumable.extraTransactionParams();
         for(paramKey in extraParams)
         {
            this.m_params[paramKey] = extraParams[paramKey];
         }
         this.m_targetsSetBusy = this.m_consumable.setTargetsBusy();
         if(canUse)
         {
            this.statsCQuestProgressCount(this.m_consumable,this.m_itemName,"if_begin:" + this.m_params.itemCount.toString());
            if(this.m_params.isGift == true)
            {
               if(!isFree)
               {
                  for(i = 0; i < itemCount; i++)
                  {
                     Global.player.removeGift(null,this.m_itemName);
                  }
               }
               if(this.m_allowReshopping)
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     sRepopGift = this.m_consumable.getItem().getStringFromDataSource("repopGift");
                  }
                  else
                  {
                     sRepopGift = this.m_consumable.getItem().xml.attribute("repopGift");
                  }
                  if(sRepopGift != "false")
                  {
                     if(sRepopGift == null || sRepopGift == "" || sRepopGift == "true")
                     {
                        UI.displayGiftBoxWindow();
                     }
                     else if(sRepopGift != null)
                     {
                        nRepopGift = Number(sRepopGift);
                        if(nRepopGift >= 0)
                        {
                           TweenLite.delayedCall(nRepopGift,UI.displayGiftBoxWindow,null);
                        }
                     }
                  }
               }
            }
            this.statsCQuestProgressCount(this.m_consumable,this.m_itemName,"if_end:" + this.m_params.itemCount.toString());
         }
         else
         {
            canPerform = false;
            this.m_consumable.onFailedPerform();
         }
      }
      
      override public function perform() : void
      {
         signedWorldAction(TWorldState.ACTION_USE,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var target:SimpleHarvestableResource = null;
         var itemCount:int = 0;
         var i:int = 0;
         this.checkForSiloHarvestBushels(result);
         if(this.m_targetsSetBusy != null)
         {
            for each(target in this.m_targetsSetBusy)
            {
               target.isBusy = false;
            }
         }
         if(Boolean(this.m_consumable) && !this.m_consumable.isOptimistic())
         {
            itemCount = this.m_params.hasOwnProperty("itemCount") ? int(this.m_params.itemCount) : 1;
            this.statsCQuestProgressCount(this.m_consumable,this.m_itemName,"onComplete_begin:" + itemCount.toString());
            for(i = 0; i < itemCount; i++)
            {
               this.m_consumable.initialize(result);
               this.m_consumable.onUse();
            }
            this.statsCQuestProgressCount(this.m_consumable,this.m_itemName,"onComplete_end:" + itemCount.toString());
         }
      }
      
      private function checkForSiloHarvestBushels(result:Object) : void
      {
         var iBushelType:Number = NaN;
         var resultEntry:Object = null;
         var farmworkerFlow:Boolean = false;
         if(result != null && result.hasOwnProperty("foundBushelArray") && result.foundBushelArray.length > 0)
         {
            for(iBushelType = 0; iBushelType < result.foundBushelArray.length; iBushelType++)
            {
               resultEntry = result.foundBushelArray[iBushelType];
               if(Boolean(resultEntry) && Boolean(resultEntry.foundBushel))
               {
                  farmworkerFlow = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FARMWORKER) == Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
                  CraftingManager.getInstance().recordBushelFound(resultEntry,farmworkerFlow);
               }
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = TWorldState.ACTION_USE;
         result.item = this.m_consumable.getItem();
         if(this.m_consumable is CHarvestAllOfType)
         {
            result.harvestables = (this.m_consumable as CHarvestAllOfType).getObjectsToBeHarvested();
         }
         return result;
      }
      
      private function statsCQuestProgressCount(object:Object, itemName:String = "", ref:String = "") : void
      {
         var statsSampleRate:Number = NaN;
         var itemCount:Number = NaN;
         var inspectEnabled:Boolean = Global.flashHotParams["CQUESTPROGRESS_OOS_INSPECT_ENABLE"] as Boolean;
         if(inspectEnabled)
         {
            statsSampleRate = Global.flashHotParams["CQUESTPROGRESS_OOS_STAT_SAMPLE_RATE1"] as Number;
            try
            {
               if(getQualifiedClassName(object) == "CQuestProgress")
               {
                  if(itemName)
                  {
                     itemCount = Global.player.getGiftCountForItem(itemName);
                     FarmStatsManager.sample(statsSampleRate,"fv_cquestprogress_oos","frontend","info","statsGiftCount",itemName + "/" + itemCount,ref);
                  }
                  else
                  {
                     FarmStatsManager.sample(statsSampleRate,"fv_cquestprogress_oos","frontend","error","statsGiftCount","itemNameIsNotValid");
                  }
               }
               FarmStatsManager.sample(statsSampleRate,"fv_cquestprogress_oos","frontend","info","statsGiftCount","trySuccess");
            }
            catch(error:Error)
            {
               FarmStatsManager.sample(statsSampleRate,"fv_cquestprogress_oos","frontend","error","statsGiftCount","tryFaild");
            }
         }
      }
   }
}

