package Widgets.Slots.LESet
{
   import Classes.Constants.Experiments;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.LESet.LESurfacingToasterWindow;
   import Widgets.Windows.LESet.LESurfacingWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class LESurfacingSlot extends LESlot
   {
      
      private static const LEARN_MORE_LINK:String = "http://zynga.org/campaigns/farmville-charity-le-items";
      
      private var m_featureName:String = "le_display_promo";
      
      private var m_newBuyBt:FarmAnimatedCashButton;
      
      private var m_popup:ZwBaseWidget;
      
      private var m_charityBG:ZwWidget;
      
      private var m_charityLogo:ZwWidget;
      
      private var m_charityLearnMore:FarmAnimatedTextButton;
      
      public function LESurfacingSlot(element:DisplayObject, parentWindow:FarmWindow, featureName:String)
      {
         super(element,parentWindow);
         this.m_featureName = featureName;
         if(m_element.hasOwnProperty("giftbox_mc"))
         {
            this.m_popup = addWidget(new ZwBaseWidget(m_element.giftbox_mc));
         }
         if(m_element.hasOwnProperty("charityBG_mc"))
         {
            this.m_charityBG = addWidget(new ZwWidget(m_element.charityBG_mc),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty("bannerLinkLearn_mc"))
         {
            this.m_charityLearnMore = addWidget(new FarmAnimatedTextButton(m_element.bannerLinkLearn_mc,ZLocUtils.t("Dialogs","leForCharity_learnMore"),this.onLearnMoreClick)) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("charityLogo_mc"))
         {
            this.m_charityLogo = addWidget(new ZwWidget(m_element.charityLogo_mc),false) as ZwWidget;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(m_farmItem.isCharityItem())
         {
            if(m_iconPreview)
            {
               m_iconPreview.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","leForCharity_hoverText")));
            }
            else if(m_objectPreviewFrame)
            {
               m_objectPreviewFrame.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","leForCharity_hoverText")));
            }
            this.toggleVisiblityCharityFrame(true);
         }
         else
         {
            if(m_iconPreview)
            {
               m_iconPreview.detachTooltip();
            }
            else if(m_objectPreviewFrame)
            {
               m_objectPreviewFrame.detachTooltip();
            }
            this.toggleVisiblityCharityFrame(false);
         }
      }
      
      private function toggleVisiblityCharityFrame(visibility:Boolean) : void
      {
         if(this.m_charityBG)
         {
            this.m_charityBG.visible = visibility;
         }
         if(this.m_charityLogo)
         {
            this.m_charityLogo.visible = visibility;
         }
         if(this.m_charityLearnMore)
         {
            this.m_charityLearnMore.visible = visibility;
         }
      }
      
      override public function release() : void
      {
         if(this.m_charityBG != null)
         {
            this.m_charityBG = null;
         }
         if(this.m_charityLogo != null)
         {
            this.m_charityLogo = null;
         }
         if(this.m_charityLearnMore != null)
         {
            this.m_charityLearnMore = null;
         }
         super.release();
      }
      
      private function onLearnMoreClick(event:Event) : void
      {
         try
         {
            navigateToURL(new URLRequest(LEARN_MORE_LINK),"_blank");
         }
         catch(e:Error)
         {
            FarmGameUtil.reportClientLog("Navigate to charity url failed : LeSurfacingSlot.onLearnMoreClick : " + e.message);
         }
      }
      
      override protected function onBuyCallback(event:Event) : void
      {
         var parentSurfaceWindow:LESurfacingWindow = null;
         var parentToasterSurfaceWindow:LESurfacingToasterWindow = null;
         if(Global.player.canBuyCash(getItemPrice()))
         {
            parentSurfaceWindow = m_parentWindow as LESurfacingWindow;
            parentToasterSurfaceWindow = m_parentWindow as LESurfacingToasterWindow;
            if(parentSurfaceWindow)
            {
               FarmStatsManager.count(this.m_featureName,"dialog","le_display_" + parentSurfaceWindow.pageNumber,"click_buy_" + name);
            }
            else if(parentToasterSurfaceWindow)
            {
               FarmStatsManager.count(this.m_featureName,"toaster","le_display_" + parentToasterSurfaceWindow.pageNumber,"click_buy_" + name);
            }
            m_farmItem.onBuy(m_farmItem.name);
            if(!parentToasterSurfaceWindow)
            {
               m_parentWindow.close();
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_LAST_CHANCE) < Experiments.VARIANT_LE_LAST_CHANCE_EXPIRING)
            {
               UI.closeMarketDialog();
            }
         }
      }
      
      override protected function setupBuyButton() : void
      {
         var variant:int = LESurfacingWindow.getImpExpVariant();
         if(m_parentWindow is LESurfacingWindow && variant > 1)
         {
            if(this.m_newBuyBt)
            {
               removeWidget(this.m_newBuyBt);
               this.m_newBuyBt = null;
            }
            this.m_newBuyBt = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,"","" + m_farmItem.cash,this.onBuyCallback,false,false,true)) as FarmAnimatedCashButton;
         }
         else
         {
            super.setupBuyButton();
         }
      }
      
      public function getSlotItemCost() : int
      {
         return m_farmItem.cash;
      }
      
      public function buyItem() : void
      {
         var price:int = 0;
         if(m_farmItem != null)
         {
            price = getItemPrice();
            if(Global.player.canBuyCash(price))
            {
               TransactionManager.addTransaction(new TBuyItemPutGiftbox(m_farmItem,Currency.CASH,1,false,false));
            }
            if(this.m_popup)
            {
               this.m_popup.visible = true;
               this.m_popup.element.gotoAndPlay(2);
            }
         }
      }
   }
}

