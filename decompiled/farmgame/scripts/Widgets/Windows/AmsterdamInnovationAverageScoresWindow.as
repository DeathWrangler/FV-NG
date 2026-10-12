package Widgets.Windows
{
   import Managers.AmsterdamInnovationManager;
   import Managers.FarmStatsManager;
   import Widgets.Core.TextFields.ZwTextField;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class AmsterdamInnovationAverageScoresWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 9;
      
      private static const FEATURE_NAME:String = "AmsterdamInnovation";
      
      private var m_featureName:String = null;
      
      private var m_mainWindow:AmsterdamInnovationMainWindow;
      
      private var m_barindex:int = 0;
      
      private var m_dayIndex:int = 0;
      
      private const DAILY_PROGRESS_BAR_FULL_WIDTH:int = 250;
      
      private const MAX_POINT:Number = 350;
      
      private var m_averagescore_tf:ZwTextField;
      
      private var m_progress_mc:MovieClip;
      
      private var m_progress_array:Array = [];
      
      private var m_expert_mc:MovieClip;
      
      private var m_professional_mc:MovieClip;
      
      private var m_champion_mc:MovieClip;
      
      private var m_expert_popup:MovieClip;
      
      private var m_professional_popup:MovieClip;
      
      private var m_champion_popup:MovieClip;
      
      private var m_featuretimer_tf:ZwTextField;
      
      private var m_highlight1_mc:MovieClip;
      
      private var m_highlight2_mc:MovieClip;
      
      private var m_highlight3_mc:MovieClip;
      
      public function AmsterdamInnovationAverageScoresWindow(featureName:String = "AmsterdamInnovation", assetUrl:String = null, mainWindow:AmsterdamInnovationMainWindow = null)
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         this.m_mainWindow = mainWindow;
         this.m_barindex = this.manager.isGAPlayer() ? 28 : 35;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var barName:String = null;
         var daycount_mc:MovieClip = null;
         super.postLoadComplete();
         this.m_dayIndex = this.getDayNumberForPlayer();
         if(m_window.hasOwnProperty("dailyavarage_tf"))
         {
            addWidget(this.m_averagescore_tf = new ZwTextField(m_window["dailyavarage_tf"],"Your Current Average: " + this.manager.getCurrentAverage().toString()));
            this.m_averagescore_tf.visible = true;
         }
         if(this.manager.isPlayerEA())
         {
            if(m_window.hasOwnProperty("dailyAverage_EA"))
            {
               this.m_progress_mc = m_window["dailyAverage_EA"] as MovieClip;
               this.m_progress_mc.visible = true;
            }
         }
         else if(m_window.hasOwnProperty("dailyAverage_GA"))
         {
            this.m_progress_mc = m_window["dailyAverage_GA"] as MovieClip;
            this.m_progress_mc.visible = true;
         }
         for(var index:int = 0; index < this.m_barindex; index++)
         {
            barName = "progressbar" + index.toString() + "_mc";
            if(this.m_progress_mc.hasOwnProperty(barName))
            {
               this.m_progress_array[index] = this.m_progress_mc[barName] as MovieClip;
               this.m_progress_array[index].visible = true;
               if(index == this.m_dayIndex)
               {
                  if(this.m_progress_array[index].hasOwnProperty("progressbarhihglight_mc"))
                  {
                     this.m_progress_array[index]["progressbarhihglight_mc"].visible = true;
                  }
                  if(this.m_progress_array[index].hasOwnProperty("dayscount_mc"))
                  {
                     daycount_mc = this.m_progress_array[index]["dayscount_mc"] as MovieClip;
                     daycount_mc.visible = true;
                     if(daycount_mc.hasOwnProperty("dayscount_tf"))
                     {
                        addWidget(new ZwTextField(daycount_mc["dayscount_tf"],(index + 1).toString()));
                     }
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("stage_highlight0_mc"))
         {
            this.m_highlight1_mc = m_window["stage_highlight0_mc"] as MovieClip;
            this.m_highlight1_mc.visible = false;
         }
         if(m_window.hasOwnProperty("stage_highlight1_mc"))
         {
            this.m_highlight2_mc = m_window["stage_highlight1_mc"] as MovieClip;
            this.m_highlight2_mc.visible = false;
         }
         if(m_window.hasOwnProperty("stage_highlight2_mc"))
         {
            this.m_highlight3_mc = m_window["stage_highlight2_mc"] as MovieClip;
            this.m_highlight3_mc.visible = false;
         }
         if(m_window.hasOwnProperty("amaturerewardpopup_mc"))
         {
            this.m_expert_popup = m_window["amaturerewardpopup_mc"] as MovieClip;
            this.m_expert_popup.visible = false;
         }
         if(m_window.hasOwnProperty("exlentrewardpopup_mc"))
         {
            this.m_professional_popup = m_window["exlentrewardpopup_mc"] as MovieClip;
            this.m_professional_popup.visible = false;
         }
         if(m_window.hasOwnProperty("proffessionalrewardpopup_mc"))
         {
            this.m_champion_popup = m_window["proffessionalrewardpopup_mc"] as MovieClip;
            this.m_champion_popup.visible = false;
         }
         if(m_window.hasOwnProperty("amaturerewardicon_small"))
         {
            this.m_expert_mc = m_window["amaturerewardicon_small"] as MovieClip;
            this.m_expert_mc.visible = true;
            this.m_expert_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onRewardsHover(0));
            this.m_expert_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onRewardsOut());
         }
         if(m_window.hasOwnProperty("exlentrewardicon_small"))
         {
            this.m_professional_mc = m_window["exlentrewardicon_small"] as MovieClip;
            this.m_professional_mc.visible = true;
            this.m_professional_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onRewardsHover(1));
            this.m_professional_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onRewardsOut());
         }
         if(m_window.hasOwnProperty("professionalrewardicon_small"))
         {
            this.m_champion_mc = m_window["professionalrewardicon_small"] as MovieClip;
            this.m_champion_mc.visible = true;
            this.m_champion_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onRewardsHover(2));
            this.m_champion_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onRewardsOut());
         }
         if(m_window.hasOwnProperty("timeremains_tf"))
         {
            this.m_featuretimer_tf = new ZwTextField(m_window["timeremains_tf"],this.manager.getFeatureEndDaysLeftText());
            this.m_featuretimer_tf.visible = true;
         }
         this.updateStateHighlights();
         this.updateCurrentdaySmallProgressBars();
         this.updateSmallProgressBars();
      }
      
      public function updateSmallProgressBars() : void
      {
         var barfill_mc:MovieClip = null;
         var dayPoints:int = 0;
         var barLength:Number = 0;
         for(var index:int = 0; index < this.m_barindex; index++)
         {
            dayPoints = this.manager.getpointsForTheDay(this.manager.isGAPlayer() ? int(index + 7) : index);
            if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
            {
               dayPoints = this.manager.VAL_THIRD_MILESTONE;
            }
            barLength = dayPoints * this.DAILY_PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
            if(this.m_progress_array[index].hasOwnProperty("bar_fill_mc"))
            {
               barfill_mc = this.m_progress_array[index]["bar_fill_mc"] as MovieClip;
               barfill_mc.visible = true;
               if(dayPoints <= 0)
               {
                  barfill_mc.width = barLength;
               }
               else
               {
                  TweenMax.to(barfill_mc,2,{"width":barLength});
               }
            }
         }
      }
      
      public function updateCurrentdaySmallProgressBars() : void
      {
         var barfill_mc:MovieClip = null;
         var dayNumber:int = this.getDayNumberForPlayer();
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
         {
            dayPoints = this.manager.VAL_THIRD_MILESTONE;
         }
         var barLength:Number = dayPoints * this.DAILY_PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(this.m_progress_array[dayNumber].hasOwnProperty("bar_fill_mc"))
         {
            barfill_mc = this.m_progress_array[dayNumber]["bar_fill_mc"] as MovieClip;
            barfill_mc.visible = true;
            if(dayPoints <= 0)
            {
               barfill_mc.width = barLength;
            }
            else
            {
               TweenMax.to(barfill_mc,2,{"width":barLength});
            }
         }
      }
      
      private function updateStateHighlights() : void
      {
         var progressTotal:int = this.manager.overAllProgressLevel();
         if(Boolean(this.m_highlight1_mc) && Boolean(this.m_highlight2_mc) && Boolean(this.m_highlight3_mc))
         {
            if(progressTotal == 0)
            {
               this.m_highlight1_mc.visible = true;
               this.m_highlight2_mc.visible = false;
               this.m_highlight3_mc.visible = false;
            }
            else if(progressTotal == 1)
            {
               this.m_highlight1_mc.visible = false;
               this.m_highlight2_mc.visible = true;
               this.m_highlight3_mc.visible = false;
            }
            else if(progressTotal == 2)
            {
               this.m_highlight1_mc.visible = false;
               this.m_highlight2_mc.visible = false;
               this.m_highlight3_mc.visible = true;
            }
         }
      }
      
      private function onRewardsHover(index:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            if(Boolean(m_expert_popup) && Boolean(m_professional_popup) && Boolean(m_champion_popup))
            {
               if(index == 0)
               {
                  m_expert_popup.visible = true;
               }
               else if(index == 1)
               {
                  m_professional_popup.visible = true;
               }
               else if(index == 2)
               {
                  m_champion_popup.visible = true;
               }
            }
         };
      }
      
      public function onRewardsOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(Boolean(m_expert_popup) && Boolean(m_professional_popup) && Boolean(m_champion_popup))
            {
               m_expert_popup.visible = false;
               m_professional_popup.visible = false;
               m_champion_popup.visible = false;
            }
         };
      }
      
      private function get manager() : AmsterdamInnovationManager
      {
         return AmsterdamInnovationManager.getInstance(FEATURE_NAME);
      }
      
      private function getDayNumberForPlayer() : int
      {
         var index:int = this.manager.isGAPlayer() ? int(this.manager.activeDayIndex - 7) : this.manager.activeDayIndex;
         return index < 0 ? 0 : index;
      }
      
      override public function close() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
         FarmStatsManager.count("AmsterdamInnovation","Main_UI","close_window");
         super.close();
      }
   }
}

