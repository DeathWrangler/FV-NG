package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FlowerShackManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FlowerShackSlotContainerFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FlowerShackWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const SUB_TITLE_TXT:String = "subtitle1_tf";
      
      private static const FLOWER_MC:String = "main_mc";
      
      private static const WHAT_IS_THIS:String = "whatisthis_mc";
      
      private static const TITLE_TXT:String = "title_tf";
      
      private static const FRAME_MC:String = "frame_mc";
      
      private static const ASK_BTN:String = "ask_bt";
      
      private static const BUY_BTN:String = "buy_bt";
      
      private static const PLANT_BTN:String = "plant_bt";
      
      private static const NUTURE_BTN:String = "nuture_bt";
      
      private static const SLOT_MC:String = "slot_mc";
      
      private static const CURRENCY_MC:String = "currency_mc";
      
      private static const NECTAR_COUNT_TXT:String = "countStars_tf";
      
      private static const PAGE_TXT:String = "page_tf";
      
      private var m_featureName:String = FlowerShackManager.FEATURE_NAME;
      
      private var m_titleTextField:FarmTextField;
      
      private var m_flowerMc:ZwWidget;
      
      private var m_frameMc:MovieClip;
      
      private var m_currencyAskButton:FarmAnimatedTextButton;
      
      private var m_buyBtn:FarmAnimatedTextButton;
      
      private var m_plantBtn:FarmAnimatedTextButton;
      
      private var m_nutureBtn:FarmAnimatedTextButton;
      
      private var m_slotMc:FlowerShackSlotContainerFrame;
      
      private var m_nectarTxt:FarmTextField;
      
      private var m_pageTxt:FarmTextField;
      
      public function FlowerShackWindow(assetUrl:String = "assets/dialogs/FlowerShack/FV_FlowerShack2015.swf")
      {
         super(this.m_featureName,assetUrl,NUM_TUTORIAL_SCENES);
         FlowerShackManager.getInstance(this.m_featureName).initFeature();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(TITLE_TXT))
         {
            this.m_titleTextField = new FarmTextField(m_window[TITLE_TXT],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_title_txt"),true);
            if(this.m_titleTextField)
            {
               addWidget(this.m_titleTextField);
            }
         }
         if(m_window.hasOwnProperty(FLOWER_MC))
         {
            this.m_flowerMc = addWidget(new ZwWidget(m_window[FLOWER_MC]),true) as ZwWidget;
         }
         if(this.m_flowerMc)
         {
            if(this.m_flowerMc.element.hasOwnProperty(PAGE_TXT))
            {
               addWidget(this.m_pageTxt = new FarmTextField(this.m_flowerMc.element[PAGE_TXT],""));
            }
            if(this.m_flowerMc.element.hasOwnProperty(SUB_TITLE_TXT))
            {
               addWidget(new ZwTextField(this.m_flowerMc.element[SUB_TITLE_TXT],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_sub_title_txt")),true);
            }
            if(this.m_flowerMc.element.hasOwnProperty(ASK_BTN))
            {
               this.m_currencyAskButton = addWidget(new FarmAnimatedTextButton(this.m_flowerMc.element[ASK_BTN],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_ask_btn_txt"),this.onAskButtonClick),true) as FarmAnimatedTextButton;
            }
            if(this.m_flowerMc.element.hasOwnProperty(BUY_BTN))
            {
               this.m_buyBtn = addWidget(new FarmAnimatedTextButton(this.m_flowerMc.element[BUY_BTN],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_buy_btn_txt"),this.onBuyButtonClick),true) as FarmAnimatedTextButton;
            }
            if(this.m_flowerMc.element.hasOwnProperty(PLANT_BTN))
            {
               this.m_plantBtn = addWidget(new FarmAnimatedTextButton(this.m_flowerMc.element[PLANT_BTN],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_plant_btn_txt"),this.onPlantButtonClick),true) as FarmAnimatedTextButton;
            }
            if(this.m_flowerMc.element.hasOwnProperty(NUTURE_BTN))
            {
               this.m_nutureBtn = addWidget(new FarmAnimatedTextButton(this.m_flowerMc.element[NUTURE_BTN],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_nuture_btn_txt"),this.onNutureButtonClick),true) as FarmAnimatedTextButton;
            }
            if(this.m_flowerMc.element.hasOwnProperty(SLOT_MC))
            {
               this.m_slotMc = new FlowerShackSlotContainerFrame(this.m_flowerMc.element[SLOT_MC],this,this.m_featureName);
               addWidget(this.m_slotMc,true);
            }
            if(this.m_flowerMc.element.hasOwnProperty(CURRENCY_MC))
            {
               if(this.m_flowerMc.element[CURRENCY_MC].hasOwnProperty(NECTAR_COUNT_TXT))
               {
                  this.m_nectarTxt = new FarmTextField(this.m_flowerMc.element[CURRENCY_MC][NECTAR_COUNT_TXT],this.playerNectarCount + "/" + FlowerShackManager.getInstance(this.m_featureName).MAX_NECTAR);
                  addWidget(this.m_nectarTxt);
               }
            }
         }
         if(m_window.hasOwnProperty(FRAME_MC))
         {
            this.m_frameMc = m_window[FRAME_MC];
            this.m_frameMc.visible = true;
         }
         if(m_window.hasOwnProperty(WHAT_IS_THIS))
         {
            addWidget(new ZwButton(m_window[WHAT_IS_THIS],this.onHowDoesThisWorkClick));
         }
         var shouldShow:Boolean = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(FlowerShackManager.getInstance(this.m_featureName).ASK_FEED_FREQUENCY_KEY) >= FlowerShackManager.getInstance(this.m_featureName).ASK_FEED_FREQUENCY;
         if(this.m_currencyAskButton)
         {
            if(shouldShow && this.playerNectarCount < FlowerShackManager.getInstance(this.m_featureName).MAX_NECTAR)
            {
               this.toggleButton(this.m_currencyAskButton,true);
            }
            else
            {
               this.disableAskButton();
            }
         }
         this.enableNurtureBtn();
      }
      
      public function updatePagination(curr:Number, total:Number) : void
      {
         if(this.m_pageTxt)
         {
            this.m_pageTxt.text = curr + 1 + "/" + (total + 1);
         }
      }
      
      private function disableAskButton() : void
      {
         var infoTooltip:FarmTextTooltip = null;
         if(this.m_currencyAskButton)
         {
            this.m_currencyAskButton.enabled = true;
            this.m_currencyAskButton.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_currencyAskButton.setToggleState(ZwToggleState.SELECTED);
            this.m_currencyAskButton.applyGrayOut = true;
            this.m_currencyAskButton.element.buttonMode = false;
            infoTooltip = new FarmTextTooltip(ZLocUtils.t("Dialogs","wandering_pirate_askToolTip"));
            this.m_currencyAskButton.attachTooltip(infoTooltip);
         }
      }
      
      private function enableNurtureBtn() : void
      {
         this.m_nutureBtn.enabled = false;
         var totalWitheredItems:int = int(FlowerShackManager.getInstance(this.m_featureName).getTotalWitheredItemsBySubtype(FlowerShackManager.BOTH_BLOSSOM_SUBTYPE).length);
         if(totalWitheredItems > 0)
         {
            this.m_nutureBtn.enabled = true;
         }
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      private function get playerNectarCount() : Number
      {
         return FlowerShackManager.getInstance(this.m_featureName).playerNectarCount;
      }
      
      private function onAskButtonClick(e:Event) : void
      {
         if(this.m_currencyAskButton)
         {
            this.disableAskButton();
         }
         if(FlowerShackManager.getInstance(this.m_featureName))
         {
            FlowerShackManager.getInstance(this.m_featureName).askForCurrencyItem();
         }
      }
      
      private function onBuyButtonClick(e:Event) : void
      {
         FlowerShackManager.getInstance(this.m_featureName).buyNecatarWindow();
      }
      
      private function onPlantButtonClick(e:Event) : void
      {
         UI.displayMiniMarketDialog(FlowerShackManager.getInstance(this.m_featureName).getCropItemNamesAsArray(),UI.MARKET_CONTEXT_UNKNOWN,"");
         this.close();
      }
      
      private function onNutureButtonClick(e:Event) : void
      {
         FlowerShackManager.getInstance(this.m_featureName).nutureAllWindow();
      }
      
      private function onHowDoesThisWorkClick(e:Event) : void
      {
         showTutorial();
      }
      
      public function update() : void
      {
         if(this.m_nectarTxt)
         {
            this.m_nectarTxt.text = this.playerNectarCount + "/" + FlowerShackManager.getInstance(this.m_featureName).MAX_NECTAR;
         }
         if(this.m_slotMc)
         {
            this.m_slotMc.refresh();
         }
      }
      
      override public function close() : void
      {
         FlowerShackManager.getInstance(this.m_featureName).resetWindow();
         this.m_titleTextField = null;
         this.m_flowerMc = null;
         this.m_frameMc = null;
         super.close();
      }
   }
}

