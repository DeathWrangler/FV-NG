package Widgets.Slots.Market
{
   import Classes.RewardCard;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.RewardCardsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketMiniSlotFrame;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class MarketRewardCardsDetailSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_callbacks:Object;
      
      private var m_container:MarketMiniSlotFrame;
      
      private var m_data:RewardCard;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_moreTextField:ZwTextField;
      
      private var m_type:String;
      
      private var m_mouseEventListeners:Object;
      
      private var m_stampSlots:Array;
      
      private var m_descriptionText:ZwTextField;
      
      private var m_shopNowButton:FarmAnimatedTextButton;
      
      private var m_titleText:ZwTextField;
      
      public function MarketRewardCardsDetailSlot(element:DisplayObject, container:MarketMiniSlotFrame, callbacks:Object, type:String, mouseEventListeners:Object = null)
      {
         var mouseEvent:String = null;
         var i:int = 0;
         var slotWidget:ZwBaseWidget = null;
         this.m_container = container;
         this.m_callbacks = callbacks;
         this.m_type = type;
         this.m_mouseEventListeners = mouseEventListeners != null ? mouseEventListeners : {};
         for(mouseEvent in this.m_mouseEventListeners)
         {
            element.addEventListener(mouseEvent,this.m_mouseEventListeners[mouseEvent]);
         }
         super(element);
         this.m_stampSlots = new Array();
         for(i = 0; m_element.hasOwnProperty("slot_" + i + "_mc"); i++)
         {
            slotWidget = new ZwBaseWidget(m_element["slot_" + i + "_mc"]);
            this.m_stampSlots.push(slotWidget);
            addWidget(slotWidget);
         }
         addWidget(this.m_descriptionText = new ZwTextField(m_element.body_tf));
         addWidget(this.m_shopNowButton = new FarmAnimatedTextButton(m_element.shopNow_bt,ZLocUtils.t("Dialogs","RewardCardsShopNow"),this.onShopNow));
         addWidget(this.m_titleText = new ZwTextField(m_element.title_tf,ZLocUtils.t("Dialogs","RewardCards_" + this.m_type)));
      }
      
      override public function release() : void
      {
         var mouseEvent:String = null;
         this.m_callbacks = null;
         this.m_container = null;
         this.m_data = null;
         this.m_nameTextField = null;
         this.m_moreTextField = null;
         this.m_shopNowButton = null;
         this.m_titleText = null;
         for(mouseEvent in this.m_mouseEventListeners)
         {
            element.removeEventListener(mouseEvent,this.m_mouseEventListeners[mouseEvent]);
         }
         this.m_mouseEventListeners = null;
         super.release();
      }
      
      public function get data() : RewardCard
      {
         return this.m_data;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      override public function populate(data:Object) : void
      {
         var owned:int = 0;
         var left:int = 0;
         var purchaseMinPrice:int = 0;
         var rewardMaxPrice:int = 0;
         var leftText:String = null;
         var i:int = 0;
         var stampSlot:ZwBaseWidget = null;
         super.populate(data);
         this.m_data = data as RewardCard;
         if(this.m_data)
         {
            owned = this.m_data.freeCredits + this.m_data.purchaseCount;
            left = Math.max(0,this.m_data.credits - owned);
            purchaseMinPrice = this.m_data.purchaseMinPrice;
            rewardMaxPrice = this.m_data.rewardMaxPrice;
            leftText = ZLocUtils.t("Dialogs","RewardCardsDetailsDescription",{
               "purchaseMinPrice":purchaseMinPrice,
               "rewardMaxPrice":rewardMaxPrice
            });
            this.m_descriptionText.text = leftText;
            this.m_titleText.visible = true;
            this.m_descriptionText.visible = true;
            this.m_shopNowButton.visible = true;
            if(left <= 0)
            {
               this.m_shopNowButton.text = ZLocUtils.t("Dialogs","RewardCardsRedeemNow");
               this.m_shopNowButton.callback = this.onRedeemNow;
            }
            else
            {
               this.m_shopNowButton.text = ZLocUtils.t("Dialogs","RewardCardsShopNow");
               this.m_shopNowButton.callback = this.onShopNow;
            }
            i = 0;
            while(i < owned && this.m_stampSlots[i] != null)
            {
               stampSlot = this.m_stampSlots[i] as ZwBaseWidget;
               if(stampSlot != null)
               {
                  stampSlot.visible = true;
               }
               i++;
            }
         }
      }
      
      private function onShopNow(event:Event) : void
      {
         if(this.m_data != null)
         {
            FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"mp2_activity","look_now",this.m_data.name);
            this.m_data.openMarketForPurchase();
         }
      }
      
      private function onRedeemNow(event:Event) : void
      {
         if(this.m_data != null)
         {
            FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"mp2_activity","redeem_now",this.m_data.name);
            this.m_data.openMarketForRedeem();
         }
      }
   }
}

