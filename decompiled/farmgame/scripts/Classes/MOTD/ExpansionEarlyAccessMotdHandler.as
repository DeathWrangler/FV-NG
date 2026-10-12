package Classes.MOTD
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.WorldStatManager;
   import flash.events.Event;
   
   public class ExpansionEarlyAccessMotdHandler extends ExpansionAccessMotdHandler
   {
      
      protected static const EARLY_ACCESS_TYPE:String = "earlyAccess";
      
      public static const EA_CONFIRMATION_UNIQUE_NAME:String = "eaConfirmationDialog";
      
      public function ExpansionEarlyAccessMotdHandler(currentMOTD:Object, addPopupToQueue:Boolean = true)
      {
         super(currentMOTD,addPopupToQueue);
      }
      
      override protected function get assetPath() : String
      {
         return m_expansionData.motdAssets[this.earlyAccessType][ExpansionData.KEY_ASSET];
      }
      
      protected function get earlyAccessType() : String
      {
         return EARLY_ACCESS_TYPE;
      }
      
      override protected function get accessType() : String
      {
         return ExpansionAccess.TYPE_EARLY;
      }
      
      override protected function get onBoardingWindowClass() : String
      {
         var windowClass:String = m_expansionData.motdAssets[this.earlyAccessType][ExpansionData.KEY_WINDOWCLASS];
         if(windowClass == null || windowClass == "")
         {
            windowClass = "Widgets.Windows.Expansion.ExpansionOnboardingWindow";
         }
         return windowClass;
      }
      
      override public function execute() : void
      {
         if(m_expansionData)
         {
            WorldStatManager.trackWorldOnboardingDialog(m_expansionData.worldId,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         }
         super.execute();
      }
      
      override protected function get brochureButtonZLocKey() : String
      {
         return "ExpansionsOnboardingTicketButtonText_Early";
      }
      
      override protected function acceptMOTD() : void
      {
         ztrack("confirm_dialog");
         UI.displayMessage(ZLocUtils.t("Dialogs","EA_MOTD_Confirmation_Body",{"price":m_access.cashCost}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmationFinished,EA_CONFIRMATION_UNIQUE_NAME,true,true);
      }
      
      protected function onConfirmationFinished(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onAcceptConfirmation();
         }
         else
         {
            this.closeMOTD();
         }
      }
      
      protected function onAcceptConfirmation() : void
      {
         var cost:int = m_access.cashCost;
         var optionId:String = this.m_expansionOnboardingWindow.getOptionId();
         if(optionId != null)
         {
            cost = m_access.getOptionCost(optionId);
         }
         if(this.m_expansionOnboardingWindow.getCurrencyType() == FarmItem.MARKET_CONTEXT_CASH)
         {
            if(m_expansionData)
            {
               WorldStatManager.trackWorldOnboardingDialog(m_expansionData.worldId,"buy_fc");
            }
            if(Global.player.canBuyCash(cost,true,m_access.type))
            {
               Global.player.cash -= cost;
               super.acceptMOTD();
            }
            else
            {
               dispatchEvent(new GenericPopupEvent(Event.COMPLETE,GenericPopup.CANCEL));
            }
         }
         else if(this.m_expansionOnboardingWindow.getCurrencyType() == FarmItem.MARKET_CONTEXT_COINS)
         {
            if(m_expansionData)
            {
               WorldStatManager.trackWorldOnboardingDialog(m_expansionData.worldId,"buy_coin");
            }
            if(Global.player.canBuy(cost,true,m_access.type))
            {
               Global.player.gold -= cost;
               super.acceptMOTD();
            }
            else
            {
               dispatchEvent(new GenericPopupEvent(Event.COMPLETE,GenericPopup.CANCEL));
            }
         }
      }
      
      override protected function closeMOTD() : void
      {
         if(m_expansionData)
         {
            WorldStatManager.trackWorldOnboardingDialog(m_expansionData.worldId,StatsTrackingConstants.STATS_X);
         }
         super.closeMOTD();
      }
   }
}

