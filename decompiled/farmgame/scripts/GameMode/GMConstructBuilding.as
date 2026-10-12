package GameMode
{
   import Classes.BuildingPart;
   import Classes.FeatureBuilding;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.HangingGardensManager;
   import Transactions.TCompleteNow;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.utils.Timer;
   
   public class GMConstructBuilding extends GMGiftReOpen
   {
      
      protected const SPARKLE_TIME:int = 2500;
      
      protected var m_buildingPart:BuildingPart;
      
      protected var m_timer:Timer = null;
      
      protected var m_building:StorageBuilding = null;
      
      private var m_displayPlusXOverBuilding:Boolean = true;
      
      private var m_combineTransactions:Boolean = true;
      
      private var m_allowReOpenGiftBox:Boolean = true;
      
      private var m_numParts:int = 1;
      
      protected var m_centerOnBuilding:Boolean = true;
      
      protected var m_sendImmediately:Boolean;
      
      public function GMConstructBuilding(itemName:String, building:StorageBuilding, isGift:Boolean = false, displayPlusXOverBuilding:Boolean = true, allowReOpenGiftBox:Boolean = true, numParts:int = 1, centerOnBuilding:Boolean = true, sendImmediately:Boolean = true, combineTransactions:Boolean = true)
      {
         this.m_sendImmediately = sendImmediately;
         var buildingName:String = Boolean(building) && Boolean(building.getItem()) ? building.getItem().name : "unknown";
         FarmGame.cbTrace("GMConstructBuilding " + buildingName + " " + itemName + " " + numParts);
         this.m_buildingPart = new BuildingPart(itemName);
         this.m_building = building;
         this.m_displayPlusXOverBuilding = displayPlusXOverBuilding;
         this.m_allowReOpenGiftBox = allowReOpenGiftBox;
         this.m_numParts = numParts;
         this.m_centerOnBuilding = centerOnBuilding;
         this.m_combineTransactions = combineTransactions;
         super(isGift,allowReOpenGiftBox);
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         this.addBuildingPartToBuilding(this.m_building,this.m_buildingPart);
         Global.world.popGameMode();
      }
      
      protected function addBuildingPartToBuilding(building:StorageBuilding, buildingPart:BuildingPart) : void
      {
         var result:Boolean = false;
         var sendStoreItemTransaction:Boolean = false;
         var multiAddToCompleteMaterial:Boolean = false;
         var partsAdded:Number = NaN;
         var featureBuilding:FeatureBuilding = null;
         var upgardPartCount:int = 0;
         var upgardPartLimit:int = 0;
         var currencyObject:Object = null;
         var marketVal:String = null;
         var iParts:int = 0;
         var message:String = null;
         var iconFilter:Array = null;
         var iconUrl:String = null;
         var duration:Number = NaN;
         var hasABuilding:Boolean = false;
         var addedToBuilding:Boolean = false;
         if(building)
         {
            hasABuilding = true;
            result = true;
            sendStoreItemTransaction = true;
            multiAddToCompleteMaterial = false;
            partsAdded = this.m_numParts;
            if(this.m_combineTransactions && this.m_numParts > 1 && building.isFullyBuilt())
            {
               upgardPartCount = building.getExpansionPartCount(buildingPart.getItem().code);
               upgardPartLimit = building.getExpansionPartLimit(buildingPart.getItem().code);
               if(upgardPartCount + this.m_numParts == upgardPartLimit)
               {
                  multiAddToCompleteMaterial = true;
                  sendStoreItemTransaction = false;
               }
            }
            if(HangingGardensManager.isInHangingGardensExperiment())
            {
               currencyObject = building.getCurrencyBeingAdded(buildingPart);
               if(Boolean(currencyObject) && currencyObject.hasOwnProperty("amount"))
               {
                  partsAdded = Number(currencyObject["amount"]);
               }
            }
            featureBuilding = building as FeatureBuilding;
            if(featureBuilding != null)
            {
               result = featureBuilding.multiAddItem(buildingPart,this.m_numParts,0,m_isGift,sendStoreItemTransaction,this.m_sendImmediately);
               if(result && !m_isGift)
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     marketVal = this.m_buildingPart.getItem().getStringFromDataSource("market");
                  }
                  else
                  {
                     marketVal = this.m_buildingPart.getItem().xml.@market;
                  }
                  if(marketVal == "cash")
                  {
                     Global.player.cash -= buildingPart.getItem().cash * this.m_numParts;
                  }
                  else
                  {
                     Global.player.gold -= buildingPart.getItem().coins * this.m_numParts;
                  }
               }
            }
            else
            {
               for(iParts = 0; iParts < this.m_numParts; iParts++)
               {
                  if(!building.addItem(buildingPart,0,m_isGift,sendStoreItemTransaction,this.m_sendImmediately))
                  {
                     result = false;
                     break;
                  }
                  if(!m_isGift)
                  {
                     if(FarmGameSettingsManager.isInDataSourceExperiment())
                     {
                        marketVal = this.m_buildingPart.getItem().getStringFromDataSource("market");
                     }
                     else
                     {
                        marketVal = this.m_buildingPart.getItem().xml.@market;
                     }
                     if(marketVal == "cash")
                     {
                        Global.player.cash -= buildingPart.getItem().cash;
                     }
                     else
                     {
                        Global.player.gold -= buildingPart.getItem().coins;
                     }
                  }
               }
            }
            if(result)
            {
               this.m_building = building;
               if(multiAddToCompleteMaterial)
               {
                  TransactionManager.addTransaction(new TCompleteNow(building,buildingPart.getItem().name,null,this.m_numParts));
               }
               if(this.m_displayPlusXOverBuilding)
               {
                  message = this.m_building.buildStatusMessage([partsAdded,buildingPart.getItemFriendlyName()]);
                  iconFilter = [new GlowFilter(16776960,1,8,8,20)];
                  iconUrl = buildingPart.getItem().icon;
                  duration = UI.DEFAULT_STATUS_TWEEN_DURATION * 2;
                  this.m_building.displayStatus(message,iconUrl,iconFilter,duration);
                  if(this.m_centerOnBuilding)
                  {
                     this.m_building.centerOn();
                  }
               }
               addedToBuilding = true;
               building.reloadImage();
            }
         }
         this.displayFeedbackPopup(hasABuilding,addedToBuilding);
         if(this.m_allowReOpenGiftBox)
         {
            reOpenGiftIfNecessary();
         }
      }
      
      protected function onTimerComplete(event:TimerEvent) : void
      {
         if(this.m_timer != null)
         {
            if(this.m_building != null)
            {
               this.m_building.stopOverlay();
            }
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
            this.m_timer = null;
         }
      }
      
      protected function displayFeedbackPopup(hasABuilding:Boolean, addedToBuilding:Boolean) : void
      {
         var popupMessage:String = "";
         if(addedToBuilding == false && hasABuilding == false)
         {
            popupMessage = ZLocUtils.t("Dialogs","ConstructionBuilding_DontHave");
            UI.displayPopup(new GenericPopup(popupMessage,GenericPopup.TYPE_OK,this.noBuildingCallback));
         }
         else if(addedToBuilding == false && hasABuilding == true)
         {
            popupMessage = ZLocUtils.t("Dialogs","ConstructionBuilding_IsFullyBuilt");
            UI.displayPopup(new GenericPopup(popupMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.alreadyCompleteCallback));
         }
      }
      
      private function noBuildingCallback(event:GenericPopupEvent) : void
      {
         var partName:String = this.m_buildingPart.getItem().name;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_accept",partName,"noBuildingCallback","GMConstructBuilding");
            UI.displayGiftBoxWindow(true);
         }
         else
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_cancel",partName,"noBuildingCallback","GMConstructBuilding");
         }
      }
      
      private function alreadyCompleteCallback(event:GenericPopupEvent) : void
      {
         var partName:String = this.m_buildingPart.getItem().name;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_accept",partName,"alreadyCompleteCallback","GMConstructBuilding");
            UI.displayGiftBoxWindow(true);
         }
         else
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_cancel",partName,"alreadyCompleteCallback","GMConstructBuilding");
         }
      }
   }
}

