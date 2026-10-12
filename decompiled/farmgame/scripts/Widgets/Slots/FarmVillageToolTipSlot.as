package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmVillageManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FarmVillageToolTipSlot extends ZwSlotFrame
   {
      
      private static const CURRENCY_ICON_URL:String = "assets/dialogs/FV_Support/FV_FarmVillage/FV_VillageCoin_icon.png";
      
      private static const EXPERIENCE_ICON_URL:String = "assets/dialogs/FV_Support/FV_FarmVillage/FV_VillagePoints_icon.png";
      
      private static const TOOLTIP:String = "toolTip";
      
      private static const ICON:String = "icon";
      
      private static const AMOUNT:String = "amount";
      
      private static const CURRENCY_REWARD:String = "currencyReward";
      
      private static const EXPERIENCE_REWARD:String = "xpReward";
      
      private static const ITEM_NAME:String = "itemName";
      
      private static const QUANTITY:String = "quantity";
      
      private static const SKIP_TIME:String = "skipTime";
      
      private static const ATTRIBUTES:String = "@attributes";
      
      private static const SLOT_PREFIX:String = "slot_";
      
      private static const SLOT_POSTFIX:String = "_mc";
      
      private var m_order:Object;
      
      private var m_acceptButton:FarmAnimatedButton;
      
      private var m_completeOrder:FarmAnimatedCashButton;
      
      private var m_skipButton:FarmAnimatedButton;
      
      private var m_skipBuyButton:FarmAnimatedCashButton;
      
      private var m_requirementSlots:Array;
      
      private var m_rewardSlotData:Array;
      
      private var m_areRequirementsFulfilled:Boolean;
      
      private var m_slot:int;
      
      private var m_numberOfRequirements:int;
      
      private var m_canSkip:Boolean;
      
      private var m_skipTimerTextField:ZwTextField;
      
      private var m_orderTitle:ZwTextField;
      
      private var m_rewardsFrame:GenericSlotContainerFrame;
      
      private var m_parentWindow:FarmWindow;
      
      public function FarmVillageToolTipSlot(element:MovieClip, parentWidow:FarmWindow, slot:int = 0)
      {
         var slotString:String = null;
         super(element);
         this.m_canSkip = true;
         this.m_slot = slot;
         this.m_parentWindow = parentWidow;
         this.m_requirementSlots = new Array();
         this.m_rewardSlotData = new Array();
         slot = 0;
         if(m_element)
         {
            slotString = SLOT_PREFIX + slot + SLOT_POSTFIX;
            while(m_element[slotString])
            {
               this.m_requirementSlots.push(new FarmVillageToolTipRequirementSlot(m_element[slotString],0,null));
               addWidget(this.m_requirementSlots[slot],false);
               slot++;
               slotString = SLOT_PREFIX + slot + SLOT_POSTFIX;
            }
         }
         if(m_element["subheader_tf"])
         {
            addWidget(new ZwTextField(m_element["subheader_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageSlotReward")));
         }
         if(m_element["order_title_tf"])
         {
            this.m_orderTitle = new ZwTextField(m_element["order_title_tf"],"");
            addWidget(this.m_orderTitle);
         }
         if(m_element["rewards_mc"])
         {
            this.m_rewardsFrame = new GenericSlotContainerFrame(m_element["rewards_mc"],FarmVillageToolTipRewardSlot,null,this.m_parentWindow);
            addWidget(this.m_rewardsFrame);
         }
         if(m_element["skipText_tf"])
         {
            this.m_skipTimerTextField = new ZwTextField(m_element["skipText_tf"]);
            addWidget(this.m_skipTimerTextField,false);
         }
         if(m_element["skip_bt"])
         {
            this.m_skipButton = new FarmAnimatedButton(m_element["skip_bt"],this.onSkipOrder);
            addWidget(this.m_skipButton);
         }
         if(m_element["skipBuy_bt"])
         {
            this.m_skipBuyButton = new FarmAnimatedCashButton(m_element["skipBuy_bt"],"Skip Now",FarmVillageManager.SKIP_PRICE.toString(),this.onBuySkipOrder,false,false,true);
            addWidget(this.m_skipBuyButton);
         }
         if(m_element["accept_bt"])
         {
            this.m_acceptButton = new FarmAnimatedButton(m_element["accept_bt"],this.onAcceptOrder);
            addWidget(this.m_acceptButton,false);
         }
         if(m_element["completeOrder_bt"])
         {
            this.m_completeOrder = new FarmAnimatedCashButton(m_element["completeOrder_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FinishNow"),"",this.onCompleteOrder,false,false,true);
            addWidget(this.m_completeOrder,false);
         }
      }
      
      public function setOrderData(order:Object) : void
      {
         var requirementsLength:int = 0;
         var slot:FarmVillageToolTipRequirementSlot = null;
         var i:int = 0;
         this.m_order = order;
         if(Boolean(this.m_order) && Boolean(this.m_order.requirements) && Boolean(this.m_requirementSlots))
         {
            requirementsLength = int(this.m_requirementSlots.length);
            for(i = 0; i < requirementsLength; i++)
            {
               slot = this.m_requirementSlots[i];
               slot.visible = this.m_order.requirements.length > i;
            }
         }
      }
      
      public function update() : void
      {
         var slot:int = 0;
         var allSlotRequirementsMet:Boolean = false;
         var completeNowCost:int = 0;
         var itemName:String = null;
         var quantity:int = 0;
         var requirementsSlot:FarmVillageToolTipRequirementSlot = null;
         var requirement:Object = null;
         var rewardItem:FarmItem = null;
         var rewards:Array = null;
         var currencyReward:Object = null;
         var itemReward:Object = null;
         var experienceReward:Object = null;
         var skipTimeRemains:Boolean = false;
         if(this.m_order)
         {
            slot = 0;
            allSlotRequirementsMet = true;
            if(this.m_order.slot)
            {
               this.m_slot = this.m_order.slot;
            }
            if(this.m_order.requirements)
            {
               for each(requirement in this.m_order.requirements)
               {
                  if(Boolean(requirement[ITEM_NAME]) && Boolean(requirement[QUANTITY]))
                  {
                     itemName = requirement[ITEM_NAME];
                     quantity = int(requirement[QUANTITY]);
                  }
                  else if(Boolean(requirement[ATTRIBUTES][ITEM_NAME]) && Boolean(requirement[ATTRIBUTES][QUANTITY]))
                  {
                     itemName = requirement[ATTRIBUTES][ITEM_NAME];
                     quantity = int(requirement[ATTRIBUTES][QUANTITY]);
                  }
                  if(Boolean(itemName) && Boolean(quantity))
                  {
                     if(this.m_requirementSlots.length > slot)
                     {
                        requirementsSlot = this.m_requirementSlots[slot];
                        requirementsSlot.setRequirements(itemName,quantity,this.m_order.slot);
                        if(!requirementsSlot.areRequirementsFulfilled())
                        {
                           allSlotRequirementsMet = false;
                           completeNowCost += requirementsSlot.getRequirementCashCost() * quantity - requirementsSlot.getStorageCount();
                        }
                        requirementsSlot.visible = true;
                     }
                  }
                  slot++;
               }
               this.m_numberOfRequirements = slot;
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_order["reward"]);
               rewards = new Array();
               currencyReward = new Object();
               currencyReward[TOOLTIP] = this.m_order[CURRENCY_REWARD] + " " + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"menu_villageCurrency");
               currencyReward[ICON] = CURRENCY_ICON_URL;
               currencyReward[AMOUNT] = this.m_order[CURRENCY_REWARD];
               itemReward = new Object();
               if(rewardItem)
               {
                  itemReward[TOOLTIP] = rewardItem.friendlyTitle;
                  itemReward[ICON] = rewardItem.iconUrl;
                  itemReward[AMOUNT] = 1;
                  itemReward["itemName"] = rewardItem.name;
               }
               experienceReward = new Object();
               experienceReward[TOOLTIP] = this.m_order[EXPERIENCE_REWARD] + " " + ZLocUtils.t("FarmGame",FarmVillageManager.WORLD_SCORE_NAME);
               experienceReward[ICON] = EXPERIENCE_ICON_URL;
               experienceReward[AMOUNT] = this.m_order[EXPERIENCE_REWARD];
               rewards.push(currencyReward);
               rewards.push(itemReward);
               rewards.push(experienceReward);
               if(this.m_rewardsFrame)
               {
                  this.m_rewardsFrame.setData(rewards);
                  this.m_rewardsFrame.refresh();
               }
               if(!allSlotRequirementsMet)
               {
                  (this.m_completeOrder.element["amount_tf"] as TextField).text = completeNowCost.toString();
               }
               this.m_completeOrder.enabled = !allSlotRequirementsMet;
               this.m_completeOrder.visible = !allSlotRequirementsMet;
               this.m_acceptButton.enabled = allSlotRequirementsMet;
               this.m_acceptButton.visible = allSlotRequirementsMet;
               this.m_areRequirementsFulfilled = allSlotRequirementsMet;
               skipTimeRemains = FarmVillageManager.instance.timeUntilCanSkipAgain(this.m_slot) > 0;
               if(skipTimeRemains)
               {
                  this.m_skipTimerTextField.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVilageSkipTimer",{"time":FarmVillageManager.instance.timeUntilCanSkipAgain(this.m_slot) + 1});
               }
               if(this.m_skipButton)
               {
                  this.m_skipButton.visible = !skipTimeRemains;
               }
               if(this.m_skipBuyButton)
               {
                  this.m_skipBuyButton.visible = skipTimeRemains;
               }
               if(this.m_skipTimerTextField)
               {
                  this.m_skipTimerTextField.visible = skipTimeRemains;
               }
               if(this.m_order["npcName"])
               {
                  this.m_orderTitle.text = this.m_order.npcName;
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_order = null;
         this.m_acceptButton = null;
         this.m_completeOrder = null;
         this.m_skipButton = null;
         this.m_skipBuyButton = null;
         this.m_requirementSlots = null;
         this.m_rewardSlotData = null;
         this.m_skipTimerTextField = null;
         this.m_orderTitle = null;
         this.m_rewardsFrame = null;
         this.m_parentWindow = null;
         super.release();
      }
      
      private function onSkipOrder(event:Event) : void
      {
         FarmVillageManager.instance.skipOrder(this.m_slot,false);
         if(this.m_skipButton)
         {
            this.m_skipButton.enabled = this.m_canSkip = false;
         }
      }
      
      private function onBuySkipOrder(event:Event) : void
      {
         FarmVillageManager.instance.skipOrder(this.m_slot,true);
         if(this.m_skipButton)
         {
            this.m_skipButton.enabled = this.m_canSkip = false;
         }
      }
      
      private function completeOrder(completeNow:Boolean = false) : void
      {
         FarmVillageManager.instance.completeOrder(this.m_order["slot"],completeNow);
         if(this.m_completeOrder)
         {
            this.m_completeOrder.enabled = false;
         }
         if(this.m_acceptButton)
         {
            this.m_acceptButton.enabled = false;
         }
         this.visible = false;
      }
      
      private function onCompleteOrder(event:Event) : void
      {
         this.completeOrder(true);
      }
      
      private function onAcceptOrder(event:Event) : void
      {
         this.completeOrder();
      }
      
      public function areRequirementsFulfilled() : Boolean
      {
         return this.m_areRequirementsFulfilled;
      }
   }
}

