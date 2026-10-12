package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.ActionDrivenRewardsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ActionDrivenRewardsSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private static const DEFAULT_REWARD_COST:int = 3;
      
      public static const SERVICE_CLASS:String = "ActionDrivenService";
      
      protected var m_data:Object;
      
      private var m_hitWidget:ZwWidget;
      
      private var m_presentWidget:ZwWidget;
      
      private var m_icon:FarmIcon;
      
      private var m_tickMark:MovieClip;
      
      private var m_counttf:ZwTextField = null;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      public function ActionDrivenRewardsSlot(element:DisplayObject)
      {
         var buyButtonText:String = null;
         super(element);
         addWidget(this.m_icon = new FarmIcon(m_element.icon_mc));
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         addWidget(this.m_presentWidget = new ZwWidget(m_element.present_mc),false);
         addWidget(this.m_hitWidget = new ZwWidget(m_element.hit_bt));
         (this.m_hitWidget.element as SimpleButton).addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         (this.m_hitWidget.element as SimpleButton).useHandCursor = false;
         if(m_element.tick_mc)
         {
            this.m_tickMark = m_element.tick_mc as MovieClip;
            this.m_tickMark.visible = false;
         }
         if(m_element.buyCash_bt)
         {
            buyButtonText = ZLocUtils.t("FarmGame","Buy");
            this.m_buyButton = new FarmAnimatedCashButton(m_element.buyCash_bt,buyButtonText,"0",this.onBuyButtonClicked,false,false,true,"",0);
            addWidget(this.m_buyButton);
            this.m_buyButton.visible = true;
            this.m_buyButton.enabled = true;
         }
         if(m_element.count_tf)
         {
            addWidget(this.m_counttf = new ZwTextField(m_element.count_tf));
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         if(this.m_hitWidget)
         {
            (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         }
         this.m_hitWidget = null;
         this.m_icon = null;
         this.m_presentWidget = null;
         this.m_counttf = null;
         super.release();
      }
      
      private function onBuyButtonClicked(event:Event) : void
      {
         var canBuy:Boolean = false;
         var amount:int = 0;
         var parentWindow:ActionDrivenRewardsWindow = null;
         var numRewards:int = 0;
         var rewards:Object = null;
         this.m_buyButton.enabled = false;
         this.m_buyButton.alpha = 0.6;
         var item:FarmItem = null;
         if(Boolean(this.m_data) && Boolean(this.m_data["name"]))
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_data["name"]);
         }
         if(item)
         {
            canBuy = Global.player.canBuyCash(item.cash,false);
            if(canBuy)
            {
               amount = item.cash > 0 ? item.cash : DEFAULT_REWARD_COST;
               Global.player.cash -= amount;
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"buyRewardItem",null,[this.m_data["featureName"],this.m_data["name"]]));
               parentWindow = getParentWindow() as ActionDrivenRewardsWindow;
               this.m_data["isReward"] = true;
               this.m_tickMark.visible = true;
               this.m_buyButton.enabled = true;
               this.m_buyButton.alpha = 1;
               numRewards = FeatureOptionsManager.getInstance().getFeatureOption(this.m_data["featureName"],"rewardCount") as int;
               rewards = FeatureOptionsManager.getInstance().getFeatureOption(this.m_data["featureName"],"allItems") as Object;
               if(rewards.hasOwnProperty(this.m_data["name"]))
               {
                  rewards[this.m_data["name"]] = parseInt(rewards[this.m_data["name"]]) + 1;
               }
               FeatureOptionsManager.getInstance().setFeatureOption(this.m_data["featureName"],"allItems",rewards);
               FeatureOptionsManager.getInstance().setFeatureOption(this.m_data["featureName"],"rewardCount",numRewards + 1);
               parentWindow = getParentWindow() as ActionDrivenRewardsWindow;
               Global.player.addGift(this.m_data["name"]);
               if(parentWindow)
               {
                  parentWindow.updateRewardCounter(numRewards + 1);
               }
            }
            else
            {
               this.m_buyButton.enabled = true;
               this.m_buyButton.alpha = 1;
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         var item:FarmItem = null;
         var element:MovieClip = null;
         var revealed:Boolean = false;
         var amountText:String = null;
         var amount:String = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_data["name"]);
            if(item)
            {
               this.m_hitWidget.visible = true;
               this.m_icon.loadIcon(item.iconUrl);
               element = m_element as MovieClip;
               revealed = Boolean(this.m_data["revealed"]);
               if(revealed)
               {
                  element.gotoAndStop(element.totalFrames);
                  this.m_icon.visible = true;
                  this.m_hitWidget.detachTooltip();
                  this.m_hitWidget.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
                  if(Boolean(this.m_data["isReward"]) && Boolean(this.m_data["isReward"] == true) && Boolean(this.m_tickMark))
                  {
                     this.m_tickMark.visible = true;
                  }
                  else if(this.m_tickMark)
                  {
                     this.m_tickMark.visible = false;
                  }
                  if(Boolean(this.m_data["count"]) && this.m_counttf != null)
                  {
                     this.m_counttf.visible = true;
                     this.m_counttf.text = "x" + this.m_data["count"];
                  }
                  if(this.m_buyButton)
                  {
                     this.m_buyButton.visible = true;
                     amountText = item.cash > 0 ? item.cash.toString() : DEFAULT_REWARD_COST.toString();
                     this.m_buyButton.setAmountText(amountText);
                  }
               }
               else
               {
                  element.gotoAndStop(1);
                  if(this.m_buyButton)
                  {
                     amount = item.cash > 0 ? item.cash.toString() : DEFAULT_REWARD_COST.toString();
                     this.m_buyButton.setAmountText(amount);
                     this.m_buyButton.visible = false;
                  }
                  if(this.m_tickMark)
                  {
                     this.m_tickMark.visible = false;
                  }
                  this.m_presentWidget.visible = true;
                  this.m_hitWidget.detachTooltip();
               }
            }
         }
      }
      
      public function reveal() : void
      {
         var item:FarmItem = null;
         var parentWindow:ActionDrivenRewardsWindow = null;
         var element:MovieClip = m_element as MovieClip;
         if(element.currentFrame == 1)
         {
            element.play();
            this.m_data["revealed"] = true;
            this.m_icon.visible = true;
            if(this.m_buyButton)
            {
               this.m_buyButton.visible = true;
            }
            if(this.m_tickMark)
            {
               this.m_tickMark.visible = true;
            }
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_data["name"]);
            if(item)
            {
               this.m_hitWidget.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
            }
            parentWindow = getParentWindow() as ActionDrivenRewardsWindow;
            if(parentWindow)
            {
               parentWindow.incrementNumRevealed();
            }
         }
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         this.reveal();
      }
   }
}

