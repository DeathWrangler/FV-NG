package Widgets.Windows.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.util.ZLocUtils;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Managers.ToasterManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Clubs.BrowseClubFrame;
   import Widgets.Frames.Clubs.MyClubFrame;
   import Widgets.Frames.Clubs.Top50ClubFrame;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FleaMarket.FleaMarketToasterWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FarmClubWindow extends FarmWindow
   {
      
      public static const BROWSE_CLUB_FRAME:String = "browse_club";
      
      public static const MY_CLUB_FRAME:String = "my_club";
      
      public static const TOP_50_FRAME:String = "top_50";
      
      public static const BROWSE_TAB_SEEN:String = "browseTabSeenFlag";
      
      public static const OUR_RANK_TAB_SEEN:String = "ourRankTabSeenFlag";
      
      public static const INTRO_SEEN:String = "introSeenFlag";
      
      public static const NUM_TABS:int = 3;
      
      public static const TAB_0:int = 0;
      
      public static const TAB_1:int = 1;
      
      public static const TAB_2:int = 2;
      
      public static const SETTINGS_BUTTON_X_OFFSET:int = 70;
      
      public static const SETTINGS_BUTTON_Y_OFFSET:int = 63;
      
      public var m_frame:String = "browse_club";
      
      private var m_closeCallback:Function;
      
      private var m_loadingWidget:ZwWidget;
      
      private var m_browseClubsFrame:BrowseClubFrame;
      
      private var m_myClubFrame:MyClubFrame;
      
      private var m_top50ClubFrame:Top50ClubFrame;
      
      private var m_tabToggleManager:ZwToggleManager;
      
      private var m_toggleHandles:Array = new Array(NUM_TABS);
      
      private var m_mainTabButtons:Array = new Array(NUM_TABS);
      
      private var m_settingsButton:FarmAnimatedButton;
      
      private var m_firstRefresh:Boolean = true;
      
      private var m_frameToShow:String = null;
      
      private var m_isSettingsVisible:Boolean = false;
      
      private var m_intro:ZwFrame;
      
      private var m_wit:ZwFrame;
      
      private var m_witTextField:ZwTextField;
      
      private var m_isTutorialShowing:Boolean = false;
      
      private var m_currentScreen:String;
      
      public function FarmClubWindow(frame:String = "browse_club", closeCallback:Function = null)
      {
         super("assets/dialogs/FV_guilds.swf");
         if(frame != BROWSE_CLUB_FRAME && frame != MY_CLUB_FRAME && frame != TOP_50_FRAME)
         {
            frame = BROWSE_CLUB_FRAME;
         }
         this.m_frame = frame;
         this.m_closeCallback = closeCallback;
         this.m_currentScreen = frame;
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
            if(!Global.player.getSeenFlag(FarmClubConstants.FARM_CLUB_ICON_TOASTER_SEEN_FLAG))
            {
               ToasterManager.getInstance().add(new FleaMarketToasterWindow());
            }
            super.onClose(event);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         if(!Global.player.getSeenFlag(INTRO_SEEN))
         {
            this.m_intro = addWidget(new ZwFrame(m_window.tutorialIntro_mc)) as ZwFrame;
            this.m_intro.addWidget(new FarmAnimatedButton(m_window.tutorialIntro_mc.okay_bt,this.onIntroCloseButtonClicked));
            this.m_intro.addWidget(new ZwTextField(m_window.tutorialIntro_mc.description_tf,ZLocUtils.t("FarmClub","intro")));
            Global.player.setSeenFlag(INTRO_SEEN);
            this.m_isTutorialShowing = true;
         }
         else
         {
            this.initialize();
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(this.m_isTutorialShowing)
         {
            m_closeButton.visible = false;
         }
      }
      
      private function initialize() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("FarmClub","FarmClubWindow_Title")));
         this.m_loadingWidget = addWidget(new ZwWidget(m_window.loading_mc),false) as ZwWidget;
         this.m_loadingWidget.visible = false;
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.LOAD_COMPLETE_EVENT,this.hideLoadingWidget);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.LOAD_EVENT,this.showLoadingWidget);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.CREATE_CLUB_EVENT,this.onCreateClub);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.SHOW_ONBOARDING_EVENT,this.showWhatIsThis);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.SHOW_X_BUTTON,this.onShowXButton);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.HIDE_X_BUTTON,this.onHideXButton);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.CLOSE_FARM_CLUB_WINDOW,this.onClose);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.TAB_CHANGED_EVENT,this.onTabChanged);
         this.m_browseClubsFrame = addWidget(new BrowseClubFrame(m_window.browseClubs_mc,this)) as BrowseClubFrame;
         this.m_myClubFrame = addWidget(new MyClubFrame(m_window.myClub_mc)) as MyClubFrame;
         this.m_myClubFrame.setSettingsFrameVisibility(false);
         this.m_top50ClubFrame = addWidget(new Top50ClubFrame(m_window.top50_mc)) as Top50ClubFrame;
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.ON_JOIN_CLUB_EVENT,this.onJoinClub);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.ON_LEAVE_CLUB_EVENT,this.onLeaveClub);
         addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.showWhatIsThis));
         this.m_mainTabButtons[TAB_0] = addWidget(new FarmTabButton(m_window.tab0_mc,ZLocUtils.t("FarmClub","BrowseClub_Tab_Title"))) as FarmTabButton;
         this.m_mainTabButtons[TAB_1] = addWidget(new FarmTabButton(m_window.tab1_mc,ZLocUtils.t("FarmClub","MyClub_Tab_Title"))) as FarmTabButton;
         this.m_mainTabButtons[TAB_2] = addWidget(new FarmTabButton(m_window.tab2_mc,ZLocUtils.t("FarmClub","Top50_Tab_Title"))) as FarmTabButton;
         this.m_tabToggleManager = new ZwToggleManager();
         this.m_toggleHandles[BROWSE_CLUB_FRAME] = this.m_tabToggleManager.addToggle(new ZwVisibilityToggle(this.m_mainTabButtons[TAB_0],this.m_browseClubsFrame,this.onBrowseClubTabButtonClick),this.m_frame == BROWSE_CLUB_FRAME);
         this.m_toggleHandles[MY_CLUB_FRAME] = this.m_tabToggleManager.addToggle(new ZwVisibilityToggle(this.m_mainTabButtons[TAB_1],this.m_myClubFrame,this.onMyClubTabButtonClick),this.m_frame == MY_CLUB_FRAME);
         this.m_toggleHandles[TOP_50_FRAME] = this.m_tabToggleManager.addToggle(new ZwVisibilityToggle(this.m_mainTabButtons[TAB_2],this.m_top50ClubFrame,this.onTop50TabButtonClick),this.m_frame == TOP_50_FRAME);
         this.m_settingsButton = addWidget(new FarmAnimatedButton(m_window.settings_bt,this.onSettingsButtonClicked)) as FarmAnimatedButton;
         this.m_settingsButton.visible = false;
         this.m_settingsButton.x = SETTINGS_BUTTON_X_OFFSET;
         this.m_settingsButton.y = SETTINGS_BUTTON_Y_OFFSET;
         this.m_wit = addWidget(new ZwFrame(m_window.wit_mc)) as ZwFrame;
         this.m_wit.visible = false;
         this.m_wit.addWidget(new FarmAnimatedButton(m_window.wit_mc.okay_bt,function():void
         {
            m_wit.visible = false;
         }));
         this.m_witTextField = this.m_wit.addWidget(new ZwTextField(m_window.wit_mc.description_tf,ZLocUtils.t("FarmClub","wit"))) as ZwTextField;
         this.refresh();
      }
      
      override protected function release() : void
      {
         var tab:Object = null;
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.ON_JOIN_CLUB_EVENT,this.onJoinClub);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.ON_LEAVE_CLUB_EVENT,this.onLeaveClub);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.CREATE_CLUB_EVENT,this.onCreateClub);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.LOAD_EVENT,this.showLoadingWidget);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.LOAD_COMPLETE_EVENT,this.hideLoadingWidget);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.SHOW_X_BUTTON,this.onShowXButton);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.HIDE_X_BUTTON,this.onHideXButton);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.CLOSE_FARM_CLUB_WINDOW,this.onClose);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.TAB_CHANGED_EVENT,this.onTabChanged);
         this.m_closeCallback = null;
         this.m_browseClubsFrame = null;
         this.m_myClubFrame = null;
         this.m_top50ClubFrame = null;
         for each(tab in this.m_mainTabButtons)
         {
            tab = null;
         }
         this.m_mainTabButtons = null;
         this.m_loadingWidget = null;
         this.m_tabToggleManager.release();
         this.m_tabToggleManager = null;
         super.release();
      }
      
      public function onTabChanged(event:DynamicObjectEvent) : void
      {
         if(event.data.hasOwnProperty("screen"))
         {
            this.m_currentScreen = event.data["screen"];
         }
      }
      
      public function changeTabs(tabName:String) : void
      {
         this.m_frame = tabName;
         this.refresh();
      }
      
      public function onSettingsButtonClicked(event:Event) : void
      {
         this.m_isSettingsVisible = !this.m_isSettingsVisible;
         this.m_myClubFrame.setSettingsFrameVisibility(this.m_isSettingsVisible);
      }
      
      public function refresh() : void
      {
         var clubId:String = FarmClubDataManager.getInstance().clubId;
         (this.m_mainTabButtons[TAB_1] as FarmTabButton).enabled = clubId != null;
         switch(this.m_frame)
         {
            case BROWSE_CLUB_FRAME:
               this.m_currentScreen = this.m_browseClubsFrame.view;
               this.m_browseClubsFrame.visible = true;
               this.m_myClubFrame.visible = false;
               this.m_top50ClubFrame.visible = false;
               this.m_settingsButton.visible = false;
               this.m_browseClubsFrame.refresh();
               break;
            case MY_CLUB_FRAME:
               this.m_currentScreen = this.m_myClubFrame.view;
               this.m_browseClubsFrame.visible = false;
               this.m_myClubFrame.visible = true;
               this.m_top50ClubFrame.visible = false;
               this.m_settingsButton.visible = true;
               this.m_myClubFrame.refresh();
               break;
            case TOP_50_FRAME:
               this.m_currentScreen = TOP_50_FRAME;
               this.m_browseClubsFrame.visible = false;
               this.m_myClubFrame.visible = false;
               this.m_top50ClubFrame.visible = true;
               this.m_settingsButton.visible = false;
               this.m_top50ClubFrame.refresh();
         }
      }
      
      private function showLoadingWidget(event:DynamicObjectEvent) : void
      {
         var child:MovieClip = null;
         this.m_loadingWidget.visible = true;
         switch(event.data)
         {
            case BROWSE_CLUB_FRAME:
               if(this.m_browseClubsFrame)
               {
                  this.m_browseClubsFrame.visible = false;
               }
               break;
            case MY_CLUB_FRAME:
               if(this.m_myClubFrame)
               {
                  this.m_myClubFrame.visible = false;
               }
               break;
            case TOP_50_FRAME:
               if(this.m_top50ClubFrame)
               {
                  this.m_top50ClubFrame.visible = false;
               }
         }
         var element:MovieClip = this.m_loadingWidget.element as MovieClip;
         for(var i:int = 0; i < element.numChildren; i++)
         {
            child = element.getChildAt(i) as MovieClip;
            if(child)
            {
               child.gotoAndPlay(1);
            }
         }
      }
      
      private function hideLoadingWidget(event:DynamicObjectEvent) : void
      {
         var child:MovieClip = null;
         this.m_loadingWidget.visible = false;
         switch(event.data)
         {
            case BROWSE_CLUB_FRAME:
               if(Boolean(this.m_browseClubsFrame) && this.m_frame == event.data)
               {
                  this.m_browseClubsFrame.visible = true;
               }
               break;
            case MY_CLUB_FRAME:
               if(Boolean(this.m_myClubFrame) && this.m_frame == event.data)
               {
                  this.m_myClubFrame.visible = true;
               }
               break;
            case TOP_50_FRAME:
               if(Boolean(this.m_top50ClubFrame) && this.m_frame == event.data)
               {
                  this.m_top50ClubFrame.visible = true;
               }
         }
         var element:MovieClip = this.m_loadingWidget.element as MovieClip;
         for(var i:int = 0; i < element.numChildren; i++)
         {
            child = element.getChildAt(i) as MovieClip;
            if(child)
            {
               child.stop();
            }
         }
      }
      
      private function onBrowseClubTabButtonClick() : void
      {
         if(this.m_frame != BROWSE_CLUB_FRAME)
         {
            this.m_frame = BROWSE_CLUB_FRAME;
            this.refresh();
         }
      }
      
      private function onJoinClub(event:Event) : void
      {
         this.m_tabToggleManager.setToggle(this.m_toggleHandles[MY_CLUB_FRAME]);
      }
      
      private function onCreateClub(event:Event) : void
      {
         this.m_tabToggleManager.setToggle(this.m_toggleHandles[MY_CLUB_FRAME]);
         this.m_myClubFrame.setSettingsFrameVisibility(false);
      }
      
      private function onLeaveClub(event:Event) : void
      {
         this.m_tabToggleManager.setToggle(this.m_toggleHandles[BROWSE_CLUB_FRAME]);
      }
      
      private function onMyClubTabButtonClick() : void
      {
         if(this.m_frame != MY_CLUB_FRAME)
         {
            this.m_frame = MY_CLUB_FRAME;
            this.refresh();
         }
      }
      
      private function onTop50TabButtonClick() : void
      {
         if(this.m_frame != TOP_50_FRAME)
         {
            this.m_frame = TOP_50_FRAME;
            this.refresh();
         }
      }
      
      public function showTab(leaderboardName:String) : void
      {
      }
      
      public function get frameToShow() : String
      {
         return this.m_frameToShow;
      }
      
      public function set frameToShow(boardToShow:String) : void
      {
         this.m_frameToShow = boardToShow;
      }
      
      public function showWhatIsThis(event:Event) : void
      {
         this.m_wit.visible = true;
      }
      
      public function onIntroCloseButtonClicked(event:MouseEvent) : void
      {
         this.m_intro.visible = false;
         m_closeButton.visible = true;
         this.m_isTutorialShowing = false;
         this.initialize();
      }
      
      public function onShowXButton(event:Event) : void
      {
         m_closeButton.visible = true;
      }
      
      public function onHideXButton(event:Event) : void
      {
         m_closeButton.visible = false;
      }
   }
}

