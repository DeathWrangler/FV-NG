package Display
{
   import Classes.EasterBasket;
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import flash.events.Event;
   
   public class EasterBasketDialog extends RewardCreditsBuildingDialog
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_Easter.swf";
      
      private static const LOCKED_ITEM_ICON_URL:String = "assets/decorations/easter_lockedegg_icon.png";
      
      public function EasterBasketDialog(easterBasket:EasterBasket, showWhatIsThisOnLoad:Boolean = false)
      {
         super(easterBasket,"EasterBasket",DIALOG_ASSET,showWhatIsThisOnLoad);
      }
      
      override protected function getAskForCreditsFeatureName() : String
      {
         return EasterBasket.ASK_FOR_CREDITS_FEATURE_NAME;
      }
      
      override protected function getDialogSideIconUrl() : String
      {
         return EasterBasket.DIALOG_SIDE_ICON;
      }
      
      override protected function getLockedItemIconUrl() : String
      {
         return LOCKED_ITEM_ICON_URL;
      }
      
      override protected function getBuildingCreditsXml() : XML
      {
         return Global.farmGameSettingsManager.getBuildingCreditsXml("easterBasket");
      }
      
      override protected function getAskSendDisableDate() : String
      {
         return Global.farmGameSettingsManager.getString("springBasketAskSendDisableDate");
      }
      
      override protected function onHowDoesThisWorkClick(event:Event = null) : void
      {
         var msg:String = null;
         var genericPopup:GenericPopup = null;
         if(!m_howDoesThisWorkPopup)
         {
            msg = ZLocUtils.t("Dialogs","EasterBasket_HowDoesThisWork");
            genericPopup = new GenericPopup(msg,GenericPopup.TYPE_ACCEPTCANCEL,this.onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET_LRG,"",true);
            genericPopup.setAcceptTextName("Invite");
            m_howDoesThisWorkPopup = genericPopup;
            UI.displayPopup(m_howDoesThisWorkPopup,false,m_buildingClassName + "_howDoesThisWorkPopup",true);
         }
      }
      
      override protected function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         if(GenericPopup.ACCEPT == event.button)
         {
            GlobalEngine.socialNetwork.redirect("invite.php?ref=neighborsInvitePage&creative=springBasket");
         }
         m_howDoesThisWorkPopup = null;
      }
      
      override protected function disableAskForCreditsButton() : void
      {
         super.disableAskForCreditsButton();
         m_window.eggs_mc.visible = false;
      }
   }
}

