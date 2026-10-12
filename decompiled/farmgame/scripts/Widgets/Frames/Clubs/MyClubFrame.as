package Widgets.Frames.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.DataObjects.MyClubLeaderboardObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.TabToggle;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Clubs.FarmClubWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public final class MyClubFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private static const NUM_TABS:int = 5;
      
      private static const TAB_0:int = 0;
      
      private static const TAB_1:int = 1;
      
      private static const TAB_2:int = 2;
      
      private static const TAB_3:int = 3;
      
      public static const OUR_RANK_FRAME:String = "our_rank";
      
      public static const TOP_FARMERS_FRAME:String = "top_farmers";
      
      public static const MY_FRIENDS_FRAME:String = "my_friends";
      
      public static const MY_RANK_FRAME:String = "my_rank";
      
      private static const ICON_OFFSET_X:int = 115;
      
      private static const ICON_OFFSET_Y:int = 185;
      
      private static const CLUB_LOGO_OFFSET_X:int = 10;
      
      private static const CLUB_LOGO_OFFSET_Y:int = -35;
      
      private const ICON_SIZE_CLUB_LOGO:int = 71;
      
      private var m_lastClickTime:int;
      
      private var m_icon:FarmIcon;
      
      private var m_myClubSlotFrame:FarmClubGenericSlotContainerFrame;
      
      private var m_myClubSettingsFrame:ClubSettingsFrame;
      
      private var m_inviteButton:FarmAnimatedButton;
      
      private var m_isDataLoaded:Boolean = false;
      
      private var m_tabToggleManager:ZwToggleManager;
      
      private var m_toggleHandles:Array;
      
      private var m_tabButtons:Array;
      
      private var m_tierNameTextField:ZwTextField;
      
      private var m_clubTotalTitleTextField:ZwTextField;
      
      private var m_clubTotalTextField:ZwTextField;
      
      private var m_myTierTextField:ZwTextField;
      
      private var m_myTotalTitle:ZwTextField;
      
      private var m_myTotalTextField:ZwTextField;
      
      private var m_motdField:ZwTextField;
      
      private var m_leaderMotdField:ZwFrame;
      
      private var m_leaderMotdSubmit:FarmAnimatedTextButton;
      
      private var m_leaderMotdTextEntry:ZwTextField;
      
      private var m_view:String = "our_rank";
      
      private var m_leaderboardCallbackId:int = 0;
      
      private var m_clubDataCallbackId:int = 0;
      
      private var m_clubLogo:FarmIcon;
      
      private var m_clubName:ZwTextField;
      
      private var m_clubLoading:Boolean = false;
      
      private var m_leaderboardLoading:Boolean = false;
      
      private var m_tutorialOverlay:ZwFrame;
      
      private var m_plantButton:FarmAnimatedTextButton;
      
      private var m_cropToPlant:String = null;
      
      public function MyClubFrame(element:DisplayObject)
      {
         this.m_toggleHandles = new Array(NUM_TABS);
         this.m_tabButtons = new Array(NUM_TABS);
         super(element);
         this.m_myClubSlotFrame = addWidget(new FarmClubGenericSlotContainerFrame(m_element.ourRank_mc,"MyClubSlot")) as FarmClubGenericSlotContainerFrame;
         this.m_myClubSettingsFrame = addWidget(new ClubSettingsFrame(m_element.settings_mc)) as ClubSettingsFrame;
         this.m_tabButtons[TAB_0] = addWidget(new FarmTabButton(m_element.ourRank_bt,ZLocUtils.t("FarmClub","OurRank_SubTab_Title"),function():void
         {
            onClickTab(OUR_RANK_FRAME);
         })) as FarmTabButton;
         this.m_tabButtons[TAB_1] = addWidget(new FarmTabButton(m_element.topFarmers_bt,ZLocUtils.t("FarmClub","TopFarmers_SubTab_Title"),function():void
         {
            onClickTab(TOP_FARMERS_FRAME);
         })) as FarmTabButton;
         this.m_tabButtons[TAB_2] = addWidget(new FarmTabButton(m_element.friends_bt,ZLocUtils.t("FarmClub","MyFriends_SubTab_Title"),function():void
         {
            onClickTab(MY_FRIENDS_FRAME);
         })) as FarmTabButton;
         this.m_tabButtons[TAB_3] = addWidget(new FarmTabButton(m_element.myRank_bt,ZLocUtils.t("FarmClub","MyRank_SubTab_Title"),function():void
         {
            onClickTab(MY_RANK_FRAME);
         })) as FarmTabButton;
         this.m_tabToggleManager = new ZwToggleManager();
         this.m_toggleHandles[OUR_RANK_FRAME] = this.m_tabToggleManager.addToggle(new TabToggle(this.m_tabButtons[TAB_0]),this.m_view == OUR_RANK_FRAME);
         this.m_toggleHandles[TOP_FARMERS_FRAME] = this.m_tabToggleManager.addToggle(new TabToggle(this.m_tabButtons[TAB_1]),this.m_view == TOP_FARMERS_FRAME);
         this.m_toggleHandles[MY_FRIENDS_FRAME] = this.m_tabToggleManager.addToggle(new TabToggle(this.m_tabButtons[TAB_2]),this.m_view == MY_FRIENDS_FRAME);
         this.m_toggleHandles[MY_RANK_FRAME] = this.m_tabToggleManager.addToggle(new TabToggle(this.m_tabButtons[TAB_3]),this.m_view == MY_RANK_FRAME);
         this.m_plantButton = addWidget(new FarmAnimatedTextButton(m_element.ourRank_mc.action_bt,ZLocUtils.t("FarmClub","MyClub_PlantButton"),this.onClickPlant)) as FarmAnimatedTextButton;
         this.m_inviteButton = addWidget(new FarmAnimatedButton(m_element.ourRank_mc.invite_bt,this.onClickInvite)) as FarmAnimatedButton;
         this.m_myTierTextField = addWidget(new ZwTextField(m_element.ourRank_mc.tierRank_tf,"")) as ZwTextField;
         this.m_tierNameTextField = addWidget(new ZwTextField(m_element.ourRank_mc.tierName_tf,"")) as ZwTextField;
         this.m_clubTotalTitleTextField = addWidget(new ZwTextField(m_element.ourRank_mc.clubTotalTitle_tf,ZLocUtils.t("FarmClub","MyClub_ClubTotalTitle"))) as ZwTextField;
         this.m_clubTotalTextField = addWidget(new ZwTextField(m_element.ourRank_mc.clubTotal_tf,"")) as ZwTextField;
         this.m_myTotalTitle = addWidget(new ZwTextField(m_element.ourRank_mc.myTotalTitle_tf,ZLocUtils.t("FarmClub","MyClub_MyTotalTitle"))) as ZwTextField;
         this.m_myTotalTextField = addWidget(new ZwTextField(m_element.ourRank_mc.myTotal_tf,"")) as ZwTextField;
         this.m_motdField = addWidget(new ZwTextField(m_element.ourRank_mc.message_tf),false) as ZwTextField;
         this.m_leaderMotdField = new ZwFrame(m_element.ourRank_mc.leaderMessageInput_mc);
         this.m_leaderMotdSubmit = this.m_leaderMotdField.addWidget(new FarmAnimatedTextButton(this.m_leaderMotdField.element.submit_bt,"Submit",this.onMotdSubmit)) as FarmAnimatedTextButton;
         this.m_leaderMotdTextEntry = this.m_leaderMotdField.addWidget(new ZwTextField(this.m_leaderMotdField.element.text_tf,"")) as ZwTextField;
         (this.m_leaderMotdTextEntry.element as TextField).maxChars = FarmClubConstants.MOTD_MAX_CHARS;
         addWidget(this.m_leaderMotdField,false);
         this.m_clubLogo = addWidget(new FarmIcon(m_element.ourRank_mc.guildLogo_mc)) as FarmIcon;
         this.m_clubLogo.visible = false;
         this.m_icon = addWidget(new FarmIcon(m_element.ourRank_mc.cropIcon_mc)) as FarmIcon;
         this.m_clubName = addWidget(new ZwTextField(m_element.ourRank_mc.guildName_tf,"")) as ZwTextField;
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.ON_JOIN_CLUB_EVENT,this.onJoinClub);
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.ON_REFRESH_MYFRAME,this.onRefreshFrame);
         this.refresh();
      }
      
      public function setSettingsFrameVisibility(visible:Boolean) : void
      {
         this.m_myClubSettingsFrame.visible = visible;
         if(visible)
         {
            this.m_myClubSettingsFrame.refresh();
         }
      }
      
      private function onJoinClub(event:Event) : void
      {
         this.m_myClubSettingsFrame.visible = false;
         this.refresh();
      }
      
      private function onRefreshFrame(event:Event) : void
      {
         this.refresh();
      }
      
      override public function release() : void
      {
         this.unregisterLeaderboardCallback();
         this.unregisterClubDataCallback();
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.ON_JOIN_CLUB_EVENT,this.onJoinClub);
         FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.ON_REFRESH_MYFRAME,this.onRefreshFrame);
         this.m_icon = null;
         this.m_inviteButton = null;
         this.m_myClubSlotFrame = null;
         this.m_toggleHandles = null;
         this.m_tabButtons = null;
         this.m_tabToggleManager = null;
         this.m_tierNameTextField = null;
         this.m_clubTotalTitleTextField = null;
         this.m_clubTotalTextField = null;
         this.m_myTierTextField = null;
         this.m_myTotalTitle = null;
         this.m_myTotalTextField = null;
         this.m_leaderMotdSubmit = null;
         this.m_leaderMotdTextEntry = null;
         this.m_leaderMotdField = null;
         this.m_motdField = null;
         super.release();
      }
      
      public function refresh() : void
      {
         this.resetViewClubElements();
         this.m_clubLoading = true;
         this.m_leaderboardLoading = true;
         var farmClubObj:FarmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
         if(farmClubObj == null)
         {
            this.unregisterClubDataCallback();
            this.m_clubDataCallbackId = FarmClubDataManager.getInstance().registerCaller(FarmClubDataManager.FARM_CLUB_DATA,this.setClubData);
         }
         else
         {
            this.setClubData(farmClubObj);
         }
         var leaderboardDataObj:MyClubLeaderboardObject = FarmClubDataManager.getInstance().getMyClubLeaderboardObject(this.m_view) as MyClubLeaderboardObject;
         if(leaderboardDataObj == null)
         {
            this.unregisterLeaderboardCallback();
            this.m_leaderboardCallbackId = FarmClubDataManager.getInstance().registerCaller(this.m_view,this.setLeaderboardData);
         }
         else
         {
            this.setLeaderboardData(leaderboardDataObj);
         }
         if(this.m_clubLoading || this.m_leaderboardLoading)
         {
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_EVENT,FarmClubWindow.MY_CLUB_FRAME));
         }
      }
      
      private function unregisterLeaderboardCallback() : void
      {
         if(this.m_leaderboardCallbackId != FarmClubDataManager.UNREGISTERED)
         {
            FarmClubDataManager.getInstance().unregisterCaller(this.m_leaderboardCallbackId);
            this.m_leaderboardCallbackId = FarmClubDataManager.UNREGISTERED;
         }
      }
      
      private function unregisterClubDataCallback() : void
      {
         if(this.m_clubDataCallbackId != FarmClubDataManager.UNREGISTERED)
         {
            FarmClubDataManager.getInstance().unregisterCaller(this.m_clubDataCallbackId);
            this.m_clubDataCallbackId = FarmClubDataManager.UNREGISTERED;
         }
      }
      
      public function setLeaderboardData(leaderboardDataObj:MyClubLeaderboardObject) : void
      {
         this.m_leaderboardLoading = false;
         this.checkFinishLoading();
         this.unregisterLeaderboardCallback();
         if(leaderboardDataObj != null && Boolean(leaderboardDataObj.data))
         {
            this.m_myClubSlotFrame.items = leaderboardDataObj.data as Array;
         }
         else
         {
            this.m_myClubSlotFrame.items = [];
         }
      }
      
      public function setClubData(clubDataObj:FarmClubDataObject) : void
      {
         var tier:int = 0;
         var item:FarmItem = null;
         var currentMessage:String = null;
         this.m_clubLoading = false;
         this.checkFinishLoading();
         this.unregisterClubDataCallback();
         if(clubDataObj != null)
         {
            if(clubDataObj.clubRank)
            {
               this.setTextField(this.m_clubTotalTextField,clubDataObj.clubRank["value"]);
            }
            if(clubDataObj.myRank)
            {
               this.setTextField(this.m_myTotalTextField,clubDataObj.myRank["value"]);
            }
            if(clubDataObj.farmClub)
            {
               tier = clubDataObj.farmClub.currentTier;
               if(!FarmClubUtility.isDeadDay())
               {
                  this.setTextField(this.m_myTierTextField,ZLocUtils.t("FarmClub","MyClub_StageText",{"value":String(tier)}));
               }
               else
               {
                  this.setTextField(this.m_myTierTextField,ZLocUtils.t("FarmClub","NoCompetition_Line1"));
               }
               item = FarmClubUtility.getFarmItemFromTier(tier);
               if(item)
               {
                  if(!FarmClubUtility.isDeadDay())
                  {
                     this.m_tierNameTextField.text = item.friendlyTitle;
                  }
                  else
                  {
                     this.m_tierNameTextField.text = ZLocUtils.t("FarmClub","NoCompetition_Line2");
                  }
                  this.m_cropToPlant = item.name;
                  this.m_icon.loadIcon(item.icon);
                  this.m_icon.visible = true;
                  this.m_icon.x = ICON_OFFSET_X;
                  this.m_icon.y = ICON_OFFSET_Y;
                  this.m_clubLogo.loadIcon(FarmClubUtility.getLogoPathFromId(clubDataObj.farmClub.clubLogoId));
                  this.m_clubLogo.visible = true;
                  this.m_clubLogo.setIconSize(this.ICON_SIZE_CLUB_LOGO,this.ICON_SIZE_CLUB_LOGO);
                  this.m_clubLogo.x = CLUB_LOGO_OFFSET_X;
                  this.m_clubLogo.y = CLUB_LOGO_OFFSET_Y;
                  this.m_clubName.text = clubDataObj.farmClub.clubName;
               }
               currentMessage = clubDataObj.farmClub.message;
               if(clubDataObj.farmClub.getLeader() == String(Global.player.uid))
               {
                  this.m_leaderMotdTextEntry.text = currentMessage;
                  this.m_leaderMotdField.visible = true;
               }
               else
               {
                  this.m_motdField.text = currentMessage;
                  this.m_motdField.visible = true;
               }
            }
         }
      }
      
      private function checkFinishLoading() : void
      {
         if(!this.m_clubLoading && !this.m_leaderboardLoading)
         {
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_COMPLETE_EVENT,FarmClubWindow.MY_CLUB_FRAME));
            if(this.m_view == OUR_RANK_FRAME && !Global.player.getSeenFlag(FarmClubWindow.OUR_RANK_TAB_SEEN))
            {
               FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.HIDE_X_BUTTON));
               this.m_tutorialOverlay = addWidget(new ZwFrame(m_element.tutorialMyClub_mc)) as ZwFrame;
               this.m_tutorialOverlay.addWidget(new FarmAnimatedButton(m_element.tutorialMyClub_mc.okay_bt,function():void
               {
                  m_tutorialOverlay.visible = false;
                  FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.SHOW_X_BUTTON));
               }));
               Global.player.setSeenFlag(FarmClubWindow.OUR_RANK_TAB_SEEN);
            }
         }
      }
      
      private function resetViewClubElements() : void
      {
         this.m_icon.visible = false;
         this.m_clubLogo.visible = false;
         this.m_leaderMotdField.visible = false;
         this.m_clubName.text = "";
         this.m_motdField.text = "";
         this.m_myTierTextField.text = "";
         this.m_myTotalTextField.text = "0";
         this.m_clubTotalTextField.text = "0";
      }
      
      private function setTextField(tf:ZwTextField, data:String) : void
      {
         if(data != null)
         {
            tf.text = data;
         }
         else
         {
            tf.text = "0";
         }
      }
      
      private function onClickTab(frame:String) : void
      {
         var view:String = null;
         var data:Object = null;
         var _loc4_:String = frame;
         switch(0)
         {
         }
         view = frame;
         if(this.m_view != view)
         {
            data = new Object();
            data.screen = view;
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.TAB_CHANGED_EVENT,data));
            this.m_view = view;
            this.m_isDataLoaded = false;
            this.refresh();
         }
      }
      
      private function onClickInvite(event:MouseEvent) : void
      {
         FarmClubUtility.showMFS();
      }
      
      private function onClickPlant(event:MouseEvent) : void
      {
         if(this.m_cropToPlant)
         {
            FarmClubUtility.dispatcher.dispatchEvent(new Event(FarmClubConstants.CLOSE_FARM_CLUB_WINDOW));
            UI.displayMiniMarketDialog([this.m_cropToPlant],"farmclub","");
         }
      }
      
      private function onMotdSubmit(event:Event) : void
      {
         var dataObj:FarmClubDataObject;
         this.m_leaderMotdSubmit.enabled = false;
         this.m_leaderMotdSubmit.applyGrayOut = true;
         dataObj = FarmClubDataManager.getInstance().getFarmClubDataObject();
         if(dataObj != null)
         {
            dataObj.farmClub.message = this.m_leaderMotdTextEntry.text;
         }
         FarmClubUtility.sendChatMessage(this.m_leaderMotdTextEntry.text,function(result:Object):void
         {
            if(m_leaderMotdSubmit != null)
            {
               m_leaderMotdSubmit.enabled = true;
               m_leaderMotdSubmit.applyGrayOut = false;
            }
         });
      }
      
      public function get view() : String
      {
         return this.m_view;
      }
   }
}

