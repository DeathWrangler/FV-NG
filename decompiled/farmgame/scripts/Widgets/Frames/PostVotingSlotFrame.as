package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.PostVotingSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class PostVotingSlotFrame extends GenericTimedSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_TabIndex:int = 0;
      
      public function PostVotingSlotFrame(element:DisplayObject, parentWindow:FarmWindow, featureName:String, tabIndex:int)
      {
         this.m_featureName = featureName;
         this.m_TabIndex = tabIndex;
         super(element,PostVotingSlot,new Array(),parentWindow);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new PostVotingSlot(slotElement,m_parentWindow,this.m_featureName,this.m_TabIndex);
      }
   }
}

