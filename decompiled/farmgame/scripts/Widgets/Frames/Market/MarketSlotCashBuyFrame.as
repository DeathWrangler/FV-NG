package Widgets.Frames.Market
{
   import Classes.Constants.Experiments;
   import Classes.ItemRequirement;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Managers.ItemMembershipManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.Market.MarketPreviewWindow;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class MarketSlotCashBuyFrame extends MarketSlotBaseBuyFarm
   {
      
      private static const X_PADDING:int = 1;
      
      private static const Y_PADDING:int = 18;
      
      private static const SEND_DISABLED_ALPHA:Number = 0.5;
      
      private var m_moreInfo:Boolean = false;
      
      private var m_licensable:Boolean = false;
      
      private var m_playable:Boolean = false;
      
      private var m_sendable:Boolean = false;
      
      private var m_isSendableQuantity:Boolean = true;
      
      private var m_sendLimit:int;
      
      private var m_icon:ZwWidget;
      
      private var m_berryIcon:ZwWidget;
      
      private var m_costTextField:ZwTextField;
      
      private var m_playButton:FarmAnimatedTextButton;
      
      private var m_sendButton:FarmAnimatedTextButton;
      
      private var m_moreInfoButton:FarmAnimatedTextButton;
      
      private var m_redeemable:Boolean = false;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      public function MarketSlotCashBuyFrame(element:MovieClip, callback:Function)
      {
         super(element);
         this.m_icon = addWidget(new ZwWidget(m_element.icon_mc)) as ZwWidget;
         if(m_element.hasOwnProperty("berryIcon_mc"))
         {
            this.m_berryIcon = addWidget(new ZwWidget(m_element.berryIcon_mc)) as ZwWidget;
            this.m_berryIcon.visible = false;
         }
         this.m_costTextField = addWidget(new ZwTextField(m_element.cost_tf)) as ZwTextField;
         (this.m_costTextField.element as TextField).autoSize = TextFieldAutoSize.RIGHT;
         (this.m_costTextField.element as TextField).multiline = false;
         (this.m_costTextField.element as TextField).wordWrap = false;
         m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","MarketCardBuyButton"),callback)) as FarmAnimatedTextButton;
         m_buyButton.attachTooltip(new MarketTooltip());
         m_lockedButton = addWidget(new FarmAnimatedTextButton(m_element.locked_bt,ZLocUtils.t("Dialogs","MarketCardLockedButton"))) as FarmAnimatedTextButton;
         m_lockedButton.attachTooltip(new MarketTooltip());
         if(m_element.hasOwnProperty("play_bt"))
         {
            this.m_playButton = addWidget(new FarmAnimatedTextButton(m_element.play_bt,ZLocUtils.t("Dialogs","MarketCardPlayButton"),callback)) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("info_bt"))
         {
            this.m_moreInfoButton = addWidget(new FarmAnimatedTextButton(m_element.info_bt,ZLocUtils.t("Dialogs","MarketCardMoreInfoButton"),callback),false) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("redeem_bt"))
         {
            this.m_redeemButton = addWidget(new FarmAnimatedTextButton(m_element.redeem_bt,ZLocUtils.t("Dialogs","MarketCardRedeemButton"),callback),false) as FarmAnimatedTextButton;
         }
         this.m_sendButton = addWidget(new FarmAnimatedTextButton(m_element.send_bt,ZLocUtils.t("Dialogs","MarketCardSendButton"),callback),false) as FarmAnimatedTextButton;
         var travelLiteExpReq:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TRAVEL_LITE) == 2;
         if(travelLiteExpReq && m_element.hasOwnProperty("travel_bt"))
         {
            m_travelButton = addWidget(new FarmAnimatedTextButton(m_element.travel_bt,"TRAVEL",callback)) as FarmAnimatedTextButton;
            m_travelButton.attachTooltip(new MarketTooltip());
         }
      }
      
      public function set cost(value:int) : void
      {
         this.m_costTextField.text = Utilities.formatNumber(value);
         this.m_costTextField.visible = true;
         this.m_icon.visible = true;
         m_buyButton.text = ZLocUtils.t("Dialogs","MarketCardBuyButton");
         if(value == 0)
         {
            this.m_costTextField.visible = false;
            this.m_icon.visible = false;
            m_buyButton.text = ZLocUtils.t("Dialogs","RewardCardsRedeemNow");
         }
         this.refresh();
      }
      
      public function set moreInfoText(value:String) : void
      {
         if(this.m_moreInfoButton.text != value)
         {
            this.m_moreInfoButton.text = value;
            this.refresh();
         }
      }
      
      public function set licensable(value:Boolean) : void
      {
         if(this.m_licensable != value)
         {
            this.m_licensable = value;
            this.refresh();
         }
      }
      
      public function set playable(value:Boolean) : void
      {
         if(this.m_playable != value)
         {
            this.m_playable = value;
            this.refresh();
         }
      }
      
      public function set moreInfo(value:Boolean) : void
      {
         if(this.m_moreInfo != value)
         {
            this.m_moreInfo = value;
            this.refresh();
         }
      }
      
      public function set sendable(value:Boolean) : void
      {
         if(this.m_sendable != value)
         {
            this.m_sendable = value;
            this.refresh();
         }
      }
      
      public function setIsSendableQuantity(value:Boolean, sendLimit:int = 1) : void
      {
         if(this.m_isSendableQuantity != value)
         {
            this.m_isSendableQuantity = value;
            this.m_sendLimit = sendLimit;
            this.refresh();
         }
      }
      
      public function getIsSendableQuantity() : Boolean
      {
         return this.m_isSendableQuantity;
      }
      
      public function get buyButton() : FarmAnimatedTextButton
      {
         return m_buyButton;
      }
      
      public function get moreInfoButton() : FarmAnimatedTextButton
      {
         return this.m_moreInfoButton;
      }
      
      public function get playButton() : FarmAnimatedTextButton
      {
         return this.m_playButton;
      }
      
      public function get sendButton() : FarmAnimatedTextButton
      {
         return this.m_sendButton;
      }
      
      public function get redeemButton() : FarmAnimatedTextButton
      {
         return this.m_redeemButton;
      }
      
      public function get travelButton() : FarmAnimatedTextButton
      {
         return m_travelButton;
      }
      
      public function restoreDefaults() : void
      {
         this.m_licensable = false;
         this.m_playable = false;
         this.m_sendable = false;
         this.m_redeemable = false;
         this.m_moreInfo = false;
         this.m_isSendableQuantity = true;
         if(this.m_berryIcon)
         {
            this.m_berryIcon.visible = false;
         }
      }
      
      override protected function refresh() : void
      {
         var rightButton:FarmAnimatedTextButton = null;
         var tooltipText:String = null;
         m_buyButton.visible = false;
         if(this.m_moreInfoButton)
         {
            this.m_moreInfoButton.visible = false;
         }
         if(this.m_playButton)
         {
            this.m_playButton.visible = false;
         }
         if(this.m_redeemButton)
         {
            this.m_redeemButton.visible = false;
         }
         if(this.m_moreInfo || this.m_licensable)
         {
            if(this.m_moreInfoButton)
            {
               this.m_moreInfoButton.visible = true;
            }
            rightButton = this.m_moreInfoButton;
         }
         else if(this.m_playable)
         {
            if(this.m_playButton)
            {
               this.m_playButton.visible = true;
            }
            rightButton = this.m_playButton;
         }
         else if(this.m_redeemable)
         {
            if(this.m_redeemButton)
            {
               this.m_redeemButton.visible = true;
               this.m_redeemButton.attachTooltip(new MarketTooltip());
               tooltipText = ItemMembershipManager.isInItemMembershipExperiment() ? ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_market_redeem_tooltip") : ZLocUtils.t("Dialogs","MarketCardRedeemButtonTooltip");
               (this.m_redeemButton.tooltip as MarketTooltip).setText(tooltipText);
            }
            rightButton = this.m_redeemButton;
         }
         else
         {
            m_buyButton.visible = true;
            if(this.m_playButton)
            {
               this.m_playButton.visible = false;
            }
            rightButton = m_buyButton;
         }
         m_lockedButton.visible = m_locked;
         if(m_locked)
         {
            rightButton = m_lockedButton;
         }
         if(this.m_sendable)
         {
            this.m_sendButton.visible = true;
            if(!MarketPreviewWindow.marketPreviewActive)
            {
               this.m_sendButton.y = m_buyButton.y;
            }
            else
            {
               this.m_sendButton.x = rightButton.x - this.m_sendButton.width - X_PADDING;
               this.m_costTextField.x = this.m_sendButton.x - this.m_costTextField.width - X_PADDING;
            }
            if(this.m_isSendableQuantity)
            {
               this.m_sendButton.alpha = 1;
               this.m_sendButton.detachTooltip();
            }
            else
            {
               this.m_sendButton.alpha = SEND_DISABLED_ALPHA;
               this.m_sendButton.attachTooltip(new MarketTooltip());
               (this.m_sendButton.tooltip as MarketTooltip).setText(ZLocUtils.t("Dialogs","MarketCardSendLimit",{"quantity":this.m_sendLimit}));
            }
         }
         else
         {
            this.m_sendButton.visible = false;
            this.m_costTextField.x = rightButton.x - this.m_costTextField.width - X_PADDING;
         }
         this.m_icon.x = this.m_costTextField.x - X_PADDING;
         this.m_sendButton.recalculateTransforms();
         if(Boolean(m_worldType) && m_worldType.length > 0)
         {
            m_buyButton.visible = false;
            if(m_travelButton)
            {
               m_travelButton.visible = true;
            }
            this.m_icon.element.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
            m_lockedButton.visible = false;
            m_costTextColor = this.m_costTextField.color;
            this.m_costTextField.color = 9671571;
         }
         else
         {
            if(m_travelButton)
            {
               m_travelButton.visible = false;
            }
            this.m_icon.element.filters = [];
            this.m_costTextField.color = m_costTextColor;
         }
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_costTextField = null;
         m_buyButton = null;
         this.m_playButton = null;
         this.m_sendButton = null;
         this.m_redeemButton = null;
         this.m_moreInfoButton = null;
         if(m_travelButton)
         {
            m_travelButton = null;
         }
         super.release();
      }
      
      override protected function canItemRequirementTriggerLockState(itemRequirement:ItemRequirement) : Boolean
      {
         return itemRequirement.shouldLockCashItem();
      }
      
      public function set redeemable(value:Boolean) : void
      {
         this.m_redeemable = value;
         this.refresh();
      }
      
      public function showBerryLicenseIcon() : void
      {
         this.m_icon.visible = false;
         if(this.m_berryIcon)
         {
            this.m_berryIcon.visible = true;
            this.m_berryIcon.x = this.m_costTextField.x - this.m_berryIcon.width - X_PADDING;
         }
      }
   }
}

