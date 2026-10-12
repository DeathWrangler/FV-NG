package Display
{
   import Classes.InventoryCellar;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class InventoryCellarDialog extends RewardCreditsBuildingDialog
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_CellarArcade1_3.swf";
      
      private static const LOCKED_ITEM_ICON_URL:String = "assets/decorations/cellar_locked_icon.png";
      
      private static const INVENTORY_BT:String = "invBt";
      
      private static const BUY_BT:String = "buyBt";
      
      private static const SHOVEL_MARKET_ITEM_NAME:String = "shovel_item_01";
      
      private static const METER_HOLE_BOTTOM_Y_OFFSET:int = 6;
      
      private static const NUM_METER_INTERVALS:int = 6;
      
      private var m_meterMaskTotalHeight:int = 0;
      
      public function InventoryCellarDialog(inventoryCellar:InventoryCellar, showWhatIsThisOnLoad:Boolean = false)
      {
         super(inventoryCellar,"InventoryCellar",DIALOG_ASSET,showWhatIsThisOnLoad);
         m_totalCreditsReceived = inventoryCellar.capacity;
      }
      
      override protected function getAskForCreditsFeatureName() : String
      {
         return InventoryCellar.ASK_FOR_CREDITS_FEATURE_NAME;
      }
      
      override protected function getDialogSideIconUrl() : String
      {
         return InventoryCellar.DIALOG_SIDE_ICON;
      }
      
      override protected function getLockedItemIconUrl() : String
      {
         return LOCKED_ITEM_ICON_URL;
      }
      
      override protected function getBuildingCreditsXml() : XML
      {
         return Global.farmGameSettingsManager.getBuildingCreditsXml("InventoryCellar");
      }
      
      override protected function isAskSendEnabled() : Boolean
      {
         return true;
      }
      
      override protected function setupButtons() : void
      {
         super.setupButtons();
         var inventoryButton:GenericButton = new GenericButton(m_window.inventory_bt,this.onClickInventory);
         inventoryButton.text = ZLocUtils.t("Dialogs","InventoryCellar_InventoryButton");
         m_buttons[INVENTORY_BT] = inventoryButton;
         var buyButton:GenericButton = new GenericButton(m_window.accept_bt,this.onClickBuy);
         buyButton.text = ZLocUtils.t("Dialogs","InventoryCellar_BuyButton");
         m_buttons[BUY_BT] = buyButton;
      }
      
      private function onClickInventory(event:Event) : void
      {
         close();
         UI.displayInventoryDialog();
      }
      
      private function onClickBuy(event:Event) : void
      {
         close();
         if(m_totalCreditsReceived >= m_rewardCreditsBuilding.maxPotentialCapacity)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","InventoryCellar_MaxCredits"));
         }
         UI.displayMiniMarketDialog([SHOVEL_MARKET_ITEM_NAME],"inventorycellar","building",null);
      }
      
      override protected function refreshMeterTitle() : void
      {
         m_window.status_tf.text = getLevelTitle(m_totalCreditsReceived);
      }
      
      override protected function refreshCreditMeter() : void
      {
         super.refreshCreditMeter();
         if(this.m_meterMaskTotalHeight > 0)
         {
            m_window.progress_mc.meter_mc.mask_mc.height = Math.min(this.m_meterMaskTotalHeight,this.m_meterMaskTotalHeight * (m_totalCreditsReceived / getMeterMaxCredits()));
            m_window.progress_mc.meter_mc.holeBottom_mc.y = m_window.progress_mc.meter_mc.mask_mc.height - METER_HOLE_BOTTOM_Y_OFFSET;
         }
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         ZLocUtils.setText(m_window,"progress_mc.generic_tf","Dialogs","FV_CellarArcade1_3.key1");
         this.m_meterMaskTotalHeight = m_window.progress_mc.meter_mc.mask_mc.height;
         this.refreshCreditMeter();
         FarmStatsManager.count("InventoryCellar","open_cellar");
      }
      
      override protected function onHowDoesThisWorkClick(event:Event = null) : void
      {
         var msg:String = null;
         var genericPopup:GenericPopup = null;
         if(!m_howDoesThisWorkPopup)
         {
            msg = ZLocUtils.t("Dialogs",m_buildingClassName + "_HowDoesThisWork_06222011");
            genericPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET,"",true);
            genericPopup.setAcceptTextName("Okay");
            m_howDoesThisWorkPopup = genericPopup;
            UI.displayPopup(m_howDoesThisWorkPopup,false,m_buildingClassName + "_howDoesThisWorkPopup",true);
         }
      }
      
      override protected function setupCreditMeterIntervals(creditMeter:MovieClip) : void
      {
         var incrementTextFieldName:String = null;
         var increment_tf:TextField = null;
         var maxCredits:int = int(getMeterMaxCredits());
         for(var interval:uint = 0; interval < NUM_METER_INTERVALS; interval++)
         {
            incrementTextFieldName = "increment" + interval + "_tf";
            if(creditMeter.hasOwnProperty(incrementTextFieldName))
            {
               increment_tf = creditMeter.getChildByName(incrementTextFieldName) as TextField;
               increment_tf.text = String(interval / (NUM_METER_INTERVALS - 1) * maxCredits);
            }
         }
      }
   }
}

