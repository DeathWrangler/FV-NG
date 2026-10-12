package Widgets.Frames.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingOrder;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FeatureCrafting.FeatureCraftingOrderDetailSlot;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingOrderDetailsFrame extends FarmSlotContainerFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_acceptCallback:Function;
      
      private var m_completeNowCallback:Function;
      
      protected var m_data:FeatureCraftingOrder;
      
      private var m_headerTextField:ZwTextField;
      
      private var m_infoTextField:ZwTextField;
      
      private var m_rewardSlots:FeatureCraftingRewardSlotContainerFrame;
      
      private var m_acceptButton:FarmAnimatedTextButton;
      
      private var m_completeNowButton:FarmAnimatedCashButton;
      
      public function FeatureCraftingOrderDetailsFrame(element:DisplayObject, acceptCallback:Function, completeNowCallback:Function)
      {
         super(element);
         this.m_acceptCallback = acceptCallback;
         this.m_completeNowCallback = completeNowCallback;
         if(m_element.header_tf)
         {
            this.m_headerTextField = addWidget(new ZwTextField(m_element.header_tf," ")) as ZwTextField;
         }
         if(m_element.subheader_tf)
         {
            this.m_infoTextField = addWidget(new ZwTextField(m_element.subheader_tf," ")) as ZwTextField;
         }
         if(m_element.rewards_mc)
         {
            this.m_rewardSlots = addWidget(new FeatureCraftingRewardSlotContainerFrame(m_element.rewards_mc)) as FeatureCraftingRewardSlotContainerFrame;
         }
         this.m_acceptButton = addWidget(new FarmAnimatedTextButton(m_element.accept_bt,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"OrderTooltip_AcceptButton"),this.onAcceptButtonClick)) as FarmAnimatedTextButton;
         this.m_completeNowButton = addWidget(new FarmAnimatedCashButton(m_element.completeOrder_bt,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"OrderTooltip_CompleteNowButton"),"00",this.onCompleteButtonClick)) as FarmAnimatedCashButton;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FeatureCraftingOrderDetailSlot(slotElement);
      }
      
      override public function release() : void
      {
         this.m_acceptCallback = null;
         this.m_data = null;
         this.m_headerTextField = null;
         this.m_infoTextField = null;
         this.m_rewardSlots = null;
         this.m_acceptButton = null;
         this.m_completeNowButton = null;
         super.release();
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         this.refresh();
      }
      
      public function populate(data:Object) : void
      {
         this.m_data = data as FeatureCraftingOrder;
         if(this.m_data)
         {
            this.items = this.m_data.requiredGoods();
            this.refresh();
         }
      }
      
      override public function refresh() : void
      {
         if(this.m_data)
         {
            if(this.m_headerTextField)
            {
               this.m_headerTextField.text = "";
            }
            if(this.m_infoTextField)
            {
               this.m_infoTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"OrderTooltip_Rewards");
            }
            if(this.m_rewardSlots)
            {
               this.m_rewardSlots.system = this.m_data.system;
               this.m_rewardSlots.items = this.m_data.rewards;
            }
            this.m_acceptButton.enabled = !this.m_data.isComplete && this.m_data.canFillOrder();
            this.m_acceptButton.visible = this.m_acceptButton.enabled;
            this.m_completeNowButton.setAmountText(String(this.m_data.getBuyRemainingGoodsCost()));
            this.m_completeNowButton.enabled = !this.m_acceptButton.visible;
            this.m_completeNowButton.visible = this.m_completeNowButton.enabled;
         }
         super.refresh();
      }
      
      private function onAcceptButtonClick(event:MouseEvent) : void
      {
         if(this.m_acceptButton.enabled)
         {
            if(this.m_acceptCallback != null)
            {
               this.m_acceptCallback(event);
               this.refresh();
            }
         }
      }
      
      private function onCompleteButtonClick(event:MouseEvent) : void
      {
         var npcName:String = null;
         var message:String = null;
         var cost:int = this.m_data.getBuyRemainingGoodsCost();
         if(cost >= 10)
         {
            npcName = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"NPC_" + this.m_data.orderBoard.npcName);
            message = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"NPCCompleteNow_Confirmation",{
               "cost":cost,
               "horseName":npcName
            });
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onUnlockMessageClose,"NPCCompleteNow_Confirmation",true);
         }
         else
         {
            this.processOrderComplete();
         }
      }
      
      private function onUnlockMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            this.processOrderComplete();
         }
      }
      
      private function processOrderComplete() : void
      {
         if(this.m_completeNowButton.enabled)
         {
            if(this.m_completeNowCallback != null)
            {
               this.m_completeNowCallback(null);
               this.refresh();
            }
         }
      }
   }
}

