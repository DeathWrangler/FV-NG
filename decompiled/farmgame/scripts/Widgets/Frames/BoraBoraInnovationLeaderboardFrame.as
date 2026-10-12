package Widgets.Frames
{
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.BoraBoraInnovationLeaderboardSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class BoraBoraInnovationLeaderboardFrame extends GenericSlotContainerFrame
   {
      
      private var m_leaderboardName:String;
      
      private var m_highlightbg:MovieClip;
      
      private var m_slotIndex:int = -1;
      
      public function BoraBoraInnovationLeaderboardFrame(element:DisplayObject, leaders:Array, leaderboardName:String, parentWindow:FarmWindow)
      {
         this.m_leaderboardName = leaderboardName;
         super(element,BoraBoraInnovationLeaderboardSlot,leaders,parentWindow);
         if(m_element.hasOwnProperty("mc_highlightbg"))
         {
            this.m_highlightbg = m_element.mc_highlightbg as MovieClip;
            this.m_highlightbg.visible = false;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         ++this.m_slotIndex;
         return new m_slotClass(slotElement,m_parentWindow,this.m_leaderboardName,this.m_slotIndex);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "leaderboardSlot_";
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance();
      }
      
      public function finishLoading(result:Object, showGift:Boolean = false) : void
      {
         var slotData:Array = null;
         if(result)
         {
            slotData = result.slotData as Array;
            if(slotData)
            {
               this.setData(slotData);
            }
         }
      }
      
      override protected function populateSlots(dataIndex:uint = 0) : void
      {
         clearSlots();
         var slotIdx:uint = 0;
         while(slotIdx < m_slots.length && Boolean(m_slots[slotIdx]))
         {
            if(!(Boolean(m_slotData) && dataIndex < m_slotData.length))
            {
               break;
            }
            populateSlot(m_slots[slotIdx] as ZwSlotFrame,m_slotData[dataIndex]);
            slotIdx++;
            dataIndex++;
         }
         m_lastPopulateStartIndex = dataIndex;
      }
   }
}

