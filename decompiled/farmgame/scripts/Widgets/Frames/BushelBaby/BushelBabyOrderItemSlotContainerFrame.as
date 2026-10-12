package Widgets.Frames.BushelBaby
{
   import Classes.BushelBaby.BushelBabyNPCLevel;
   import Classes.BushelBaby.BushelBabyOrderItem;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.BushelBabyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.BushelBaby.BushelBabyOrderItemSlot;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class BushelBabyOrderItemSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      protected var m_levelData:BushelBabyNPCLevel;
      
      private var m_headerTextField:ZwTextField;
      
      private var m_completeButton:FarmAnimatedTextButton;
      
      private var m_itemSlots:Vector.<BushelBabyOrderItemSlot>;
      
      public function BushelBabyOrderItemSlotContainerFrame(element:DisplayObject)
      {
         var slotName:String = null;
         super(element);
         if(m_element.header_tf)
         {
            this.m_headerTextField = addWidget(new ZwTextField(m_element.header_tf,"")) as ZwTextField;
         }
         this.m_completeButton = addWidget(new FarmAnimatedTextButton(m_element.accept_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Raise"),this.onAcceptButtonClick)) as FarmAnimatedTextButton;
         this.m_itemSlots = new Vector.<BushelBabyOrderItemSlot>();
         var slotCount:int = 1;
         while(m_element.hasOwnProperty(slotName = "slot_" + slotCount + "_mc") && slotCount < 10)
         {
            this.m_itemSlots.push(addWidget(new BushelBabyOrderItemSlot(m_element[slotName]) as BushelBabyOrderItemSlot));
            slotCount++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BushelBabyOrderItemSlot(slotElement);
      }
      
      override public function release() : void
      {
         this.m_levelData = null;
         this.m_headerTextField = null;
         this.m_completeButton = null;
         this.m_itemSlots = null;
         super.release();
      }
      
      override protected function setupData() : void
      {
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         this.refresh();
      }
      
      public function populate(data:Object) : void
      {
         this.m_levelData = data as BushelBabyNPCLevel;
         if(this.m_levelData)
         {
            this.items = this.m_levelData.orderItemArray;
         }
      }
      
      override public function refresh() : void
      {
         if(this.m_levelData)
         {
            if(this.m_headerTextField)
            {
               this.m_headerTextField.text = this.m_levelData.friendlyItemTitle;
            }
            this.m_completeButton.enabled = this.m_completeButton.visible = this.m_levelData.canCompleteOrder();
            this.setSlots(this.m_levelData.orderItems);
         }
         super.refresh();
      }
      
      private function setSlots(orderItems:Vector.<BushelBabyOrderItem>) : void
      {
         var visibleSlotes:int = 0;
         var i:int = 0;
         var length:int = 0;
         if(orderItems.length)
         {
            visibleSlotes = int(orderItems.length);
            i = 0;
            length = int(this.m_itemSlots.length);
            while(i < length)
            {
               if(i < visibleSlotes)
               {
                  this.m_itemSlots[i].visible = true;
                  this.m_itemSlots[i].populate(orderItems[i]);
               }
               else
               {
                  this.m_itemSlots[i].visible = false;
               }
               i++;
            }
         }
      }
      
      private function onAcceptButtonClick(event:MouseEvent) : void
      {
         this.m_levelData.npc.system.logStats("raise",this.m_levelData.item.name);
         if(this.m_completeButton.enabled)
         {
            BushelBabyManager.instance.completeNPCLevel(this.m_levelData);
         }
      }
   }
}

