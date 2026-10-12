package Widgets.Frames.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.util.ZLocUtils;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.DataObjects.BrowseClubObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Clubs.FarmClubWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public final class BrowseClubFrame extends ZwFrame
   {
      
      private static const NUM_TABS:int = 2;
      
      private static const TAB_0:int = 0;
      
      private static const TAB_1:int = 1;
      
      public static const BROWSE_FRAME:String = "browse";
      
      public static const CREATE_FRAME:String = "create";
      
      private static const ICON_SIZE:int = 100;
      
      private var m_lastClickTime:int;
      
      private var m_icon:FarmIcon;
      
      private var m_browseClubSlotFrame:FarmClubGenericSlotContainerFrame;
      
      private var m_createClubFrame:CreateClubFrame;
      
      private var m_viewClubFrame:ViewClubFrame;
      
      private var m_isDataLoaded:Boolean = false;
      
      private var m_tabToggleManager:ZwToggleManager;
      
      private var m_toggleHandles:Array;
      
      private var m_tabButtons:Array;
      
      private var m_view:String = "browse";
      
      private var m_idx:int;
      
      private var m_loading:Boolean = false;
      
      private var m_tutorialOverlay:ZwFrame;
      
      public function BrowseClubFrame(element:DisplayObject, farmClubWindow:FarmClubWindow)
      {
         this.m_toggleHandles = new Array(NUM_TABS);
         this.m_tabButtons = new Array(NUM_TABS);
         this.m_idx = FarmClubDataManager.UNREGISTERED;
         super(element);
         this.m_browseClubSlotFrame = addWidget(new FarmClubGenericSlotContainerFrame(m_element.browse_mc,"BrowseClubSlot")) as FarmClubGenericSlotContainerFrame;
         this.m_createClubFrame = addWidget(new CreateClubFrame(m_element.create_mc,farmClubWindow)) as CreateClubFrame;
         this.m_viewClubFrame = addWidget(new ViewClubFrame(m_element.viewClubs_mc)) as ViewClubFrame;
         this.m_viewClubFrame.visible = false;
         this.m_tabButtons[TAB_0] = addWidget(new FarmTabButton(m_element.browse_bt,ZLocUtils.t("FarmClub","BrowseClub_SubTab_Title"),function():void
         {
            onClickTab(BROWSE_FRAME);
         })) as FarmTabButton;
         this.m_tabButtons[TAB_1] = addWidget(new FarmTabButton(m_element.create_bt,ZLocUtils.t("FarmClub","CreateClub_SubTab_Title"),function():void
         {
            onClickTab(CREATE_FRAME);
         })) as FarmTabButton;
         this.m_tabToggleManager = new ZwToggleManager();
         this.m_toggleHandles[BROWSE_FRAME] = this.m_tabToggleManager.addToggle(new ZwVisibilityToggle(this.m_tabButtons[TAB_0],this.m_browseClubSlotFrame),this.m_view == BROWSE_FRAME);
         this.m_toggleHandles[CREATE_FRAME] = this.m_tabToggleManager.addToggle(new ZwVisibilityToggle(this.m_tabButtons[TAB_1],this.m_createClubFrame),this.m_view == CREATE_FRAME);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.ON_JOIN_CLUB_EVENT,this.onJoinClub);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.VIEW_CLUB_EVENT,this.onViewClubEvent);
         this.refresh();
      }
      
      public function onViewClubEvent(event:DynamicObjectEvent) : void
      {
         this.m_viewClubFrame.visible = true;
         GlobalEngine.assert(event.data.hasOwnProperty("id"),"Expected event to have data.id");
         GlobalEngine.assert(event.data.hasOwnProperty("clubInfo"),"Expected event to have data.clubInfo");
         this.m_viewClubFrame.clubId = event.data.id;
         this.m_viewClubFrame.clubInfo = event.data.clubInfo;
         this.m_viewClubFrame.refresh();
      }
      
      override public function release() : void
      {
         this.unregisterCallback();
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.ON_JOIN_CLUB_EVENT,this.onJoinClub);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.VIEW_CLUB_EVENT,this.onViewClubEvent);
         this.m_icon = null;
         this.m_browseClubSlotFrame = null;
         this.m_createClubFrame = null;
         this.m_tabToggleManager = null;
         this.m_toggleHandles = null;
         this.m_tabButtons = null;
         super.release();
      }
      
      private function onJoinClub(event:Event) : void
      {
         this.refresh();
      }
      
      public function refresh() : void
      {
         var browseClubs:BrowseClubObject = FarmClubDataManager.getInstance().getBrowseClubObject() as BrowseClubObject;
         if(browseClubs == null)
         {
            this.unregisterCallback();
            this.m_idx = FarmClubDataManager.getInstance().registerCaller(FarmClubDataManager.BROWSE_CLUB_DATA,this.setData);
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_EVENT,FarmClubWindow.BROWSE_CLUB_FRAME));
            this.m_loading = true;
         }
         else
         {
            this.setData(browseClubs);
         }
      }
      
      private function unregisterCallback() : void
      {
         if(this.m_idx != FarmClubDataManager.UNREGISTERED)
         {
            FarmClubDataManager.getInstance().unregisterCaller(this.m_idx);
            this.m_idx = FarmClubDataManager.UNREGISTERED;
         }
      }
      
      public function setData(browseClubs:BrowseClubObject) : void
      {
         FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_COMPLETE_EVENT,FarmClubWindow.BROWSE_CLUB_FRAME));
         this.m_loading = false;
         this.unregisterCallback();
         if(browseClubs != null && Boolean(browseClubs.data))
         {
            this.m_browseClubSlotFrame.items = browseClubs.data as Array;
         }
         else
         {
            this.m_browseClubSlotFrame.items = [];
         }
         if(this.m_view == BROWSE_FRAME && !Global.player.getSeenFlag(FarmClubWindow.BROWSE_TAB_SEEN))
         {
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.HIDE_X_BUTTON));
            this.m_tutorialOverlay = addWidget(new ZwFrame(m_element.tutorialBrowse_mc)) as ZwFrame;
            this.m_tutorialOverlay.addWidget(new FarmAnimatedButton(m_element.tutorialBrowse_mc.okay_bt,function():void
            {
               m_tutorialOverlay.visible = false;
               FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.SHOW_X_BUTTON));
            }));
            Global.player.setSeenFlag(FarmClubWindow.BROWSE_TAB_SEEN);
         }
      }
      
      private function onClickTab(frame:String) : void
      {
         var view:String = null;
         switch(frame)
         {
            case BROWSE_FRAME:
               view = "browse";
               this.m_viewClubFrame.refresh();
               this.refresh();
               break;
            case CREATE_FRAME:
               view = "create";
               this.m_viewClubFrame.refresh();
               this.m_createClubFrame.refresh();
         }
         var data:Object = new Object();
         data.screen = view;
         FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.TAB_CHANGED_EVENT,data));
      }
      
      public function get view() : String
      {
         return this.m_view;
      }
   }
}

