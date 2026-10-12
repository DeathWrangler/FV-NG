package Widgets.Frames
{
   import Managers.WhitewinterInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.WhitewinterInnovationRewardSlot;
   import flash.display.DisplayObject;
   
   public class WhitewinterInnovationRewardWindowFrame extends FarmSlotContainerFrame
   {
      
      public function WhitewinterInnovationRewardWindowFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new WhitewinterInnovationRewardSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var rewardList:Array = WhitewinterInnovationManager.getInstance().rewardsArray;
         for(var i:int = 0; i < rewardList.length; i++)
         {
            m_slotData.push({
               "rewardSlotNumber":i,
               "rewardName":rewardList[i]
            });
         }
      }
   }
}

