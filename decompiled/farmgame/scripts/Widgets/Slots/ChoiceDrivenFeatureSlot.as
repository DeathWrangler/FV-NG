package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Events.GenericPopupEvent;
   import Managers.ChoiceDrivenManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ChoiceDrivenFeatureSlot extends ZwSlotFrame
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const ICON_MC:String = "icon_mc";
      
      private const BUY_BT:String = "buyCash_bt";
      
      private const XCURRENCY_MC:String = "xCurrency_mc";
      
      private const YCURRENCY_MC:String = "yCurrency_mc";
      
      private const CHECKMARK_MC:String = "checkMark_mc";
      
      private const XCOUNT_TF:String = "xCount_tf";
      
      private const YCOUNT_TF:String = "yCount_tf";
      
      private const GLOW_MC:String = "glow_mc";
      
      private const BUY_DOOBER_MOVIECLIP:String = "buyConfirmation_mc";
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      protected var m_objectPreview:ObjectPreviewFrame;
      
      protected var m_iconPreview:FarmIcon;
      
      private var m_xCurrencyIcon:ZwWidget;
      
      private var m_xCurrencyCount:ZwTextField;
      
      private var m_yCurrencyIcon:ZwWidget;
      
      private var m_yCurrencyCount:ZwTextField;
      
      private var m_checkMark:ZwWidget;
      
      private var m_glowMc:MovieClip;
      
      private const TEXT_ROUND_TITLE:String = "_round_reward_number";
      
      public function ChoiceDrivenFeatureSlot(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         this.m_featureName = featureName;
         super(element);
         addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element[this.BUY_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Buy"),"",this.onBuyItem,false,false,true,"",5),false);
         if(m_element.hasOwnProperty(this.XCURRENCY_MC))
         {
            addWidget(this.m_xCurrencyIcon = new ZwWidget(m_element[this.XCURRENCY_MC]),false);
            addWidget(this.m_xCurrencyCount = new ZwTextField(m_element[this.XCURRENCY_MC][this.XCOUNT_TF]),false);
         }
         if(m_element.hasOwnProperty(this.YCURRENCY_MC))
         {
            addWidget(this.m_yCurrencyIcon = new ZwWidget(m_element[this.YCURRENCY_MC]),false);
            addWidget(this.m_yCurrencyCount = new ZwTextField(m_element[this.YCURRENCY_MC][this.YCOUNT_TF]),false);
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            addWidget(this.m_checkMark = new ZwWidget(m_element[this.CHECKMARK_MC]),false);
         }
         if(m_element.hasOwnProperty(this.GLOW_MC))
         {
            this.m_glowMc = m_element[this.GLOW_MC] as MovieClip;
            this.disableGlow();
         }
      }
      
      override public function populate(data:Object) : void
      {
         var item:FarmItem = null;
         var collectableReward:Object = null;
         super.populate(data);
         this.m_data = data;
         var isFeaturePlayable:Boolean = this.manager.isFeaturePlayable();
         item = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         this.m_buyButton.visible = !isFeaturePlayable;
         this.m_buyButton.setAmountText(item.cash.toString());
         this.m_buyButton.buyConfirmationText = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":item.cash.toString()});
         var roundNumberText:String = ZLocUtils.t("Dialogs",this.m_featureName + this.TEXT_ROUND_TITLE,{"number":data["roundNumber"]});
         var infoTooltip:FarmTextTooltip = new FarmTextTooltip(roundNumberText + ": " + ZLocUtils.tk_pk_asTitle(item.friendlyName));
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            this.m_objectPreview = getWidget(m_element[this.ICON_MC]) as ObjectPreviewFrame;
            if(this.m_objectPreview)
            {
               removeWidget(this.m_objectPreview);
               this.m_objectPreview = null;
            }
            this.m_iconPreview = getWidget(m_element[this.ICON_MC]) as FarmIcon;
            if(this.m_iconPreview)
            {
               removeWidget(this.m_iconPreview);
               this.m_iconPreview = null;
            }
            if(item.getImageByName("frt_idle") != null || item.getImageByName("bare") != null || item.getImageByName("static") != null || item.getImageByName("horizontal") != null)
            {
               this.m_objectPreview = new ObjectPreviewFrame(m_element[this.ICON_MC],item,null,[item.sizeX == 1 ? 2 : 1.75]);
               (this.m_objectPreview.element as MovieClip).filters = [];
               addWidget(this.m_objectPreview,true);
               this.m_objectPreview.attachTooltip(infoTooltip);
            }
            else if(m_element.hasOwnProperty(this.ICON_MC))
            {
               this.m_iconPreview = new FarmIcon(m_element.icon_mc,item.icon);
               addWidget(this.m_iconPreview,true);
               this.m_iconPreview.attachTooltip(infoTooltip);
            }
         }
         this.disableGlow();
         if(isFeaturePlayable)
         {
            if(!data["redeemed"])
            {
               collectableReward = this.manager.getRedeemableReward();
               if(Boolean(collectableReward) && Boolean(this.m_data.name == collectableReward.name) && this.manager.canClaimReward())
               {
                  this.enableGlow();
               }
               this.m_xCurrencyIcon.visible = true;
               this.m_xCurrencyCount.visible = true;
               this.m_xCurrencyCount.text = data["pink"];
               this.m_yCurrencyIcon.visible = true;
               this.m_yCurrencyCount.visible = true;
               this.m_yCurrencyCount.text = data["white"];
            }
            else
            {
               this.m_checkMark.visible = true;
            }
         }
         if(m_element[this.BUY_DOOBER_MOVIECLIP])
         {
            (m_element[this.BUY_DOOBER_MOVIECLIP] as MovieClip).stop();
            m_element[this.BUY_DOOBER_MOVIECLIP].visible = false;
         }
      }
      
      private function onBuyItem(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.manager.buyCollectionItem(this.m_data.name);
            if(m_element[this.BUY_DOOBER_MOVIECLIP])
            {
               m_element[this.BUY_DOOBER_MOVIECLIP].visible = true;
               (m_element[this.BUY_DOOBER_MOVIECLIP] as MovieClip).play();
            }
         }
      }
      
      private function disableGlow() : void
      {
         if(this.m_glowMc)
         {
            this.m_glowMc.stop();
            this.m_glowMc.visible = false;
         }
      }
      
      private function enableGlow() : void
      {
         if(this.m_glowMc)
         {
            this.m_glowMc.play();
            this.m_glowMc.visible = true;
         }
      }
      
      private function get manager() : ChoiceDrivenManager
      {
         return ChoiceDrivenManager.getInstance(this.m_featureName);
      }
      
      override public function release() : void
      {
         this.m_iconPreview = null;
         this.m_objectPreview = null;
         super.release();
      }
   }
}

