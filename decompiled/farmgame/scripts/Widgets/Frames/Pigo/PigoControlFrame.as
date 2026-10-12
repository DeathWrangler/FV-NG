package Widgets.Frames.Pigo
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class PigoControlFrame extends ZwFrame
   {
      
      private static const DOUBLE_CLICK_DELAY:int = 500;
      
      private var m_buyTokenCallback:Function;
      
      private var m_buyTokenPackageCallback:Function;
      
      private var m_playCallback:Function;
      
      private var m_buyTokenButton:FarmAnimatedTextButton;
      
      private var m_buyTokenPackageButton:FarmAnimatedTextButton;
      
      private var m_playButton:FarmAnimatedTextButton;
      
      private var m_playBuyButton:FarmAnimatedCashButton;
      
      private var m_tokenCountTextField:ZwTextField;
      
      private var m_hasFreePlay:Boolean = false;
      
      private var m_lastClickTime:int;
      
      private var m_tokenCount:int;
      
      private var m_maxTokensInPlay:int = 1;
      
      private var m_tokensInPlay:int;
      
      public function PigoControlFrame(element:DisplayObject, tokenPrice:int, tokenCount:int = 0, hasFreePlay:Boolean = false, tokenPackageCount:int = 0, tokenPackagePrice:int = 0)
      {
         var tokenPackageFullPrice:int = 0;
         super(element);
         this.m_tokenCount = tokenCount;
         this.m_hasFreePlay = hasFreePlay;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_PIGO_MAX_TOKENS_IN_PLAY) == 2)
         {
            this.m_maxTokensInPlay = 3;
         }
         else
         {
            this.m_maxTokensInPlay = 1;
         }
         addWidget(new ZwTextField(m_element.instructions_tf,ZLocUtils.t("Dialogs","PigoWindow_Instructions")));
         this.m_buyTokenButton = addWidget(new FarmAnimatedTextButton(m_element.buyButton0_mc,ZLocUtils.t("Dialogs","PigoWindow_BuyTokenButton"),this.onBuyTokenButtonClick)) as FarmAnimatedTextButton;
         addWidget(new ZwTextField(m_element.amount0_tf,ZLocUtils.t("Dialogs","PigoWindow_BuyTokenPrice",{"quantity":String(tokenPrice)})));
         if(tokenPackageCount > 0 && tokenPackagePrice > 0)
         {
            this.m_buyTokenPackageButton = addWidget(new FarmAnimatedTextButton(m_element.buyButton1_mc,ZLocUtils.t("Dialogs","PigoWindow_BuyTokenPackageButton",{"quantity":String(tokenPackageCount)}),this.onBuyTokenPackageButtonClick)) as FarmAnimatedTextButton;
            tokenPackageFullPrice = tokenPackageCount * tokenPrice;
            addWidget(new ZwTextField(m_element.amountOld_tf,String(tokenPackageFullPrice)));
            addWidget(new ZwWidget(m_element.crossOut_mc));
            addWidget(new ZwTextField(m_element.amount1_tf,ZLocUtils.t("Dialogs","PigoWindow_BuyTokenPrice",{"quantity":String(tokenPackagePrice)})));
         }
         this.m_playButton = addWidget(new FarmAnimatedTextButton(m_element.playButton_mc,ZLocUtils.t("Dialogs","PigoWindow_PlayButton"),this.onPlayButtonClick)) as FarmAnimatedTextButton;
         this.m_playBuyButton = addWidget(new FarmAnimatedCashButton(m_element.playButton2_mc,ZLocUtils.t("Dialogs","PigoWindow_PlayButton"),String(tokenPrice),this.onPlayButtonClick)) as FarmAnimatedCashButton;
         this.m_tokenCountTextField = addWidget(new ZwTextField(m_element.dartsLeft_tf,"")) as ZwTextField;
         this.refresh();
      }
      
      override public function release() : void
      {
         this.m_buyTokenButton = null;
         this.m_buyTokenCallback = null;
         this.m_buyTokenPackageButton = null;
         this.m_buyTokenPackageCallback = null;
         this.m_playCallback = null;
         this.m_playButton = null;
         this.m_playBuyButton = null;
         this.m_tokenCountTextField = null;
         super.release();
      }
      
      private function refresh() : void
      {
         if(this.m_hasFreePlay)
         {
            this.m_buyTokenButton.enabled = false;
            this.m_tokenCountTextField.text = ZLocUtils.t("Dialogs","PigoWindow_FreePlay");
            if(this.m_buyTokenPackageButton)
            {
               this.m_buyTokenPackageButton.enabled = false;
            }
         }
         else
         {
            this.m_buyTokenButton.enabled = true;
            this.m_tokenCountTextField.text = ZLocUtils.t("Dialogs","PigoWindow_TokenCount",{"quantity":String(this.m_tokenCount)});
            if(this.m_buyTokenPackageButton)
            {
               this.m_buyTokenPackageButton.enabled = true;
            }
         }
         if(this.m_tokensInPlay < this.m_maxTokensInPlay)
         {
            this.m_playButton.enabled = true;
            this.m_playBuyButton.enabled = true;
         }
         else
         {
            this.m_playButton.enabled = false;
            this.m_playBuyButton.enabled = false;
         }
         if(this.m_tokenCount > 0 || this.m_hasFreePlay)
         {
            this.m_playButton.visible = true;
            this.m_playBuyButton.visible = false;
         }
         else
         {
            this.m_playBuyButton.visible = true;
            this.m_playButton.visible = false;
         }
      }
      
      public function setCallbacks(playCallback:Function, buyTokenCallback:Function, buyTokenPackageCallback:Function) : void
      {
         this.m_playCallback = playCallback;
         this.m_buyTokenCallback = buyTokenCallback;
         this.m_buyTokenPackageCallback = buyTokenPackageCallback;
      }
      
      public function set hasFreePlay(value:Boolean) : void
      {
         this.m_hasFreePlay = value;
         this.refresh();
      }
      
      public function get hasFreePlay() : Boolean
      {
         return this.m_hasFreePlay;
      }
      
      public function set tokenCount(value:int) : void
      {
         this.m_tokenCount = value;
         this.refresh();
      }
      
      public function get tokenCount() : int
      {
         return this.m_tokenCount;
      }
      
      public function set tokensInPlay(value:int) : void
      {
         this.m_tokensInPlay = value;
         this.refresh();
      }
      
      public function get tokensInPlay() : int
      {
         return this.m_tokensInPlay;
      }
      
      private function onBuyTokenButtonClick(event:MouseEvent) : void
      {
         if(this.m_buyTokenButton.enabled && this.m_buyTokenCallback != null && GlobalEngine.currentTime >= this.m_lastClickTime + DOUBLE_CLICK_DELAY)
         {
            this.m_buyTokenCallback();
            this.m_lastClickTime = GlobalEngine.currentTime;
         }
      }
      
      private function onBuyTokenPackageButtonClick(event:MouseEvent) : void
      {
         if(this.m_buyTokenPackageButton.enabled && this.m_buyTokenPackageCallback != null && GlobalEngine.currentTime >= this.m_lastClickTime + DOUBLE_CLICK_DELAY)
         {
            this.m_buyTokenPackageCallback();
            this.m_lastClickTime = GlobalEngine.currentTime;
         }
      }
      
      private function onPlayButtonClick(event:MouseEvent) : void
      {
         if(this.m_playButton.enabled && this.m_playCallback != null && GlobalEngine.currentTime >= this.m_lastClickTime + DOUBLE_CLICK_DELAY)
         {
            this.m_playCallback();
            this.m_lastClickTime = GlobalEngine.currentTime;
         }
      }
   }
}

