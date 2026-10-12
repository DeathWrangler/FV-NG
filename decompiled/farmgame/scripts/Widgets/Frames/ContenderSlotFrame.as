package Widgets.Frames
{
   import Managers.ChoiceDrivenManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.ContenderSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class ContenderSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_window:FarmWindow;
      
      protected var m_featureName:String;
      
      public function ContenderSlotFrame(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ContenderSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      override protected function setupData() : void
      {
         var itemObject:Object = null;
         m_slotData = new Array();
         var contenderObject:Object = ChoiceDrivenManager.getInstance(this.m_featureName).getChooseContenderSlotObject();
         for each(itemObject in contenderObject)
         {
            m_slotData.push(itemObject);
         }
      }
   }
}

