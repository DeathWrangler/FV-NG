package Widgets.Windows.Charity
{
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.LicenseManager;
   import Transactions.TAcquireLicense;
   
   public class FCDonateWindow extends DonateWindow
   {
      
      public function FCDonateWindow(seedData:SeedItem, onAcceptCallback:Function = null, source:String = null)
      {
         super(seedData,onAcceptCallback,source);
      }
      
      override protected function onDonate(code:String) : void
      {
         if(Global.player.canBuyCash(donateAmount,false))
         {
            if(!LicenseManager.getInstance().hasCurrentLicense(m_seedItem.code))
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  TransactionManager.addTransaction(new TAcquireLicense(null,code,this.onLicenseGranted,m_seedItem.getStringFromDataSource("name")),true);
               }
               else
               {
                  TransactionManager.addTransaction(new TAcquireLicense(m_seedItem.xml,code,this.onLicenseGranted),true);
               }
            }
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","BuyCashDialog"),GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyCash,"",true);
         }
         UI.closeMarketDialog();
         super.onDonate(code);
      }
      
      private function onBuyCash(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            FarmStatsManager.count("fv_cash_buy_fail",m_seedItem.name,"click_accept");
         }
         else
         {
            FarmStatsManager.count("fv_cash_buy_fail",m_seedItem.name,"click_cancel");
         }
      }
      
      private function onLicenseGranted(result:Object) : void
      {
         if(result)
         {
            Global.player.cash -= donateAmount;
            Global.player.addGift(result.gift);
            UI.displayPopup(new DonateThanksWindow(m_seedItem,result.friendRewardName,result.friendRewardLink),false);
         }
      }
   }
}

