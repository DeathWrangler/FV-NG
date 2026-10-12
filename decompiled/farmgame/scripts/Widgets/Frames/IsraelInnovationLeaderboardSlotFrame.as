package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Managers.IsraelInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.IsraelInnovationLeaderboardSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class IsraelInnovationLeaderboardSlotFrame extends GenericSlotContainerFrame
   {
      
      private static const FEATURE_NAME:String = "IsraelInnovation";
      
      private var m_leaderboardName:String;
      
      private var m_leaderboardTF:ZwTextField;
      
      private var m_finishedTF:ZwTextField;
      
      private var m_currentLeaderboard:Object;
      
      private var m_rankTF:ZwTextField;
      
      private var m_percentileTF:ZwTextField;
      
      private var m_scoreTF:ZwTextField;
      
      private var m_leaderboardTitleTF:ZwTextField;
      
      private var m_highlightbg:MovieClip;
      
      public function IsraelInnovationLeaderboardSlotFrame(element:DisplayObject, leaders:Array, leaderboardName:String, parentWindow:FarmWindow)
      {
         this.m_leaderboardName = leaderboardName;
         super(element,IsraelInnovationLeaderboardSlot,leaders,parentWindow);
         if(m_element.hasOwnProperty("mc_highlightbg"))
         {
            this.m_highlightbg = m_element.mc_highlightbg as MovieClip;
            this.m_highlightbg.visible = false;
         }
         if(m_element.rank_tf)
         {
            this.m_rankTF = new ZwTextField(m_element.rank_tf,"Rank");
            addWidget(this.m_rankTF,false);
         }
         if(m_element.score_tf)
         {
            this.m_scoreTF = new ZwTextField(m_element.score_tf,"Score");
            addWidget(this.m_scoreTF,false);
         }
         this.m_currentLeaderboard = IsraelInnovationManager.getInstance(FEATURE_NAME).getCurrentLeaderboard();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new m_slotClass(slotElement,m_parentWindow,this.m_leaderboardName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "leaderboardSlot_";
      }
      
      public function finishLoading(data:Object, finished:Boolean = false, winner:Boolean = false) : void
      {
         var slotData:Array = null;
         var rank:Number = NaN;
         var genericLeaderboardZLocFailoverPrefix:String = null;
         if(m_element.hasOwnProperty("loader_mc"))
         {
            m_element.loader_mc.visible = false;
         }
         if(data)
         {
            slotData = data.slotData as Array;
            for each(data in slotData)
            {
            }
            if(slotData)
            {
               this.setData(slotData);
            }
            if(this.m_rankTF)
            {
               this.m_rankTF.text = "Rank";
               this.m_rankTF.visible = true;
            }
            if(this.m_scoreTF)
            {
               this.m_scoreTF.text = "Score";
               this.m_scoreTF.visible = true;
            }
            if(finished)
            {
               genericLeaderboardZLocFailoverPrefix = "GenericLeaderboard";
               if(this.m_leaderboardTF)
               {
                  this.m_leaderboardTF.text = ZLocUtils.getZLocString("Dialogs",this.m_leaderboardName,genericLeaderboardZLocFailoverPrefix,"Title_Finished");
                  this.m_leaderboardTF.visible = true;
               }
               if(Boolean(this.m_finishedTF) && winner)
               {
                  this.m_finishedTF.text = ZLocUtils.getZLocString("Dialogs",this.m_leaderboardName,genericLeaderboardZLocFailoverPrefix,"FinishedDescription");
                  this.m_finishedTF.visible = true;
               }
            }
            if(Boolean(this.m_scoreTF) && data.hasOwnProperty("score_tf"))
            {
               this.m_scoreTF.text = "Score";
               this.m_scoreTF.visible = true;
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

