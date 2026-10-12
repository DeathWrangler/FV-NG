package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Display.MOTD;
   
   public class TSawMOTD extends TFarmTransaction
   {
      
      protected var m_currentMOTD:Object;
      
      public function TSawMOTD(currentMOTD:Object = null)
      {
         super();
         this.m_currentMOTD = currentMOTD;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MOTD_GIFT_ONCOMPLETE) == 0)
         {
            this.conditionallyGrantGifts();
         }
      }
      
      private function conditionallyGrantGifts() : void
      {
         var gifts:Array = null;
         var giftAmounts:Array = null;
         var freeGiftName:String = null;
         var additionalGiftCount:int = 0;
         var giftName:String = null;
         var giftItem:int = 0;
         var amount:int = 0;
         var giftQuantity:int = 0;
         var motdGiftName:String = null;
         if(this.m_currentMOTD)
         {
            gifts = new Array();
            giftAmounts = new Array();
            freeGiftName = this.m_currentMOTD["freeGift"];
            gifts.push(freeGiftName);
            giftAmounts.push(1);
            additionalGiftCount = 1;
            giftName = this.m_currentMOTD["additionalGift" + String(additionalGiftCount)];
            while(giftName)
            {
               gifts.push(giftName);
               amount = int(this.m_currentMOTD["additionalGiftQuantity" + String(additionalGiftCount)]);
               if(amount)
               {
                  giftAmounts.push(amount);
               }
               else
               {
                  giftAmounts.push(1);
               }
               additionalGiftCount++;
               giftName = this.m_currentMOTD["additionalGift" + String(additionalGiftCount)];
            }
            for(giftItem = 0; giftItem < gifts.length; giftItem++)
            {
               for(giftQuantity = 0; giftQuantity < giftAmounts[giftItem]; giftQuantity++)
               {
                  motdGiftName = gifts[giftItem];
                  if(Boolean(motdGiftName) && !Global.player.checkItemLimit(motdGiftName))
                  {
                     Global.player.addGift(motdGiftName);
                  }
               }
            }
            Global.player.setMotdSeenFlag(this.m_currentMOTD.motdSeenFlag);
            if(this.m_currentMOTD.hasOwnProperty("rewards"))
            {
               UserRewardUtil.grantUserRewardsFromArray(this.m_currentMOTD.rewards);
            }
         }
      }
      
      override public function perform() : void
      {
         signedCall("UserService.sawMOTD");
      }
      
      override public function isFaultable() : Boolean
      {
         return false;
      }
      
      override protected function onComplete(result:Object) : void
      {
         var giftName:String = null;
         var action:String = null;
         var cancelAction:String = null;
         var storageBuildingName:String = null;
         var giftItem:FarmItem = null;
         var storageBuilding:FarmItem = null;
         var slotmachineObjects:Array = null;
         var featureBuilding:FeatureBuilding = null;
         if(result != null && Boolean(this.m_currentMOTD))
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MOTD_GIFT_ONCOMPLETE) > 0)
            {
               this.conditionallyGrantGifts();
            }
            giftName = this.m_currentMOTD["freeGift"];
            action = this.m_currentMOTD["action"];
            cancelAction = this.m_currentMOTD["cancelAction"];
            storageBuildingName = this.m_currentMOTD["storageBuildingName"];
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(giftName);
            storageBuilding = Global.farmGameSettingsManager.getFarmItemByName(storageBuildingName);
            if(Boolean((action == "placementModeForFreeGift" || action == "placementModeForFreeGiftFromSeenMOTD") && !MOTD.cancelButtonPressed && giftName) && Boolean(giftItem) && Global.player.hasGiftItem(giftItem.code))
            {
               if(!Global.worldManager.isVisiting())
               {
                  Global.world.enterForcePlaceMode(giftName);
               }
            }
            else if(Boolean(action == "displayStorageDialog" && !MOTD.cancelButtonPressed && storageBuildingName) && Boolean(storageBuilding) && Global.player.hasGiftItem(storageBuilding.code))
            {
               if(!Global.worldManager.isVisiting())
               {
                  Global.world.enterForcePlaceMode(storageBuildingName);
               }
            }
            else if(Boolean(MOTD.freeGiftUIOpenedFromMOTDAcceptance) && Boolean(giftName) && Boolean(this.m_currentMOTD.freeGiftClassName) && "FeatureBuilding" == String(this.m_currentMOTD.freeGiftClassName))
            {
               slotmachineObjects = Global.world.getObjectsByName(giftName);
               featureBuilding = null;
               if(slotmachineObjects[0] != null)
               {
                  featureBuilding = slotmachineObjects[0] as FeatureBuilding;
                  featureBuilding.slotmachine.displayWindow();
                  MOTD.freeGiftUIOpenedFromMOTDAcceptance = false;
                  if(giftItem)
                  {
                     Global.player.setItemFlag("ForcePlace_Reminder",giftItem.code);
                  }
               }
            }
            MOTD.cancelButtonPressed = false;
            Global.player.currentMOTD = null;
         }
      }
   }
}

