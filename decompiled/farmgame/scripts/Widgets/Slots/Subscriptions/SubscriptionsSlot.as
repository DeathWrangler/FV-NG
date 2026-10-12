package Widgets.Slots.Subscriptions
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Windows.Subscriptions.SubscriptionsMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   
   public class SubscriptionsSlot extends ZwSlotFrame
   {
      
      public static const OFFER_STATUS_CLAIMED:int = 1;
      
      public static const OFFER_STATUS_AVAILABLE:int = 0;
      
      private var m_parentWindow:SubscriptionsMainWindow;
      
      private var m_checkmark:ZwBaseWidget;
      
      private var m_dealAvailable:SubscriptionsDealFrame;
      
      private var m_dealClaimed:SubscriptionsDealFrame;
      
      private var m_claimButtons:Vector.<FarmAnimatedTextButton>;
      
      private var m_fireworks:Vector.<ZwBaseWidget>;
      
      private var m_tradingPackage:int;
      
      private var m_tradingCost:int;
      
      private var m_slotIndex:int;
      
      public function SubscriptionsSlot(element:DisplayObject, parentWindow:SubscriptionsMainWindow)
      {
         var farmAnimatedButton:FarmAnimatedButton = null;
         var firework:ZwBaseWidget = null;
         super(element);
         this.m_parentWindow = parentWindow;
         addWidget(this.m_checkmark = new ZwBaseWidget(m_element.checkMark_mc));
         addWidget(this.m_dealAvailable = new SubscriptionsDealFrame(m_element.deal_available_mc));
         this.m_claimButtons = new Vector.<FarmAnimatedTextButton>();
         for(var i:int = 0; m_element["trade_" + i + "_bt"] != null; i++)
         {
            farmAnimatedButton = new FarmAnimatedTextButton(m_element["trade_" + i + "_bt"],"",this.showConfirmationPopup);
            this.m_claimButtons.push(farmAnimatedButton);
            addWidget(farmAnimatedButton);
         }
         this.m_fireworks = new Vector.<ZwBaseWidget>();
         for(i = 0; m_element["fireworks_" + i + "_mc"] != null; i++)
         {
            firework = new ZwBaseWidget(m_element["fireworks_" + i + "_mc"]);
            this.animateFireworks(firework.element as MovieClip);
            this.m_fireworks.push(firework);
            addWidget(firework);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var firework:ZwBaseWidget = null;
         var canTrade:Boolean = false;
         var farmAnimatedButton:FarmAnimatedTextButton = null;
         this.m_tradingPackage = data.amount;
         this.m_tradingCost = data.tradingCost;
         var alreadyTraded:* = int(data.alreadyTraded);
         var i:int = 0;
         while(i < this.m_claimButtons.length && i < data.tradingLimit)
         {
            farmAnimatedButton = this.m_claimButtons[i];
            if(alreadyTraded > 0)
            {
               alreadyTraded--;
               farmAnimatedButton.text = "Claimed";
               farmAnimatedButton.enabled = false;
            }
            else
            {
               farmAnimatedButton = this.m_claimButtons[i];
               farmAnimatedButton.text = "Trade";
            }
            farmAnimatedButton.visible = true;
            i++;
         }
         for each(firework in this.m_fireworks)
         {
            firework.visible = true;
         }
         canTrade = data.alreadyTraded < data.tradingLimit;
         this.m_checkmark.visible = !canTrade;
         if(!canTrade)
         {
            (this.m_dealAvailable.element as MovieClip).filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         this.m_dealAvailable.visible = true;
         this.m_dealAvailable.fcAmount = this.m_tradingPackage;
         this.m_dealAvailable.coninsAmount = this.m_tradingCost;
      }
      
      private function animateFireworks(element:MovieClip, stopAnimation:Boolean = true) : void
      {
         var i:int = 0;
         if(stopAnimation)
         {
            element.stop();
            for(i = 0; i < element.numChildren; i++)
            {
               (element.getChildAt(i) as MovieClip).stop();
            }
         }
         else
         {
            element.play();
            for(i = 0; i < element.numChildren; i++)
            {
               (element.getChildAt(i) as MovieClip).play();
            }
         }
      }
      
      private function showConfirmationPopup(event:Event) : void
      {
         var pattern:String = null;
         var regExp:RegExp = null;
         var sellMessage:String = null;
         var confirmationPopup:GenericPopup = null;
         var message:String = null;
         var notEnoughDialog:GenericPopup = null;
         if(Global.player.gold > this.m_tradingCost)
         {
            pattern = "\\d+";
            regExp = new RegExp(pattern,event.currentTarget.name as String);
            this.m_slotIndex = regExp.exec(event.currentTarget.name as String);
            sellMessage = ZLocUtils.t("Dialogs","Subscriptions_Slot_Confirmation",{
               "coins":this.m_tradingCost,
               "cash":this.m_tradingPackage
            });
            confirmationPopup = new GenericPopup(sellMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.exchangeCoinsForCash);
            UI.displayPopup(confirmationPopup,false,"FleaMarket_sellConfirmation",true);
         }
         else
         {
            message = ZLocUtils.t("Dialogs","Subscriptions_Slot_NotEnough");
            notEnoughDialog = new GenericPopup(message);
            UI.displayPopup(notEnoughDialog,false,"NotEnoughCoins",true);
         }
      }
      
      private function exchangeCoinsForCash(event:GenericPopupEvent) : void
      {
         var tradingTransaction:TGenericTransaction = null;
         var subsriptionsData:Object = null;
         var firework:MovieClip = null;
         if(Global.player.gold > this.m_tradingCost && event.button == GenericPopup.ACCEPT)
         {
            if(this.m_fireworks[this.m_slotIndex] != null)
            {
               firework = this.m_fireworks[this.m_slotIndex].element as MovieClip;
               this.animateFireworks(firework as MovieClip,false);
            }
            if(this.m_claimButtons[this.m_slotIndex] != null)
            {
               this.m_claimButtons[this.m_slotIndex].enabled = false;
               this.m_claimButtons[this.m_slotIndex].text = "Claimed";
               (this.m_claimButtons[this.m_slotIndex].element.generic_tf as TextField).filters = [new GlowFilter(11635788,1,2,2,2000)];
            }
            FarmStatsManager.count(SubscriptionsMainWindow.STATS_COUNTER,SubscriptionsMainWindow.STATS_KINGDOM,"use_package",this.m_tradingPackage.toString());
            FarmStatsManager.count(SubscriptionsMainWindow.STATS_COUNTER,SubscriptionsMainWindow.STATS_KINGDOM,"convert",this.m_tradingCost.toString());
            FarmStatsManager.count(SubscriptionsMainWindow.STATS_COUNTER,SubscriptionsMainWindow.STATS_KINGDOM,"earn",this.m_tradingPackage.toString());
            Global.player.gold -= this.m_tradingCost;
            Global.player.cash += this.m_tradingPackage;
            tradingTransaction = new TGenericTransaction("SubscriptionsService","tradePackage",null,[this.m_tradingPackage]);
            TransactionManager.addTransaction(tradingTransaction,true);
            subsriptionsData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS,SubscriptionsMainWindow.DEFAULT_SUBSCRIPTION_CODE);
            if(subsriptionsData.hasOwnProperty(this.m_tradingPackage.toString()) && Boolean(subsriptionsData[this.m_tradingPackage.toString()].hasOwnProperty("alreadyTraded")))
            {
               ++subsriptionsData[this.m_tradingPackage.toString()]["alreadyTraded"];
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.SUBSCRIPTIONS,SubscriptionsMainWindow.DEFAULT_SUBSCRIPTION_CODE,subsriptionsData);
            }
            else
            {
               ErrorManager.addError("Subscription plan " + SubscriptionsMainWindow.DEFAULT_SUBSCRIPTION_CODE + " [ Package " + this.m_tradingPackage.toString() + " not found]");
            }
         }
      }
   }
}

import Engine.Utilities;
import Widgets.Core.Frames.ZwFrame;
import Widgets.Core.TextFields.ZwTextField;
import flash.display.DisplayObject;

class SubscriptionsDealFrame extends ZwFrame
{
   
   private var m_fcText:ZwTextField;
   
   private var m_coinsCostText:ZwTextField;
   
   public function SubscriptionsDealFrame(element:DisplayObject)
   {
      super(element);
      addWidget(this.m_fcText = new ZwTextField(m_element.fc_tf));
      addWidget(new ZwTextField(m_element.description_tf,"FOR ONLY"));
      addWidget(this.m_coinsCostText = new ZwTextField(m_element.cost_tf));
   }
   
   public function set fcAmount(amount:int) : void
   {
      this.m_fcText.text = amount.toString();
   }
   
   public function set coninsAmount(amount:int) : void
   {
      this.m_coinsCostText.text = Utilities.formatNumber(amount);
   }
}
