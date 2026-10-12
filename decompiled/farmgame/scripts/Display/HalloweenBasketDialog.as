package Display
{
   import Classes.HalloweenBasket;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import GameMode.GMCreditsBuildingItemPlace;
   import Managers.FarmStatsManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class HalloweenBasketDialog extends RewardCreditsBuildingDialog
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_HalloweenBasket.swf";
      
      private static const LOCKED_ITEM_ICON_URL:String = "assets/decorations/easter_lockedegg_icon.png";
      
      private static const STR_BUILDING_ITEM_NAME:String = "halloweenBasket";
      
      private static const STR_LOCALE_BUILDING_PREFIX:String = "HalloweenBasket";
      
      private static const STR_LOCALE_TOKEN_HOWDOESTHISWORK:String = STR_LOCALE_BUILDING_PREFIX + "_HowDoesThisWork";
      
      private static const STR_GAMESETTINGS_TOKEN_DISABLE_DATE:String = "halloweenBasketAskSendDisableDate";
      
      private var m_buyCreditsBtn:GenericButton = null;
      
      protected var m_creditsItemToBuy:FarmItem = null;
      
      public function HalloweenBasketDialog(halloweenBasket:HalloweenBasket, showWhatIsThisOnLoad:Boolean = false, alwaysUnlock:Boolean = true)
      {
         super(halloweenBasket,STR_LOCALE_BUILDING_PREFIX,DIALOG_ASSET,showWhatIsThisOnLoad,alwaysUnlock);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         if(m_window != null)
         {
            this.m_buyCreditsBtn = new GenericButton(m_window.buyCandy_mc,this.onBuyCredits);
         }
      }
      
      private function onBuyCredits(event:MouseEvent = null) : void
      {
         if(this.m_shown)
         {
            this.hide();
         }
         FarmStatsManager.count(this.getAskForCreditsCounter(),"purchase_candy");
         this.m_creditsItemToBuy = Global.farmGameSettingsManager.getFarmItemByName(HalloweenBasket.HALLOWEEN_CANDY_5);
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(this.m_creditsItemToBuy.friendlyName),
            "cashQuantity":this.m_creditsItemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyConfirmation),false);
         onClose(event);
      }
      
      private function onBuyConfirmation(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT && this.m_creditsItemToBuy != null)
         {
            FarmStatsManager.count(this.getAskForCreditsCounter(),"purchase_candy","accept");
            if(Global.player.canBuyCash(this.m_creditsItemToBuy.cash,false))
            {
               Global.world.addGameMode(new GMCreditsBuildingItemPlace(this.m_creditsItemToBuy.name,false),false);
            }
            else
            {
               FarmStatsManager.count(this.getAskForCreditsCounter(),"purchase_candy","not_enough_cash");
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_creditsItemToBuy.cash,this.m_creditsItemToBuy.type);
            }
         }
         close();
      }
      
      override protected function getAskForCreditsCounter() : String
      {
         return STR_BUILDING_ITEM_NAME;
      }
      
      override protected function getAskForCreditsFeatureName() : String
      {
         return HalloweenBasket.ASK_FOR_CREDITS_FEATURE_NAME;
      }
      
      override protected function getDialogSideIconUrl() : String
      {
         return HalloweenBasket.DIALOG_SIDE_ICON;
      }
      
      override protected function getLockedItemIconUrl() : String
      {
         return LOCKED_ITEM_ICON_URL;
      }
      
      override protected function getBuildingCreditsXml() : XML
      {
         return Global.farmGameSettingsManager.getBuildingCreditsXml(STR_BUILDING_ITEM_NAME);
      }
      
      override protected function getAskSendDisableDate() : String
      {
         return Global.farmGameSettingsManager.getString(STR_GAMESETTINGS_TOKEN_DISABLE_DATE);
      }
      
      override protected function onHowDoesThisWorkClick(event:Event = null) : void
      {
         var msg:String = null;
         if(!m_howDoesThisWorkPopup)
         {
            msg = ZLocUtils.t("Dialogs",STR_LOCALE_TOKEN_HOWDOESTHISWORK);
            m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,this.onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET,"",true);
            UI.displayPopup(m_howDoesThisWorkPopup,false,m_buildingClassName + "_howDoesThisWorkPopup",true);
         }
      }
      
      override protected function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         m_howDoesThisWorkPopup = null;
      }
      
      override protected function getNumMeterFrames() : Number
      {
         var numFrames:Number = 0;
         var meterStack:MovieClip = getMeterStack();
         if(meterStack)
         {
            numFrames = meterStack.totalFrames;
         }
         return numFrames;
      }
      
      override protected function disableAskForCreditsButton() : void
      {
         super.disableAskForCreditsButton();
      }
   }
}

