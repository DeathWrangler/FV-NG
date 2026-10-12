package Widgets.Windows
{
   import Classes.Constants.BlossomConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FlowerShackManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FlowerShackNutureWindow extends FarmWindow
   {
      
      private static const MAIN_MC:String = "nurture_mc";
      
      private static const CLOSE_BTN:String = "loginClose_bt";
      
      private static const BUY_BTN:String = "buyRandom_bt";
      
      private static const BLOOM_CHECK_MC:String = "checkmark_1_mc";
      
      private static const BOQUET_CHECK_MC:String = "checkmark_2_mc";
      
      private static const BLOOM_ITEM_COUNT_TXT:String = "itemCount_1_tf";
      
      private static const BOQUET_ITEM_COUNT_TXT:String = "itemCount_2_tf";
      
      private static const CANCEL_BTN:String = "cancel_bt";
      
      private static const BLOOM_SELL_BTN:String = "sell_1_bt";
      
      private static const BOQUET_SELL_BTN:String = "sell_2_bt";
      
      private static const SUB_TITLE_1_TXT:String = "subtitle1_tf";
      
      private static const SUB_TITLE_2_TXT:String = "subtitle2_tf";
      
      private static const CURRENCY_MC:String = "currency_mc";
      
      private static const NECTAR_COUNT_TXT:String = "countStars_tf";
      
      private var m_featureName:String;
      
      private var m_mainMc:ZwWidget;
      
      private var m_buyBtn:FarmAnimatedCashButton;
      
      private var m_bloomCountTxt:ZwTextField;
      
      private var m_boquetCountTxt:ZwTextField;
      
      private var m_closeBtn:FarmButton;
      
      private var m_bloomCheckBtn:MovieClip;
      
      private var m_bloomSellBtn:FarmButton;
      
      private var m_boquetCheckBtn:MovieClip;
      
      private var m_boquetSellBtn:FarmButton;
      
      private var m_cancelBtn:FarmAnimatedTextButton;
      
      private var m_nectarTxt:FarmTextField;
      
      private var m_totalNectarCost:int;
      
      public function FlowerShackNutureWindow(featureName:String)
      {
         this.m_featureName = featureName;
         super(FlowerShackManager.FLOWERSHACK_NUTURE_DIALOG_URL);
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
                  addWidget(new ZwTextField(this.m_mainMc.element[SUB_TITLE_1_TXT],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,"flowershack_nuture_title")),true);
               }
               if(this.m_mainMc.element.hasOwnProperty(SUB_TITLE_2_TXT))
               {
                  addWidget(new ZwTextField(this.m_mainMc.element[SUB_TITLE_2_TXT],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,"flowershack_nuture_subtitle")),true);
               }
               if(this.m_mainMc.element.hasOwnProperty(CLOSE_BTN))
               {
                  addWidget(this.m_closeBtn = new FarmButton(this.m_mainMc.element[CLOSE_BTN],this.onCloseBtnClick),true);
               }
               if(this.m_mainMc.element.hasOwnProperty(BUY_BTN))
               {
                  this.m_buyBtn = new FarmAnimatedCashButton(this.m_mainMc.element[BUY_BTN],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,"FlowerShackNuture"),"0",this.onBuyButtonClick,false,false,true,"",1);
               }
               if(this.m_mainMc.element.hasOwnProperty(CANCEL_BTN))
               {
                  this.m_cancelBtn = addWidget(new FarmAnimatedTextButton(this.m_mainMc.element[CANCEL_BTN],ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,"Cancel"),this.onCloseBtnClick),true) as FarmAnimatedTextButton;
               }
               if(this.m_mainMc.element.hasOwnProperty(BLOOM_ITEM_COUNT_TXT))
               {
                  this.m_bloomCountTxt = addWidget(new ZwTextField(this.m_mainMc.element[BLOOM_ITEM_COUNT_TXT]),true) as ZwTextField;
                  this.m_bloomCountTxt.text = "0";
               }
               if(this.m_mainMc.element.hasOwnProperty(BOQUET_ITEM_COUNT_TXT))
               {
                  this.m_boquetCountTxt = addWidget(new ZwTextField(this.m_mainMc.element[BOQUET_ITEM_COUNT_TXT]),true) as ZwTextField;
                  this.m_boquetCountTxt.text = "0";
               }
               if(this.m_mainMc.element.hasOwnProperty(BLOOM_CHECK_MC))
               {
                  this.m_bloomCheckBtn = this.m_mainMc.element[BLOOM_CHECK_MC];
                  this.m_bloomCheckBtn.visible = false;
                  this.m_bloomCheckBtn.enabled = false;
               }
               if(this.m_mainMc.element.hasOwnProperty(BOQUET_CHECK_MC))
               {
                  this.m_boquetCheckBtn = this.m_mainMc.element[BOQUET_CHECK_MC];
                  this.m_boquetCheckBtn.visible = false;
                  this.m_boquetCheckBtn.enabled = false;
               }
               if(this.m_mainMc.element.hasOwnProperty(BLOOM_SELL_BTN))
               {
                  this.m_bloomSellBtn = addWidget(new FarmButton(this.m_mainMc.element[BLOOM_SELL_BTN],this.onBloomSelectHandler),true) as FarmButton;
               }
               if(this.m_mainMc.element.hasOwnProperty(BOQUET_SELL_BTN))
               {
                  this.m_boquetSellBtn = addWidget(new FarmButton(this.m_mainMc.element[BOQUET_SELL_BTN],this.onBoquetSelectHandler),true) as FarmButton;
               }
               if(this.m_mainMc.element.hasOwnProperty(CURRENCY_MC))
               {
                  if(this.m_mainMc.element[CURRENCY_MC].hasOwnProperty(NECTAR_COUNT_TXT))
                  {
                     this.m_nectarTxt = new FarmTextField(this.m_mainMc.element[CURRENCY_MC][NECTAR_COUNT_TXT],this.playerNectarCount + "/" + FlowerShackManager.getInstance(this.m_featureName).MAX_NECTAR);
                     addWidget(this.m_nectarTxt);
                  }
               }
               this.preselectCheckBtn();
               this.refresh();
            }
         }
      }
      
      private function preselectCheckBtn() : void
      {
         this.m_buyBtn.enabled = false;
         this.m_bloomCheckBtn.visible = false;
         this.m_boquetCheckBtn.visible = false;
         this.m_bloomSellBtn.enabled = false;
         this.m_boquetSellBtn.enabled = false;
         if(this.getTotalNutureCostBySubtype(BlossomConstants.SINGLE_BLOSSOM_SUBTYPE) != 0 && this.getTotalNutureCostBySubtype(BlossomConstants.SINGLE_BLOSSOM_SUBTYPE) <= this.playerNectarCount)
         {
            this.m_bloomCheckBtn.visible = true;
            this.m_bloomSellBtn.enabled = true;
         }
         if(this.getTotalNutureCostBySubtype(BlossomConstants.FULL_BLOSSOM_SUBTYPE) != 0 && this.getTotalNutureCostBySubtype(BlossomConstants.FULL_BLOSSOM_SUBTYPE) <= this.playerNectarCount)
         {
            this.m_boquetCheckBtn.visible = true;
            this.m_boquetSellBtn.enabled = true;
         }
      }
      
      public function getTotalNutureCostBySubtype(subtype:String) : int
      {
         return FlowerShackManager.getInstance(this.m_featureName).getTotalNutureCostBySubtype(subtype);
      }
      
      private function enableNutureBtn(subtype:String) : void
      {
         this.m_buyBtn.enabled = false;
         var totalNectarRequired:int = FlowerShackManager.getInstance(this.m_featureName).getTotalNutureCostBySubtype(subtype);
         if(this.playerNectarCount >= totalNectarRequired)
         {
            this.m_buyBtn.enabled = true;
         }
      }
      
      private function updateBloomCountTxt() : void
      {
         if(this.m_bloomCountTxt)
         {
            this.m_bloomCountTxt.text = FlowerShackManager.getInstance(this.m_featureName).getTotalNutureCostBySubtype(BlossomConstants.SINGLE_BLOSSOM_SUBTYPE).toString();
         }
         if(this.m_boquetCountTxt)
         {
            this.m_boquetCountTxt.text = FlowerShackManager.getInstance(this.m_featureName).getTotalNutureCostBySubtype(BlossomConstants.FULL_BLOSSOM_SUBTYPE).toString();
         }
      }
      
      private function onBloomSelectHandler(e:Event) : void
      {
         this.m_bloomCheckBtn.visible = this.m_bloomCheckBtn.visible ? false : true;
         this.refresh();
      }
      
      private function onBoquetSelectHandler(e:Event) : void
      {
         this.m_boquetCheckBtn.visible = this.m_boquetCheckBtn.visible ? false : true;
         this.refresh();
      }
      
      private function isValidSubtype() : Boolean
      {
         var result:Boolean = false;
         if(this.getSubtype() != "")
         {
            result = FlowerShackManager.getInstance(this.m_featureName).getTotalWitheredItemsBySubtype(this.getSubtype()).length > 0;
         }
         return result;
      }
      
      private function refresh() : void
      {
         this.updateCashBtnText();
         this.updateBloomCountTxt();
         if(this.getSubtype() != "" && this.isValidSubtype())
         {
            this.enableNutureBtn(this.getSubtype());
         }
         else
         {
            this.m_buyBtn.enabled = false;
         }
      }
      
      private function get playerNectarCount() : Number
      {
         return FlowerShackManager.getInstance(this.m_featureName).playerNectarCount;
      }
      
      private function updateCashBtnText() : void
      {
         var nectarAmount:TextField = null;
         var buyConfirmText:String = null;
         if(Boolean(this.m_buyBtn) && this.m_buyBtn.element.hasOwnProperty("amount_tf"))
         {
            nectarAmount = this.m_buyBtn.element["amount_tf"];
            nectarAmount.text = this.getTotalNutureCostBySubtype(this.getSubtype()).toString();
            buyConfirmText = ZLocUtils.t("Dialogs","flower_shack_nuture_confirm_txt",{"nectarCount":nectarAmount.text});
            this.m_buyBtn.buyConfirmationText = buyConfirmText;
         }
      }
      
      private function onBuyButtonClick(e:Event) : void
      {
         if(this.getSubtype() != "" && this.isValidSubtype())
         {
            FlowerShackManager.getInstance(this.m_featureName).nutureAllBlossomsOrBoquets(this.getSubtype());
            close();
         }
      }
      
      private function getSubtype() : String
      {
         var subtype:String = "";
         if(this.m_bloomCheckBtn.visible && this.m_boquetCheckBtn.visible)
         {
            subtype = FlowerShackManager.BOTH_BLOSSOM_SUBTYPE;
         }
         else if(this.m_bloomCheckBtn.visible && !this.m_boquetCheckBtn.visible)
         {
            subtype = BlossomConstants.SINGLE_BLOSSOM_SUBTYPE;
         }
         else if(!this.m_bloomCheckBtn.visible && this.m_boquetCheckBtn.visible)
         {
            subtype = BlossomConstants.FULL_BLOSSOM_SUBTYPE;
         }
         return subtype;
      }
      
      private function onCloseBtnClick(e:Event) : void
      {
         super.close();
      }
   }
}

