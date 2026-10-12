package GameMode
{
   import Classes.BeehiveBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Windows.Beehives.BeehiveWindow;
   import Widgets.Windows.Market.MarketWindow;
   
   public class GMBeehiveItemPlace extends GMCreditsBuildingItemPlace
   {
      
      protected var m_isHive:Boolean;
      
      public function GMBeehiveItemPlace(itemName:String, isGift:Boolean, itemCount:int = 1, isHive:Boolean = false)
      {
         super(itemName,isGift,true,true,itemCount);
         this.m_isHive = isHive;
      }
      
      override public function enableMode() : void
      {
         var buildingX:int = 0;
         var buildings:Array = Global.world.getObjectsByName(m_creditsBuildingName);
         var beehiveBuilding:BeehiveBuilding = null;
         if(buildings.length > 0)
         {
            for(buildingX = 0; buildingX < buildings.length; buildingX++)
            {
               if(canModifyBuilding(buildings[buildingX]) || (buildings[buildingX] as BeehiveBuilding).isFull())
               {
                  beehiveBuilding = buildings[buildingX];
                  m_building = beehiveBuilding;
                  break;
               }
            }
         }
         var canEnableMode:Boolean = true;
         var messageText:String = null;
         if(!beehiveBuilding)
         {
            messageText = ZLocUtils.t("Dialogs","BeehiveBuilding_NoBuilding");
            canEnableMode = false;
         }
         else if(beehiveBuilding.hasQueenBee() && this.m_itemName == BeehiveBuilding.BEEHIVE_QUEEN)
         {
            messageText = ZLocUtils.t("Dialogs","BeehiveBuilding_ExrtaQueen");
            canEnableMode = false;
         }
         else if(!beehiveBuilding.hasQueenBee() && (this.m_itemName == BeehiveBuilding.BEEHIVE_BEE_5 || this.m_itemName == BeehiveBuilding.BEEHIVE_BEE))
         {
            messageText = ZLocUtils.t("Dialogs","BeehiveBuilding_NoQueen");
            canEnableMode = false;
         }
         else if(beehiveBuilding.hasQueenBee() && beehiveBuilding.isAlmostFull() && this.m_itemName == BeehiveBuilding.BEEHIVE_BEE_5)
         {
            messageText = ZLocUtils.t("Dialogs","BeehiveBuilding_AlmostFullBuilding");
            canEnableMode = false;
         }
         else if(beehiveBuilding.hasQueenBee() && beehiveBuilding.isFull() && this.m_itemName == BeehiveBuilding.BEEHIVE_BEE)
         {
            messageText = ZLocUtils.t("Dialogs","BeehiveBuilding_FullBuilding");
            canEnableMode = false;
         }
         if(canEnableMode)
         {
            super.enableMode();
         }
         else if(messageText)
         {
            UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_OK,this.onEnableModeErrorClosed));
         }
      }
      
      private function onEnableModeErrorClosed(event:GenericPopupEvent) : void
      {
         if(this.m_isGift)
         {
            UI.displayGiftBoxWindow();
         }
         else if(this.m_isHive)
         {
            if(this.m_building)
            {
               UI.displayPopup(new BeehiveWindow(this.m_building as BeehiveBuilding));
            }
         }
         else
         {
            UI.displayMarketDialog("GMBeehiveItemPlace",MarketWindow.previousType,null,MarketWindow.previousSubType);
         }
         Global.world.popGameMode();
      }
      
      override protected function onFinishModifyBuilding(modifiedBuilding:Boolean, hasABuilding:Boolean, isFirstEntry:Boolean) : void
      {
         var messageFull:String = null;
         var messageMissing:String = null;
         if(modifiedBuilding)
         {
            if(m_isGift)
            {
               reOpenGiftIfNecessary();
            }
            else
            {
               Global.player.tryBuy(m_itemToAdd);
            }
         }
         else if(hasABuilding)
         {
            messageFull = ZLocUtils.t("Dialogs",m_creditsBuildingName + "_FullBuilding");
            UI.displayMessage(messageFull);
         }
         else
         {
            messageMissing = ZLocUtils.t("Dialogs",m_creditsBuildingName + "_NoBuilding");
            UI.displayMessage(messageMissing,GenericPopup.TYPE_ACCEPTCANCEL,this.noBuildingCallback);
         }
      }
      
      private function noBuildingCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayGiftBoxWindow(true);
         }
      }
   }
}

