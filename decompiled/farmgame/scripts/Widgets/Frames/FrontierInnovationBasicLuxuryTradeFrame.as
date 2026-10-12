package Widgets.Frames
{
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FrontierInnovationBasicLuxuryTradeSlot;
   import Widgets.Windows.FrontierInnovationBarnWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FrontierInnovationBasicLuxuryTradeFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String;
      
      private var m_frameName:String;
      
      private var m_resourceTpe:String;
      
      private var m_r1Resource:String;
      
      private var m_r2Resource:String;
      
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
      
      private var emptySlot:int;
      
      private var R1SlotActive:Boolean = false;
      
      private var R2SlotActive:Boolean = false;
      
      private var m_flag:Boolean;
      
      private var m_itemCode:String;
      
      private const BASIC_TRADE_MC:String = "basic_trade_mc";
      
      private const LUXURY_TRADE_MC:String = "luxury_trade_mc";
      
      private var m_window:FrontierInnovationBarnWindow;
      
      public function FrontierInnovationBasicLuxuryTradeFrame(element:DisplayObject, featureName:String, window:FrontierInnovationBarnWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         this.m_frameName = element.name;
         super(element);
         this.m_resourceTpe = m_element.name;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FrontierInnovationBasicLuxuryTradeSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var data:Array = null;
         var temp:Object = null;
         m_slotData = [];
         data = this.getSortedSlotData();
         for(var i:int = 0; i < data.length; i++)
         {
            temp = data[i];
            m_slotData.push({
               "Count":temp["value"],
               "resourceCode":temp["key"]
            });
         }
      }
      
      private function initialise() : void
      {
         this.R1 = -1;
         this.R2 = -1;
         this.R1SlotActive = false;
         this.R2SlotActive = false;
         this.m_confirmBt.visible = false;
      }
      
      override protected function getSlotPrefix() : String
      {
         return "item";
      }
      
      public function getSortedSlotData() : Array
      {
         var sorted:Array = null;
         var index:int = 0;
         var temp:Object = null;
         var j:int = 0;
         if(this.m_frameName == this.BASIC_TRADE_MC)
         {
            sorted = this.manager.getSortedBasicFrameData();
         }
         else if(this.m_frameName == this.LUXURY_TRADE_MC)
         {
            sorted = this.manager.getSortedLuxuryFrameData();
         }
         if(this.m_flag)
         {
            for(j = 0; j < sorted.length; j++)
            {
               temp = sorted[j];
               if(temp["key"] == this.m_itemCode)
               {
                  index = j;
                  break;
               }
            }
            temp = sorted[0];
            sorted[0] = sorted[index];
            sorted[index] = temp;
         }
         return sorted;
      }
      
      public function setFrameData(flag:Boolean, itemCode:String) : void
      {
         this.m_flag = flag;
         this.m_itemCode = itemCode;
         this.refresh();
         this.m_flag = false;
         this.m_itemCode = "";
      }
      
      public function setEmptySlot(slotNumber:int) : void
      {
         this.emptySlot = slotNumber;
      }
      
      public function slotActive() : Boolean
      {
         if(this.R1SlotActive)
         {
            return true;
         }
         return false;
      }
      
      public function setR2(r2:int, r2Name:String) : void
      {
         this.R2 = r2;
         this.m_r2Resource = r2Name;
         this.R2SlotActive = true;
      }
      
      public function setR1(r1:int, r1Name:String) : void
      {
         this.R1 = r1;
         this.m_r1Resource = r1Name;
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
      
      private function disableSlotSelectButton() : void
      {
         this.m_window.disableTradeSlotsButton(this.m_frameName);
      }
      
      public function onConform() : void
      {
         this.disableSlotSelectButton();
         this.manager.onTradePostConfirm(this.m_r1Resource,this.m_r2Resource,this.emptySlot);
      }
      
      private function onCancelButton(event:Event) : void
      {
         this.initialise();
         this.manager.clearTradeSlot(this.m_frameName);
         this.manager.closeTradeFrame(this.m_frameName);
         this.m_window.clearFrameSlot(this.m_frameName,this.R2);
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      public function clear() : void
      {
         super.clearSlots();
      }
   }
}

