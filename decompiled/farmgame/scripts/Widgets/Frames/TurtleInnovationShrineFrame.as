package Widgets.Frames
{
   import Managers.TurtleInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.TurtleInnovationShrineSlot;
   import flash.display.DisplayObject;
   
   public class TurtleInnovationShrineFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      public function TurtleInnovationShrineFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TurtleInnovationShrineSlot(slotElement,this.m_featureName,this);
      }
      
      override protected function setupData() : void
      {
         var shrines:Object = TurtleInnovationManager.getInstance().shrines;
         for(var i:int = 0; i < shrines.length; i++)
         {
            m_slotData.push(shrines[i]);
         }
      }
   }
}

