package Widgets.Windows
{
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.TropicalMarketInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class TropicalMarketInnovationLimitedStoragePopup extends FarmWindow
   {
      
      private static const FEATURE_TRACKING:String = "TropicalMarketInnovation";
      
      private static const FEATURE_NAME:String = "TropicalMarketInnovation";
      
      private var m_featureName:String = null;
      
      private var m_upgrade_bt:FarmAnimatedCashButton;
      
      private var m_contrinue_bt:FarmAnimatedTextButton;
      
      private var m_slotNumber:int;
      
      private var m_isSkip:Boolean;
      
      public function TropicalMarketInnovationLimitedStoragePopup(featureName:String = "TropicalMarketInnovation", assetUrl:String = null, slotIndex:int = -1, isSkip:Boolean = false)
      {
         this.m_featureName = featureName;
         super(assetUrl,true,true);
         this.m_slotNumber = slotIndex;
         this.m_isSkip = isSkip;
      }
      
      override protected function postLoadComplete() : void
      {
         var amount:int = 0;
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Limited Storage!"));
         }
         if(m_window.hasOwnProperty("upgrade_bt"))
         {
            amount = this.manager.getCostToUpgradeLevel();
            addWidget(this.m_upgrade_bt = new FarmAnimatedCashButton(m_window["upgrade_bt"],"Upgrade",amount.toString(),this.onStorageUpgradeClick));
            this.m_upgrade_bt.enabled = amount == 0 ? false : true;
         }
         if(m_window.hasOwnProperty("sell_bt"))
         {
            addWidget(this.m_contrinue_bt = new FarmAnimatedTextButton(m_window["sell_bt"],"Continue",this.onContinueButtonClick));
         }
      }
      
      private function onContinueButtonClick(e:Event = null) : void
      {
         var remainingSpace:int = 0;
         if(this.m_slotNumber != -1)
         {
            remainingSpace = this.manager.currentStorageCapacity - this.manager.getCurrentProduceQty();
            if(this.m_isSkip)
            {
               this.manager.addRemainingOBPointsOnSkip(this.m_slotNumber,null,remainingSpace);
            }
            else
            {
               this.manager.addRemainingOBPoints(this.m_slotNumber,null,remainingSpace);
            }
            if(this.manager.mainWindow)
            {
               this.manager.mainWindow.refreshTaskFrame();
               this.manager.mainWindow.refreshWindow();
            }
         }
      }
      
      private function get manager() : TropicalMarketInnovationManager
      {
         return TropicalMarketInnovationManager.getInstance(FEATURE_NAME);
      }
      
      private function onStorageUpgradeClick(e:Event = null) : void
      {
         var confirmationMessage:String = "Do you want to spend " + this.manager.getCostToUpgradeLevel().toString() + " FC to upgrade the storage capacity to " + this.manager.nextStorageCapacity.toString();
         UI.displayMessage(confirmationMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompleteAccept,"",true);
      }
      
      private function onConfirmCompleteAccept(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.manager.upgradeStorageCapacity();
         }
         else
         {
            FarmStatsManager.count(FEATURE_NAME,"CancelPurchase");
         }
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.close();
         FarmStatsManager.count("FEATURE_TRACKING","TropicalMarketInnovationLimitedStoragePopup","close_window");
      }
   }
}

