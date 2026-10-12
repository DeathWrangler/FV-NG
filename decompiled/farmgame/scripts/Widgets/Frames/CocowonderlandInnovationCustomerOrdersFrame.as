package Widgets.Frames
{
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CocowonderlandInnovationCustomerOrderSlot;
   import Widgets.Windows.CocowonderlandInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class CocowonderlandInnovationCustomerOrdersFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "order";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:CocowonderlandInnovationMainWindow;
      
      private var m_featureName:String;
      
      public function CocowonderlandInnovationCustomerOrdersFrame(element:DisplayObject, window:CocowonderlandInnovationMainWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
         m_element.visible = true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CocowonderlandInnovationCustomerOrderSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupData() : void
      {
         var questOrders:Vector.<XML> = null;
         for(var j:int = 0; j < m_slots.length; j++)
         {
            (m_slots[j] as CocowonderlandInnovationCustomerOrderSlot).stopAnimation();
         }
         m_slotData = [];
         questOrders = CocowonderlandInnovationManager.getInstance(this.m_featureName).getCustomerOrders();
         for(var i:int = 0; i < questOrders.length; i++)
         {
            m_slotData.push({
               "questOrderSlotNumber":i,
               "orderXML":questOrders[i]
            });
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      public function playAnimation(cookedOrder:String) : void
      {
         for(var i:int = 0; i < m_slots.length; i++)
         {
            if((m_slots[i] as CocowonderlandInnovationCustomerOrderSlot).playAnimation(cookedOrder))
            {
               break;
            }
         }
      }
   }
}

