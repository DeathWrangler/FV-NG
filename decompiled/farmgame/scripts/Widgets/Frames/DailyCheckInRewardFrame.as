package Widgets.Frames
{
   import Managers.DailyCheckInManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.DailyCheckInRewardSlot;
   import Widgets.Windows.DailyCheckInWindow;
   import flash.display.DisplayObject;
   
   public class DailyCheckInRewardFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:DailyCheckInWindow;
      
      private var m_goodieUrl:String;
      
      private var m_rewards:Array;
      
      public function DailyCheckInRewardFrame(element:DisplayObject, goodieUrl:String, rewards:Array, window:DailyCheckInWindow)
      {
         this.m_window = window;
         this.m_goodieUrl = goodieUrl;
         this.m_rewards = rewards;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DailyCheckInRewardSlot(slotElement,this.m_goodieUrl,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var rewards:Array = null;
         var i:int = 0;
         if(this.m_rewards)
         {
            rewards = DailyCheckInManager.getInstance().getRewardItemCodes(this.m_rewards);
            for(i = 0; i < 3; i++)
            {
               m_slotData.push({"itemCode":rewards[i]});
            }
         }
      }
      
      override public function release() : void
      {
         var slot:ZwSlotFrame = null;
         this.m_window = null;
         this.m_rewards = null;
         for each(slot in slots)
         {
            slot.release();
         }
         super.release();
      }
   }
}

