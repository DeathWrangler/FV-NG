package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Events.UIEvent;
   import Managers.FarmStatsManager;
   import Managers.MapResourceHelper;
   import Managers.OrganicFertilizerHelper;
   import Transactions.TRefreshGifts;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Instagrow.InstagrowSelectionFrame;
   import flash.events.Event;
   
   public class OrganicFertilizerWindow extends FarmWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_SuperFertilizer.swf";
      
      public static const WHATISTHIS_ITEM_NAME:String = "OrganicFertilizerTutorial";
      
      private var m_organicFertilizerHelper:OrganicFertilizerHelper = null;
      
      private var m_cropsFrame:InstagrowSelectionFrame = null;
      
      private var m_freeUse:Boolean = false;
      
      public function OrganicFertilizerWindow(organicFertilizerHelper:OrganicFertilizerHelper, freeUse:Boolean = false)
      {
         super(DIALOG_ASSET);
         this.m_organicFertilizerHelper = organicFertilizerHelper;
         this.m_freeUse = freeUse;
      }
      
      private static function onMoreInfo(event:Event) : void
      {
         onMoreInfoHelper();
      }
      
      private static function onMoreInfoHelper() : void
      {
         TutorialUI.displayTutorialWindowForItem(WHATISTHIS_ITEM_NAME,"Dialogs:" + WHATISTHIS_ITEM_NAME + "_Title","assets/dialogs/4d_elements/SuperFertilizer/SuperFertilizer");
      }
      
      private function isFree() : Boolean
      {
         return this.m_freeUse || OrganicFertilizerHelper.playerHasOrganicFertilizerInGiftbox();
      }
      
      override protected function postLoadComplete() : void
      {
         var totalCostText:String = null;
         var totalCost:Number = NaN;
         var hasResourcesToApplyTo:Boolean = this.m_organicFertilizerHelper.hasResourcesToActOn();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","OrganicFertilizer_DialogHeader")));
         if(Boolean(m_window.bodycopy_mc) && Boolean(m_window.bodycopy_mc.body_tf))
         {
            addWidget(new ZwFrame(m_window.bodycopy_mc));
            addWidget(new ZwTextField(m_window.bodycopy_mc.body_tf,ZLocUtils.t("Dialogs","OrganicFertilizer_DialogSubHeading")));
         }
         if(OrganicFertilizerHelper.isInSuperFertExperiment() && this.m_freeUse)
         {
            this.displayCongratsMessage();
            onMoreInfoHelper();
         }
         var cropsCost:int = this.m_organicFertilizerHelper.calculateCost(MapResourceHelper.TYPE_PLOTS);
         var costIsFree:Boolean = this.isFree();
         this.m_cropsFrame = new InstagrowSelectionFrame(m_window.crops_mc,MapResourceHelper.TYPE_PLOTS,cropsCost,this.onSelectionFrameToggle,costIsFree);
         this.m_cropsFrame.setSelected(cropsCost > 0);
         addWidget(this.m_cropsFrame,hasResourcesToApplyTo);
         addWidget(new ZwTextField(m_window.text_tf,ZLocUtils.t("FarmGame","Cost")),hasResourcesToApplyTo);
         if(costIsFree)
         {
            totalCostText = ZLocUtils.t("Dialogs","Free");
         }
         else
         {
            totalCost = this.m_organicFertilizerHelper.calculateCost(MapResourceHelper.TYPE_ALL);
            totalCostText = totalCost.toString();
         }
         addWidget(new ZwTextField(m_window.price_tf,totalCostText),hasResourcesToApplyTo);
         addWidget(new FarmAnimatedTextButton(m_window.growNow_bt,ZLocUtils.t("Dialogs","OrganicFertilizer_BuyButton"),this.onBuyButton),hasResourcesToApplyTo);
         addWidget(new FarmAnimatedTextButton(m_window.moreInfo_bt,ZLocUtils.t("Dialogs","MoreInfo"),onMoreInfo),hasResourcesToApplyTo);
         StatsManager.count(OrganicFertilizerHelper.FEATURE_NAME,StatsTrackingConstants.MAIN_UI,StatsTrackingConstants.IMPRESSIONS);
      }
      
      private function displayCongratsMessage() : void
      {
         var text:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"superFertilizerGiftCongrats");
         var popupType:int = GenericPopup.TYPE_ACCEPTCANCEL;
         var closeHandler:Function = this.onCongratsMessageClosed;
         UI.displayMessage(text,popupType,closeHandler,"",true);
      }
      
      private function onCongratsMessageClosed(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onBuyButtonClickedHelper();
         }
      }
      
      private function onSelectionFrameToggle(event:Event) : void
      {
         var button:FarmAnimatedTextButton = getWidget(m_window.growNow_bt) as FarmAnimatedTextButton;
         if(!this.m_cropsFrame.getSelected())
         {
            button.applyGrayOut = true;
            button.enabled = false;
         }
         else
         {
            button.applyGrayOut = false;
            button.enabled = true;
         }
         this.updateWindow(this.calculateCost());
      }
      
      private function updateWindow(aCost:Number) : void
      {
         var priceText:ZwTextField = null;
         var discountPriceText:ZwTextField = null;
         if(m_window)
         {
            priceText = getWidget(m_window.price_tf) as ZwTextField;
            discountPriceText = getWidget(m_window.discountPrice_tf) as ZwTextField;
            if(priceText)
            {
               if(this.isFree())
               {
                  priceText.text = ZLocUtils.t("Dialogs","Free");
               }
               else
               {
                  priceText.text = aCost.toString();
               }
            }
            if(discountPriceText)
            {
               discountPriceText.text = "not used";
            }
         }
      }
      
      private function consumeOrganicFertilizerInGiftboxCallback(event:Event) : void
      {
         Global.ui.removeEventListener(UIEvent.GIFTBOX_UNLOCKED,this.consumeOrganicFertilizerInGiftboxCallback);
         if(!OrganicFertilizerHelper.consumeOrganicFertilizerInGiftbox())
         {
            FarmStatsManager.count("organicFertilizer","delayedConsumeFail");
         }
         this.updateWindow(this.calculateCost());
      }
      
      private function onBuyButton(event:Event) : void
      {
         this.onBuyButtonClickedHelper();
      }
      
      private function onBuyButtonClickedHelper() : void
      {
         var canBuy:Boolean = false;
         var costIsFree:Boolean = this.isFree();
         var execute:Boolean = false;
         var cost:int = this.calculateCost();
         if(costIsFree)
         {
            execute = OrganicFertilizerHelper.consumeOrganicFertilizerInGiftbox();
            if(!execute && this.m_freeUse)
            {
               if(TRefreshGifts.isRefreshing())
               {
                  Global.ui.addEventListener(UIEvent.GIFTBOX_UNLOCKED,this.consumeOrganicFertilizerInGiftboxCallback);
               }
               else
               {
                  OrganicFertilizerHelper.consumeOrganicFertilizerInGiftbox();
               }
               execute = true;
            }
         }
         else
         {
            canBuy = Global.player.canBuyCash(cost);
            if(canBuy && cost > 0)
            {
               Global.player.cash -= cost;
               execute = true;
            }
         }
         if(execute)
         {
            this.m_organicFertilizerHelper.execute();
            this.m_organicFertilizerHelper.sendTransaction();
            close();
         }
         BushelReportWindow.conditionallyRefreshWindow();
         StatsManager.count(OrganicFertilizerHelper.FEATURE_NAME,StatsTrackingConstants.MAIN_UI,StatsTrackingConstants.CLICKS);
      }
      
      private function calculateCost() : int
      {
         var applyType:uint = 0;
         if(this.m_cropsFrame.getSelected())
         {
            applyType |= MapResourceHelper.TYPE_PLOTS;
         }
         return this.m_organicFertilizerHelper.calculateCost(applyType);
      }
      
      override protected function onClose(event:Event) : void
      {
         close();
         OrganicFertilizerHelper.showToasterFreeInGiftbox();
      }
   }
}

