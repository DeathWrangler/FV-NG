package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FlowerShackManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   
   public class FlowerShackBuyNectarWindow extends FarmWindow
   {
      
      private static const MAIN_MC:String = "buyNectar_mc";
      
      private static const CLOSE_BTN:String = "buyClose_bt";
      
      private static const RANDOM_BTN:String = "buyRandom_bt";
      
      private static const DOWN_ARROW_BTN:String = "downArrow_mc";
      
      private static const UP_ARROW_BTN:String = "upArrow_mc";
      
      private static const ITEM_COUNT_TXT:String = "itemCount_tf";
      
      private static const SUB_TITLE_1_TXT:String = "subtitle1_tf";
      
      private static const SUB_TITLE_2_TXT:String = "subtitle2_tf";
      
      private static const CURRENCY_MC:String = "currency_mc";
      
      private static const NECTAR_COUNT_TXT:String = "countStars_tf";
      
      private static const NECTAR_INTERVAL:int = 5;
      
      private var m_featureName:String;
      
      private var m_mainMc:ZwWidget;
      
      private var m_buyBtn:FarmAnimatedCashButton;
      
      private var m_upArrowBtn:FarmButton;
      
      private var m_downArrowBtn:FarmButton;
      
      private var m_itemCountTxt:ZwTextField;
      
      private var m_closeBtn:FarmButton;
      
      private var m_subtitle1:ZwTextField;
      
      private var m_subtitle2:ZwTextField;
      
      private var m_nectarTxt:FarmTextField;
      
      private var m_nectarCount:Number = 0;
      
      private var m_shortcutEnabled:Boolean = false;
      
      public function FlowerShackBuyNectarWindow(featureName:String)
      {
         this.m_featureName = featureName;
         super(FlowerShackManager.FLOWERSHACK_BUY_NECTAR_DIALOG_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(MAIN_MC))
         {
            this.m_mainMc = addWidget(new ZwWidget(m_window[MAIN_MC]),true) as ZwWidget;
            if(this.m_mainMc)
            {
               if(this.m_mainMc.element.hasOwnProperty(SUB_TITLE_1_TXT))
               {
                  addWidget(new ZwTextField(this.m_mainMc.element[SUB_TITLE_1_TXT],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,"flowershack_buyNectar_title")),true);
               }
               if(this.m_mainMc.element.hasOwnProperty(SUB_TITLE_2_TXT))
               {
                  addWidget(new ZwTextField(this.m_mainMc.element[SUB_TITLE_2_TXT],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,"flowershack_buyNectar_sub_title")),true);
               }
               if(this.m_mainMc.element.hasOwnProperty(RANDOM_BTN))
               {
                  this.m_buyBtn = new FarmAnimatedCashButton(this.m_mainMc.element[RANDOM_BTN],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_buy_btn_txt"),"0",this.onBuyButtonClick,false,false,true,"",1);
               }
               if(this.m_mainMc.element.hasOwnProperty(UP_ARROW_BTN))
               {
                  addWidget(this.m_upArrowBtn = new FarmButton(this.m_mainMc.element[UP_ARROW_BTN],this.onUpArrowPress),true);
               }
               if(this.m_mainMc.element.hasOwnProperty(DOWN_ARROW_BTN))
               {
                  addWidget(this.m_downArrowBtn = new FarmButton(this.m_mainMc.element[DOWN_ARROW_BTN],this.onDownArrowPress),true);
               }
               if(this.m_mainMc.element.hasOwnProperty(ITEM_COUNT_TXT))
               {
                  this.m_itemCountTxt = addWidget(new ZwTextField(this.m_mainMc.element[ITEM_COUNT_TXT]),true) as ZwTextField;
                  this.m_itemCountTxt.text = "0";
                  this.m_itemCountTxt.restrict("0-9",3);
                  this.m_itemCountTxt.element.addEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
               }
               if(this.m_mainMc.element.hasOwnProperty(CLOSE_BTN))
               {
                  addWidget(this.m_closeBtn = new FarmButton(this.m_mainMc.element[CLOSE_BTN],this.onCloseBtnClick),true);
               }
               if(this.m_mainMc.element.hasOwnProperty(CURRENCY_MC))
               {
                  if(this.m_mainMc.element[CURRENCY_MC].hasOwnProperty(NECTAR_COUNT_TXT))
                  {
                     this.m_nectarTxt = new FarmTextField(this.m_mainMc.element[CURRENCY_MC][NECTAR_COUNT_TXT],this.nectarCount + "/" + FlowerShackManager.getInstance(this.m_featureName).MAX_NECTAR);
                     addWidget(this.m_nectarTxt);
                  }
               }
            }
         }
      }
      
      private function onKeyUpHandler(e:KeyboardEvent) : void
      {
         this.m_nectarCount = Number(this.m_itemCountTxt.text);
         this.m_nectarCount = Math.round(this.m_nectarCount / 5) * 5;
         this.updateNectarCount();
         this.updateCashText();
      }
      
      private function enableShortcut(e:FocusEvent) : void
      {
         this.m_nectarCount = Number(this.m_itemCountTxt.text);
         this.m_nectarCount = Math.round(this.m_nectarCount / 5) * 5;
         this.updateNectarCount();
         this.updateCashText();
         this.m_shortcutEnabled = true;
      }
      
      private function get nectarCount() : Number
      {
         return FlowerShackManager.getInstance(this.m_featureName).playerNectarCount;
      }
      
      private function onBuyButtonClick(e:Event) : void
      {
         if(this.m_nectarCount > 0)
         {
            FlowerShackManager.getInstance(this.m_featureName).buyCurrencyItem(this.m_nectarCount);
            super.close();
         }
      }
      
      private function onUpArrowPress(e:Event) : void
      {
         if(!this.m_shortcutEnabled)
         {
            if(this.m_nectarCount < FlowerShackManager.getInstance(this.m_featureName).MAX_NECTAR)
            {
               this.m_nectarCount += NECTAR_INTERVAL;
               this.updateNectarCount();
               this.updateCashText();
            }
         }
         else
         {
            this.m_shortcutEnabled = false;
         }
      }
      
      private function onDownArrowPress(e:Event) : void
      {
         if(!this.m_shortcutEnabled)
         {
            if(this.m_nectarCount > 0)
            {
               this.m_nectarCount -= NECTAR_INTERVAL;
               this.updateNectarCount();
               this.updateCashText();
            }
         }
         else
         {
            this.m_shortcutEnabled = false;
         }
      }
      
      private function updateNectarCount() : void
      {
         if(this.m_itemCountTxt)
         {
            this.m_itemCountTxt.text = String(this.m_nectarCount);
         }
      }
      
      private function updateCashText() : void
      {
         var nectarCost:TextField = null;
         if(Boolean(this.m_buyBtn) && this.m_buyBtn.element.hasOwnProperty("amount_tf"))
         {
            nectarCost = this.m_buyBtn.element["amount_tf"];
            nectarCost.text = this.cashValue.toString();
            this.m_buyBtn.buyConfirmationText = ZLocUtils.t("Dialogs","flower_shack_buy_nectar_confirm_txt",{
               "nectarCount":this.m_nectarCount,
               "amount":this.cashValue
            });
         }
      }
      
      private function get cashValue() : int
      {
         return FlowerShackManager.getInstance(this.m_featureName).getWorldCurrencyCost(this.m_nectarCount);
      }
      
      private function onCloseBtnClick(e:Event) : void
      {
         super.close();
      }
   }
}

