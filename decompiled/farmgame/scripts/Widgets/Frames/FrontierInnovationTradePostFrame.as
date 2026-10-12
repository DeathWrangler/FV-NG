package Widgets.Frames
{
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FrontierInnovationTradePostSlot;
   import Widgets.Windows.FrontierInnovationTradePostWindow;
   import flash.display.DisplayObject;
   
   public class FrontierInnovationTradePostFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String;
      
      private var m_frameName:String;
      
      private var m_resourceTpe:String;
      
      private var m_confirmBt:FarmAnimatedTextButton;
      
      private var m_cancelBt:FarmAnimatedTextButton;
      
      private var m_itemTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      internal var manager:FrontierInnovationManager;
      
      private const CONFIRM_BT:String = "confirm_bt";
      
      private const CANCEL_BT:String = "cancel_bt";
      
      private const ITEM_TF:String = "item_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private var R1:int;
      
      private var R2:int;
      
      private var R1SlotActive:Boolean = false;
      
      private var R2SlotActive:Boolean = false;
      
      private var m_window:FrontierInnovationTradePostWindow;
      
      public function FrontierInnovationTradePostFrame(element:DisplayObject, featureName:String, window:FrontierInnovationTradePostWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
         this.m_resourceTpe = m_element.name;
         this.m_frameName = m_element.name;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FrontierInnovationTradePostSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var slot:Array = null;
         var tempData:* = undefined;
         m_slotData = [];
         var data:Object = this.manager.getTradePostData();
         for(var i:int = 0; i < 6; i++)
         {
            slot = data[i];
            tempData = [];
            tempData.push({
               "Status":slot[0],
               "R1":slot[1],
               "R2":slot[2],
               "TD":slot[3],
               "userName":slot[4],
               "userPic":slot[5]
            });
            m_slotData.push(tempData);
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot";
      }
      
      public function activeConformTradeButton() : void
      {
         this.m_confirmBt.visible = true;
      }
      
      public function getSlotNameById(r2:int) : String
      {
         var slot:String = null;
         switch(r2)
         {
            case 0:
               slot = "item0_mc";
               break;
            case 1:
               slot = "item1_mc";
               break;
            case 2:
               slot = "item2_mc";
         }
         return slot;
      }
      
      public function slotActive() : Boolean
      {
         if(this.R2SlotActive)
         {
            return true;
         }
         return false;
      }
      
      public function setR2Slot(r2:int) : void
      {
         this.R2 = r2;
         this.R2SlotActive = true;
      }
      
      public function setR1(r1:int) : void
      {
         this.R1 = r1;
         this.R1SlotActive = true;
      }
      
      public function getR1() : int
      {
         return this.R1;
      }
      
      public function getR2() : int
      {
         return this.R2;
      }
   }
}

