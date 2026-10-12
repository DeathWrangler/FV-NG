package Widgets.Windows.LESet
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.LESurfacingManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LESet.LESurfacingSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LESurfacingWindow extends FarmWindow
   {
      
      private static const NUMBER_ITEMS_PER_TYPE_SORTING:int = 3;
      
      private var m_leSet:Array;
      
      private var m_frame:LESurfacingSlotFrame;
      
      private var m_featureName:String = "le_display_promo";
      
      private var m_buyAllBtn:FarmAnimatedCashButton;
      
      public function LESurfacingWindow(leSet:Array, featureName:String = null)
      {
         var assetUrl:String = "assets/dialogs/FV_LESurfacing.swf";
         if(getImpExpVariant() > 1)
         {
            assetUrl = "assets/dialogs/FV_LESurfacing2_generic.swf";
         }
         super(assetUrl);
         this.m_leSet = leSet;
         if(featureName != null)
         {
            this.m_featureName = featureName;
         }
      }
      
      public static function getImpExpVariant() : int
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_IMPROVED_LE_DIALOG);
      }
      
      override protected function postLoadComplete() : void
      {
         var btnText:String = null;
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","LESurfacingWindowTitle")));
         var slotFrame:MovieClip = m_window.slotFrame_mc;
         var variant:int = getImpExpVariant();
         switch(variant)
         {
            case 2:
               slotFrame = m_window.slotFrame1_mc;
               break;
            case 3:
               this.m_leSet = Global.marketRecommendations.sortItemsByRecomended(this.m_leSet,NUMBER_ITEMS_PER_TYPE_SORTING);
               slotFrame = m_window.slotFrame1_mc;
               break;
            case 4:
               slotFrame = m_window.slotFrame0_mc;
         }
         if(slotFrame)
         {
            this.m_frame = new LESurfacingSlotFrame(slotFrame,this.m_leSet,this,this.m_featureName);
            addWidget(this.m_frame);
         }
         if(variant > 1 && m_window.hasOwnProperty("completeNow_bt"))
         {
            btnText = ZLocUtils.t("Dialogs","LESurfacingWindowBuyAll");
            this.m_buyAllBtn = addWidget(new FarmAnimatedCashButton(m_window.completeNow_bt,btnText,String(this.getBuyAllPrice()),this.handleBuyAllClicked)) as FarmAnimatedCashButton;
         }
         FarmStatsManager.count(this.m_featureName,"dialog","le_display_" + this.pageNumber,"view");
      }
      
      private function onConfirmBuyAll(e:GenericPopupEvent) : void
      {
         if(e.button == GenericPopup.ACCEPT)
         {
            if(Global.player.canBuyCash(this.getBuyAllPrice()))
            {
               this.m_frame.buyItemsFromSlots();
            }
         }
      }
      
      private function handleBuyAllClicked(event:MouseEvent) : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","LESurfacingWindow_buy_all_confirmation",{"amount":this.getBuyAllPrice()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyAll,"LESurfacingBuyAll",true);
      }
      
      private function getBuyAllPrice() : int
      {
         return this.m_frame.getTotalPriceForShownItems();
      }
      
      public function get pageNumber() : uint
      {
         return this.m_frame.pageNumber;
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(this.m_featureName,"dialog","le_display_" + this.pageNumber,"click_cancel");
         super.onClose(event);
         var v2Variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_SURFACING_V2);
         if(v2Variant >= 5)
         {
            UI.displayMarketDialog(this.m_featureName,"limited",null,"all",null,null,"limitedStart","desc");
         }
         Global.player.setFeatureLastShown(LESurfacingManager.LE_SURFACING_DISMISS_FLAG,GlobalEngine.serverTime,true);
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         if(this.m_buyAllBtn)
         {
            this.m_buyAllBtn.setAmountText(String(this.getBuyAllPrice()));
         }
      }
   }
}

