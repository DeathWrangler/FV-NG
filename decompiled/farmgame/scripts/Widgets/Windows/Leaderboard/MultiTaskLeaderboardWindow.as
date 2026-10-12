package Widgets.Windows.Leaderboard
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardConfigSettings;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Leaderboard.MultiTaskLeaderboardProgressMeterFrame;
   import Widgets.Frames.Leaderboard.MultiTaskLeaderboardRewardSlotContainerFrame;
   import Widgets.Frames.Leaderboard.MultiTaskLeaderboardSlotContainerFrame;
   import Widgets.Frames.Leaderboard.MultiTaskLeaderboardTaskSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Leaderboard.LeaderboardSlotPlayerData;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class MultiTaskLeaderboardWindow extends FarmWindow
   {
      
      public static const ASSET_URL:String = "assets/dialogs/FV_FarmDerby2013.swf";
      
      public static const DEFAULT_TAB:String = "task";
      
      public static const PRIZE_TAB:String = "prize";
      
      public static const RANK_TAB:String = "rank";
      
      private var m_currentTab:String;
      
      private var m_closeCallback:Function;
      
      private var m_leaderboard:Leaderboard;
      
      private var m_background:FarmIcon;
      
      private var m_loadingWidget:ZwWidget;
      
      private var m_loadingTimer:Timer;
      
      private var m_timer:Timer;
      
      private var m_titleTextField:FarmTextField;
      
      private var m_descriptionTextField:FarmTextField;
      
      private var m_timeRemainingFrame:ZwFrame;
      
      private var m_timeRemainingValueTextField:FarmTextField;
      
      private var m_timeRemainingUnitsTextField:FarmTextField;
      
      private var m_tabFrame:ZwFrame;
      
      private var m_tabBoxWidget:ZwWidget;
      
      private var m_tabToggleManager:ZwToggleManager;
      
      private var m_tabToggleDictionary:Dictionary = new Dictionary();
      
      private var m_tabButtons:Array = new Array();
      
      private var m_progressRewardMeter:MultiTaskLeaderboardProgressMeterFrame;
      
      private var m_taskView:ZwFrame;
      
      private var m_taskGroup1Title:FarmTextField;
      
      private var m_taskGroup1Description:FarmTextField;
      
      private var m_taskGroup2Title:FarmTextField;
      
      private var m_taskGroup2Description:FarmTextField;
      
      private var m_taskSlots:MultiTaskLeaderboardTaskSlotContainerFrame;
      
      private var m_prizeView:ZwFrame;
      
      private var m_progressRewardSlots:MultiTaskLeaderboardRewardSlotContainerFrame;
      
      private var m_rankRewardSlots:MultiTaskLeaderboardRewardSlotContainerFrame;
      
      private var m_leaderboardView:ZwFrame;
      
      private var m_topLeaderboardSlots:MultiTaskLeaderboardSlotContainerFrame;
      
      private var m_bottomLeaderboardSlots:MultiTaskLeaderboardSlotContainerFrame;
      
      public function MultiTaskLeaderboardWindow(tab:String = "", closeCallback:Function = null)
      {
         super(ASSET_URL);
         this.m_currentTab = tab ? tab : DEFAULT_TAB;
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
         var tabFrameElement:MovieClip = null;
         var tabElementName:String = null;
         var tabItem:Object = null;
         var tabButton:FarmAnimatedTextButton = null;
         var toggle:ZwVisibilityToggle = null;
         var isSelected:Boolean = false;
         this.m_loadingWidget = addWidget(new ZwWidget(m_window.loading_mc),false) as ZwWidget;
         if(m_window.background_mc)
         {
            this.m_background = addWidget(new FarmIcon(m_window.background_mc)) as FarmIcon;
            this.m_background.setIconSize(m_window.background_mc.width,m_window.background_mc.height);
         }
         addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onTutorialButtonClick)) as FarmAnimatedButton;
         this.m_titleTextField = addWidget(new FarmTextField(m_window.title_tf,"")) as FarmTextField;
         this.m_descriptionTextField = addWidget(new FarmTextField(m_window.subHeader_mc,"")) as FarmTextField;
         this.m_timeRemainingFrame = addWidget(new ZwFrame(m_window.countdown_mc),false) as ZwFrame;
         this.m_timeRemainingValueTextField = this.m_timeRemainingFrame.addWidget(new FarmTextField(m_window.countdown_mc.value_tf,"")) as FarmTextField;
         this.m_timeRemainingUnitsTextField = this.m_timeRemainingFrame.addWidget(new FarmTextField(m_window.countdown_mc.units_tf,"")) as FarmTextField;
         this.m_progressRewardMeter = addWidget(new MultiTaskLeaderboardProgressMeterFrame(m_window.meter_mc),false) as MultiTaskLeaderboardProgressMeterFrame;
         this.m_taskView = addWidget(new ZwFrame(m_window.tasks_mc),false) as ZwFrame;
         this.m_taskGroup1Title = this.m_taskView.addWidget(new FarmTextField(m_window.tasks_mc.name_0_tf,"")) as FarmTextField;
         this.m_taskGroup1Description = this.m_taskView.addWidget(new FarmTextField(m_window.tasks_mc.description_0_tf,"")) as FarmTextField;
         this.m_taskGroup2Title = this.m_taskView.addWidget(new FarmTextField(m_window.tasks_mc.name_1_tf,"")) as FarmTextField;
         this.m_taskGroup2Description = this.m_taskView.addWidget(new FarmTextField(m_window.tasks_mc.description_1_tf,"")) as FarmTextField;
         this.m_taskSlots = this.m_taskView.addWidget(new MultiTaskLeaderboardTaskSlotContainerFrame(m_window.tasks_mc.slots_mc)) as MultiTaskLeaderboardTaskSlotContainerFrame;
         this.m_prizeView = addWidget(new ZwFrame(m_window.prizes_mc),false) as ZwFrame;
         this.m_progressRewardSlots = this.m_prizeView.addWidget(new MultiTaskLeaderboardRewardSlotContainerFrame(m_window.prizes_mc.progress_slots_mc,LeaderboardManager.PROGRESS_REWARD_TYPE)) as MultiTaskLeaderboardRewardSlotContainerFrame;
         this.m_rankRewardSlots = this.m_prizeView.addWidget(new MultiTaskLeaderboardRewardSlotContainerFrame(m_window.prizes_mc.rank_slots_mc,LeaderboardManager.RANK_REWARD_TYPE)) as MultiTaskLeaderboardRewardSlotContainerFrame;
         this.m_leaderboardView = addWidget(new ZwFrame(m_window.rank_mc),false) as ZwFrame;
         this.m_leaderboardView.addWidget(new FarmTextField(m_window.rank_mc.name_tf,"TOP FARMERS"));
         this.m_topLeaderboardSlots = this.m_leaderboardView.addWidget(new MultiTaskLeaderboardSlotContainerFrame(m_window.rank_mc.top_slots_mc)) as MultiTaskLeaderboardSlotContainerFrame;
         this.m_bottomLeaderboardSlots = this.m_leaderboardView.addWidget(new MultiTaskLeaderboardSlotContainerFrame(m_window.rank_mc.bottom_slots_mc)) as MultiTaskLeaderboardSlotContainerFrame;
         this.m_tabButtons = [];
         this.m_tabToggleManager = new ZwToggleManager();
         this.m_tabFrame = addWidget(new ZwFrame(m_window.tabs_mc),false) as ZwFrame;
         this.m_tabBoxWidget = addWidget(new ZwWidget(m_window.tab_box_mc),false) as ZwWidget;
         var tabItems:Array = [{
            "key":DEFAULT_TAB,
            "view":this.m_taskView
         },{
            "key":PRIZE_TAB,
            "view":this.m_prizeView
         },{
            "key":RANK_TAB,
            "view":this.m_leaderboardView
         }];
         for(var i:int = 0; i < tabItems.length; i++)
         {
            tabFrameElement = this.m_tabFrame.element as MovieClip;
            tabElementName = "tab_" + i + "_mc";
            if(tabFrameElement.hasOwnProperty(tabElementName))
            {
               tabItem = tabItems[i];
               tabButton = new FarmAnimatedTextButton(tabFrameElement[tabElementName],ZLocUtils.t("Leaderboard","MultiTaskLeaderboardWindow_Tab_" + tabItem["key"]));
               this.m_tabButtons.push(this.m_tabFrame.addWidget(tabButton));
               toggle = new ZwVisibilityToggle(tabButton,tabItem["view"],this.onTabSelected);
               isSelected = this.m_currentTab == tabItem["key"];
               this.m_tabToggleManager.addToggle(toggle,isSelected);
               this.m_tabToggleDictionary[toggle] = tabItem["key"];
            }
         }
         this.refresh();
      }
      
      override protected function release() : void
      {
         var tab:Object = null;
         this.m_closeCallback = null;
         this.m_leaderboard = null;
         this.m_loadingWidget = null;
         this.m_background = null;
         this.m_tabFrame = null;
         this.m_tabBoxWidget = null;
         for each(tab in this.m_tabButtons)
         {
            tab = null;
         }
         this.m_tabButtons = null;
         if(this.m_tabToggleManager != null)
         {
            this.m_tabToggleManager.release();
            this.m_tabToggleManager = null;
         }
         this.stopLoadingTimer();
         this.m_loadingTimer = null;
         this.stopTimer();
         this.m_timer = null;
         this.m_timeRemainingFrame = null;
         this.m_timeRemainingUnitsTextField = null;
         this.m_timeRemainingValueTextField = null;
         this.m_progressRewardMeter = null;
         this.m_taskView = null;
         this.m_taskGroup1Title = null;
         this.m_taskGroup1Description = null;
         this.m_taskGroup2Title = null;
         this.m_taskGroup2Description = null;
         this.m_taskSlots = null;
         this.m_prizeView = null;
         this.m_progressRewardSlots = null;
         this.m_rankRewardSlots = null;
         this.m_leaderboardView = null;
         this.m_topLeaderboardSlots = null;
         this.m_bottomLeaderboardSlots = null;
         super.release();
      }
      
      public function get leaderboard() : Leaderboard
      {
         return this.m_leaderboard;
      }
      
      public function refresh() : void
      {
         var activeLeaderboards:Array = null;
         var threshold:int = 0;
         var userState:LeaderboardState = null;
         var userScore:int = 0;
         var nextProgressReward:Object = null;
         var progressRewards:Array = null;
         var progressReward:Object = null;
         var leaderboardSlotItems:Array = null;
         var backgroundURL:String = null;
         if(LeaderboardManager.initialized)
         {
            this.hideLoadingWidget();
            activeLeaderboards = Global.leaderboardConfigSettings.getActiveLeaderboards(LeaderboardConfigSettings.MULTI_TASK);
            if(Boolean(activeLeaderboards) && activeLeaderboards.length > 0)
            {
               this.m_leaderboard = activeLeaderboards[0];
               FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"impressions","multitask_window",this.m_leaderboard.name);
               if(this.m_background)
               {
                  backgroundURL = this.m_leaderboard.getAssetUrl(Leaderboard.ASSET_DIALOG_BACKGROUND);
                  if(backgroundURL)
                  {
                     this.m_background.loadIcon(backgroundURL);
                  }
               }
               this.m_titleTextField.text = this.m_leaderboard.nameText;
               this.m_tabFrame.visible = true;
               this.m_tabBoxWidget.visible = true;
               this.m_progressRewardSlots.items = this.m_leaderboard.progressRewards;
               this.m_rankRewardSlots.items = this.m_leaderboard.rankRewards;
               userState = Global.player.getLeaderboardState(this.m_leaderboard.name);
               userScore = userState ? userState.score : 0;
               progressRewards = this.m_leaderboard.progressRewards;
               for each(progressReward in progressRewards)
               {
                  threshold = int(progressReward["threshold"]);
                  if(userScore < threshold)
                  {
                     nextProgressReward = progressReward;
                  }
               }
               if(nextProgressReward)
               {
                  this.m_descriptionTextField.text = ZLocUtils.t("Leaderboard","MultiTaskLeaderboardWindow_ProgressReward_Message");
                  this.m_progressRewardMeter.populateReward(nextProgressReward,userScore);
               }
               else
               {
                  this.m_descriptionTextField.text = ZLocUtils.t("Leaderboard","MultiTaskLeaderboardWindow_RankReward_Message");
                  this.m_progressRewardMeter.populatePlayer(Global.player.picture,Global.player.firstName,userScore);
               }
               this.m_progressRewardMeter.visible = true;
               leaderboardSlotItems = this.getLeaderboardSlotItems();
               this.m_topLeaderboardSlots.items = leaderboardSlotItems.slice(0,3);
               if(leaderboardSlotItems.length > 3)
               {
                  this.m_bottomLeaderboardSlots.items = leaderboardSlotItems.slice(3);
                  this.m_bottomLeaderboardSlots.visible = true;
               }
               else
               {
                  this.m_bottomLeaderboardSlots.visible = false;
               }
               this.m_taskGroup1Title.text = ZLocUtils.t("Leaderboard",this.m_leaderboard.name + "_TaskGroup1_Title");
               this.m_taskGroup1Description.text = ZLocUtils.t("Leaderboard",this.m_leaderboard.name + "_TaskGroup1_Description");
               this.m_taskGroup2Title.text = ZLocUtils.t("Leaderboard",this.m_leaderboard.name + "_TaskGroup2_Title");
               this.m_taskGroup2Description.text = ZLocUtils.t("Leaderboard",this.m_leaderboard.name + "_TaskGroup2_Description");
               this.m_taskSlots.items = this.m_leaderboard.tasks;
               if(this.leaderboard.expirationTime > 0)
               {
                  this.startTimer();
                  LeaderboardManager.markAsSeen(this.m_leaderboard.name);
               }
               else
               {
                  this.stopTimer();
               }
            }
            else
            {
               this.stopTimer();
            }
         }
         else
         {
            this.showLoadingWidget();
            this.startLoadingTimer();
            this.stopTimer();
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
      
      private function startLoadingTimer() : void
      {
         if(!this.m_loadingTimer)
         {
            this.m_loadingTimer = new Timer(1000);
            this.m_loadingTimer.addEventListener(TimerEvent.TIMER,this.onLoadingTimer);
         }
         this.m_loadingTimer.start();
         this.onLoadingTimer();
      }
      
      private function stopLoadingTimer() : void
      {
         if(this.m_loadingTimer)
         {
            this.m_loadingTimer.removeEventListener(TimerEvent.TIMER,this.onLoadingTimer);
            this.m_loadingTimer.stop();
         }
      }
      
      private function onLoadingTimer(event:TimerEvent = null) : void
      {
         if(LeaderboardManager.initialized)
         {
            this.stopLoadingTimer();
            this.refresh();
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
         if(this.m_timeRemainingFrame)
         {
            this.m_timeRemainingFrame.visible = true;
         }
         this.onTimer();
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.stop();
         }
         if(this.m_timeRemainingFrame)
         {
            this.m_timeRemainingFrame.visible = false;
         }
      }
      
      private function onTimer(event:TimerEvent = null) : void
      {
         var expirationTime:Number = NaN;
         var timeText:String = null;
         var splitTimeText:Array = null;
         if(this.m_leaderboard)
         {
            expirationTime = this.m_leaderboard.expirationTime;
            if(expirationTime > 0)
            {
               timeText = FarmGameUtil.getTimeLeftText(expirationTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
               if(timeText)
               {
                  splitTimeText = timeText.split(" ");
                  this.m_timeRemainingValueTextField.text = splitTimeText[0];
                  this.m_timeRemainingUnitsTextField.text = splitTimeText[1] + "\nLeft";
               }
               else
               {
                  this.m_timeRemainingValueTextField.text = "";
                  this.m_timeRemainingUnitsTextField.text = "";
                  this.stopTimer();
               }
            }
         }
      }
      
      private function onTabSelected() : void
      {
         var selectedToggles:Array = null;
         var selectedToggle:ZwVisibilityToggle = null;
         var tabKey:String = null;
         if(this.m_leaderboard)
         {
            selectedToggles = this.m_tabToggleManager.getSelectedToggles();
            if(Boolean(selectedToggles) && selectedToggles.length > 0)
            {
               selectedToggle = selectedToggles[0] as ZwVisibilityToggle;
               if(selectedToggle)
               {
                  tabKey = this.m_tabToggleDictionary[selectedToggle] as String;
                  FarmStatsManager.sample(100,LeaderboardManager.STAT_COUNTER,"clicks","multitask_window_tab",this.m_leaderboard.name,tabKey);
               }
            }
         }
      }
      
      private function onTutorialButtonClick(event:Event) : void
      {
         LeaderboardManager.displayMultiTaskLeaderboardTutorial();
      }
      
      private function getLeaderboardSlotItems() : Array
      {
         var i:int = 0;
         var userState:LeaderboardState = null;
         var userScore:int = 0;
         var userData:LeaderboardSlotPlayerData = null;
         var leaderboardFriendList:Array = null;
         var injectedUser:Boolean = false;
         var leaderboardFriendListLength:int = 0;
         var resultLength:int = 0;
         var friendData:Object = null;
         var playerData:LeaderboardSlotPlayerData = null;
         var result:Array = new Array();
         if(this.m_leaderboard)
         {
            userState = Global.player.getLeaderboardState(this.m_leaderboard.name);
            userScore = userState ? userState.score : 0;
            userData = new LeaderboardSlotPlayerData(Global.player.uid,userScore);
            leaderboardFriendList = LeaderboardManager.getFriendList(this.m_leaderboard.name);
            if(leaderboardFriendList)
            {
               injectedUser = false;
               leaderboardFriendListLength = int(leaderboardFriendList.length);
               for(i = 0; i < leaderboardFriendListLength; i++)
               {
                  friendData = new LeaderboardSlotPlayerData(Number(leaderboardFriendList[i]["uid"]),int(leaderboardFriendList[i]["value"]));
                  if(!injectedUser && userScore >= friendData.score)
                  {
                     result.push(userData);
                     injectedUser = true;
                  }
                  result.push(friendData);
               }
               if(!injectedUser)
               {
                  result.push(userData);
               }
               resultLength = int(result.length);
               for(i = 0; i < resultLength; i++)
               {
                  playerData = result[i] as LeaderboardSlotPlayerData;
                  if(playerData)
                  {
                     playerData.rank = i + 1;
                  }
               }
            }
            else
            {
               userData.rank = 1;
               result.push(userData);
            }
         }
         return result;
      }
   }
}

