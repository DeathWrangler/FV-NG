package Widgets.Frames
{
   import Managers.WinternordInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.WinternordInnovationLeaderboardSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class WinternordInnovationLeaderboardSlotFrame extends GenericSlotContainerFrame
   {
      
      private const LEADERBOARD_COUNT:int = 5;
      
      private var m_leaderboardName:String;
      
      private var m_highlightbg:MovieClip;
      
      public function WinternordInnovationLeaderboardSlotFrame(element:DisplayObject, leaders:Array, leaderboardName:String, parentWindow:FarmWindow)
      {
         this.m_leaderboardName = leaderboardName;
         super(element,WinternordInnovationLeaderboardSlot,leaders,parentWindow);
         if(m_element.hasOwnProperty("mc_highlightbg"))
         {
            this.m_highlightbg = m_element.mc_highlightbg as MovieClip;
            this.m_highlightbg.visible = false;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new m_slotClass(slotElement,m_parentWindow,this.m_leaderboardName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "leaderboardSlot_";
      }
      
      private function get manager() : WinternordInnovationManager
      {
         return WinternordInnovationManager.getInstance();
      }
      
      public function finishLoading(data:Object, finished:Boolean = false) : void
      {
         var slotData:Array = null;
         if(m_element.hasOwnProperty("loader_mc"))
         {
            m_element.loader_mc.visible = false;
         }
         if(data)
         {
            slotData = data.slotData as Array;
         }
         if(slotData)
         {
            this.setData(slotData);
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

