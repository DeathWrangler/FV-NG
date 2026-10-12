package Widgets.Windows.Leaderboard
{
   import Classes.Constants.Experiments;
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardConfigSettings;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Widgets.Buttons.Leaderboard.LeaderboardTabButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Leaderboard.LeaderboardFrame;
   import Widgets.Frames.Leaderboard.LeaderboardHistorySlotContainerFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class LeaderboardWindow extends FarmWindow
   {
      
      public static const DEFAULT_TAB:String = "";
      
      public static const HISTORY_FRAME:String = "history";
      
      public static const NUM_TABS:int = 4;
      
      public static const HISTORY_TAB_ICON_URL:String = "assets/hud/Action_Menu/FV_Main_Action_Leader.png";
      
      private var m_currentTab:String;
      
      private var m_closeCallback:Function;
      
      private var m_loadingWidget:ZwWidget;
      
      private var m_leaderboardHistoryFrame:LeaderboardHistorySlotContainerFrame;
      
      private var m_tabToggleManager:ZwToggleManager;
      
      private var m_leaderboardToggleHandles:Array;
      
      private var m_leaderBoardFrames:Array;
      
      private var m_leaderboardTabButtons:Array;
      
      private var m_timer:Timer;
      
      private var m_firstRefresh:Boolean = true;
      
      private var m_leaderboardToShow:String = null;
      
      public function LeaderboardWindow(leaderboardName:String = "", closeCallback:Function = null)
      {
         var asset:String = null;
         this.m_leaderboardToggleHandles = new Array(NUM_TABS);
         this.m_leaderBoardFrames = new Array(NUM_TABS);
         this.m_leaderboardTabButtons = new Array(NUM_TABS);
         var in6thBdayExp:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_6TH_BDAY) == 2;
         var inLeaderboardv3Experiment:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LEADERBOARD_V3) == 1;
         if(in6thBdayExp)
         {
            asset = "assets/dialogs/Farmville6thBirthday/FV_Leaderboard3_FV6thBD.swf";
         }
         else if(inLeaderboardv3Experiment)
         {
            asset = "assets/dialogs/FV_Leaderboard3.swf";
         }
         else
         {
            asset = "assets/dialogs/FV_Leaderboard2.swf";
         }
         super(asset);
         this.m_currentTab = leaderboardName;
         this.m_closeCallback = closeCallback;
      }
      
      override public function close() : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         super.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_closeButton.enabled)
         {
            super.onClose(event);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Leaderboard","LeaderboardWindow_Title")));
         this.m_loadingWidget = addWidget(new ZwWidget(m_window.loading_mc),false) as ZwWidget;
         this.m_leaderboardHistoryFrame = addWidget(new LeaderboardHistorySlotContainerFrame(m_window.history_mc)) as LeaderboardHistorySlotContainerFrame;
         this.refresh();
      }
      
      override protected function release() : void
      {
         var tab:Object = null;
         var leaderboard:Object = null;
         this.m_closeCallback = null;
         this.m_leaderboardHistoryFrame = null;
         for each(tab in this.m_leaderboardTabButtons)
         {
            tab = null;
         }
         this.m_leaderboardTabButtons = null;
         for each(leaderboard in this.m_leaderBoardFrames)
         {
            leaderboard = null;
         }
         this.m_leaderBoardFrames = null;
         this.m_loadingWidget = null;
         if(this.m_tabToggleManager != null)
         {
            this.m_tabToggleManager.release();
            this.m_tabToggleManager = null;
         }
         this.stopTimer();
         this.m_timer = null;
         super.release();
      }
      
      public function refresh() : void
      {
         var activeLeaderboards:Array = null;
         var leaderboard:Leaderboard = null;
         var i:int = 0;
         var leaderboardFrame:LeaderboardFrame = null;
         var maxLeaderboards:int = 0;
         var historyButton:LeaderboardTabButton = null;
         var leaderBoardTab:LeaderboardTabButton = null;
         if(LeaderboardManager.initialized)
         {
            this.hideLoadingWidget();
            activeLeaderboards = Global.leaderboardConfigSettings.getActiveLeaderboards(LeaderboardConfigSettings.SINGLE_TASK);
            i = 0;
            if(this.m_firstRefresh)
            {
               this.m_firstRefresh = false;
               this.m_leaderboardTabButtons = [];
               this.m_tabToggleManager = new ZwToggleManager();
               maxLeaderboards = int(activeLeaderboards.length);
               i = 0;
               while(i < maxLeaderboards && Boolean(m_window["current" + (i + 1) + "_mc"]))
               {
                  leaderboard = activeLeaderboards[i];
                  leaderBoardTab = new LeaderboardTabButton(m_window["tab" + i + "_mc"],ZLocUtils.t("Leaderboard","LeaderboardWindow_CurrentTab" + (i + 1)),leaderboard.iconUrl);
                  this.m_leaderboardTabButtons.push(addWidget(leaderBoardTab));
                  leaderboardFrame = addWidget(new LeaderboardFrame(m_window["current" + (i + 1) + "_mc"])) as LeaderboardFrame;
                  leaderboardFrame.leaderboard = leaderboard;
                  this.m_leaderBoardFrames[leaderboard.name] = leaderboardFrame;
                  if(this.m_currentTab == "" && i == 0)
                  {
                     this.m_currentTab = leaderboard.name;
                  }
                  this.m_leaderboardToggleHandles[leaderboard.name] = this.m_tabToggleManager.addToggle(new ZwVisibilityToggle(leaderBoardTab,leaderboardFrame,this.generateLeaderboardTabButtonCallback(leaderboard.name)),this.m_currentTab == leaderboard.name);
                  LeaderboardManager.markAsSeen(leaderboard.name);
                  i++;
               }
               historyButton = addWidget(new LeaderboardTabButton(m_window["tab" + i + "_mc"],ZLocUtils.t("Leaderboard","LeaderboardWindow_HistoryTab"),HISTORY_TAB_ICON_URL)) as LeaderboardTabButton;
               this.m_leaderboardToggleHandles[HISTORY_FRAME] = this.m_tabToggleManager.addToggle(new ZwVisibilityToggle(historyButton,this.m_leaderboardHistoryFrame,this.onHistoryTabButtonClick),maxLeaderboards == 0 || this.m_currentTab == HISTORY_FRAME);
            }
            if(this.m_leaderboardToShow)
            {
               this.m_currentTab = this.m_leaderboardToShow;
               this.m_leaderboardToShow = null;
            }
            if(this.m_currentTab == HISTORY_FRAME || this.m_leaderBoardFrames.length == 0)
            {
               for each(leaderboardFrame in this.m_leaderBoardFrames)
               {
                  leaderboardFrame.visible = false;
               }
               this.m_leaderboardHistoryFrame.items = Global.leaderboardConfigSettings.getHistoricalLeaderboards(LeaderboardConfigSettings.SINGLE_TASK);
               FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"impressions","history");
            }
            else
            {
               for each(leaderboardFrame in this.m_leaderBoardFrames)
               {
                  if(Boolean(leaderboardFrame.leaderboard) && leaderboardFrame.leaderboard.name == this.m_currentTab)
                  {
                     leaderboardFrame.visible = true;
                     FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"impressions","leaderboard",this.m_currentTab);
                  }
                  else
                  {
                     leaderboardFrame.visible = false;
                  }
               }
            }
         }
         else
         {
            this.showLoadingWidget();
            this.startTimer();
         }
      }
      
      private function showLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(this.m_loadingWidget)
         {
            this.m_loadingWidget.visible = true;
            element = this.m_loadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.gotoAndPlay(1);
               }
            }
         }
      }
      
      private function hideLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(this.m_loadingWidget)
         {
            this.m_loadingWidget.visible = false;
            element = this.m_loadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.stop();
               }
            }
         }
      }
      
      private function startTimer() : void
      {
         if(!this.m_timer)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         }
         this.m_timer.start();
         this.onTimer();
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.stop();
         }
      }
      
      private function onTimer(event:TimerEvent = null) : void
      {
         if(LeaderboardManager.initialized)
         {
            this.stopTimer();
            this.refresh();
         }
      }
      
      private function generateLeaderboardTabButtonCallback(leaderboardName:String) : Function
      {
         return function():void
         {
            if(m_currentTab != leaderboardName)
            {
               m_currentTab = leaderboardName;
               refresh();
            }
         };
      }
      
      private function onHistoryTabButtonClick() : void
      {
         if(this.m_currentTab != HISTORY_FRAME)
         {
            this.m_currentTab = HISTORY_FRAME;
            this.refresh();
            FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","history_tab");
         }
      }
      
      public function showTab(leaderboardName:String) : void
      {
         this.m_tabToggleManager.setToggle(this.getMapping(leaderboardName));
      }
      
      public function get leaderboardToShow() : String
      {
         return this.m_leaderboardToShow;
      }
      
      public function set leaderboardToShow(boardToShow:String) : void
      {
         this.m_leaderboardToShow = boardToShow;
      }
      
      private function getMapping(leaderboardName:String) : uint
      {
         return this.m_leaderboardToggleHandles[leaderboardName];
      }
   }
}

