package Widgets.Frames
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.GenericLeaderboardSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class GenericLeaderboardSlotFrame extends GenericSlotContainerFrame
   {
      
      private static const ZLOC_PREFIX:String = "generic_leaderboard_slotframe";
      
      private var m_leaderboardName:String;
      
      private var m_leaderboardTF:ZwTextField;
      
      private var m_finishedTF:ZwTextField;
      
      private var m_rankTF:ZwTextField;
      
      private var m_percentileTF:ZwTextField;
      
      public function GenericLeaderboardSlotFrame(element:DisplayObject, leaders:Array, leaderboardName:String, parentWindow:FarmWindow)
      {
         var weeklyReward:MovieClip = null;
         this.m_leaderboardName = leaderboardName;
         super(element,GenericLeaderboardSlot,leaders,parentWindow);
         if(m_element.score_tf)
         {
            this.m_leaderboardTF = new ZwTextField(m_element.score_tf,ZLocUtils.t_pk("Dialogs",this.m_leaderboardName + "LeaderboardTitle"));
            addWidget(this.m_leaderboardTF);
         }
         if(m_element.WeeklyReward_mc is MovieClip)
         {
            weeklyReward = m_element.WeeklyReward_mc;
            weeklyReward.visible = true;
         }
         if(m_element.leaderboard_tf)
         {
            this.m_leaderboardTF = new ZwTextField(m_element.leaderboard_tf,ZLocUtils.t_pk("Dialogs",this.m_leaderboardName + "LeaderboardTitle"));
            addWidget(this.m_leaderboardTF);
         }
         if(m_element.finished_tf)
         {
            this.m_finishedTF = new ZwTextField(m_element.finished_tf,"");
            addWidget(this.m_finishedTF,false);
         }
         if(m_element.rank_tf)
         {
            this.m_rankTF = new ZwTextField(m_element.rank_tf,"");
            addWidget(this.m_rankTF,false);
         }
         if(m_element.percentage_tf)
         {
            this.m_percentileTF = new ZwTextField(m_element.percentage_tf,"");
            addWidget(this.m_percentileTF,false);
         }
         clearSlots();
         this.showLoading();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new m_slotClass(slotElement,m_parentWindow,this.m_leaderboardName);
      }
      
      private function showLoading() : void
      {
         var loadingScreen:MovieClip = null;
         if(m_element.hasOwnProperty("loader_mc"))
         {
            loadingScreen = m_element.loader_mc as MovieClip;
            loadingScreen.visible = true;
            loadingScreen.play();
         }
      }
      
      public function finishLoading(data:Object, finished:Boolean = false, winner:Boolean = false) : void
      {
         var slotData:Array = null;
         var genericLeaderboardZLocFailoverPrefix:String = null;
         if(m_element.hasOwnProperty("loader_mc"))
         {
            m_element.loader_mc.visible = false;
         }
         if(data)
         {
            slotData = data.slotData as Array;
            if(slotData)
            {
               this.setData(slotData);
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
            if(Boolean(this.m_rankTF) && Boolean(data.hasOwnProperty("rank")) && data.rank > 0)
            {
               this.m_rankTF.text = ZLocUtils.t("Dialogs",ZLOC_PREFIX + "_rank",{"rank":FarmGameUtil.convertPositionToRankString(data.rank)});
               this.m_rankTF.visible = true;
            }
            if(Boolean(this.m_percentileTF) && Boolean(data.hasOwnProperty("percentile")) && data.percentile > 0)
            {
               this.m_percentileTF.text = ZLocUtils.t("Dialogs",ZLOC_PREFIX + "_percentile",{"percentile":data.percentile});
               this.m_percentileTF.visible = true;
            }
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return "leaderboardSlot_";
      }
   }
}

