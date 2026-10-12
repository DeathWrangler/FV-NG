package Widgets.Frames.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.DataObjects.ViewFarmClubObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Clubs.FarmClubWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class ViewClubFrame extends ZwFrame
   {
      
      private static const ICON_OFFSET_X:int = 115;
      
      private static const ICON_OFFSET_Y:int = 185;
      
      private static const CLUB_LOGO_OFFSET_X:int = 10;
      
      private static const CLUB_LOGO_OFFSET_Y:int = -35;
      
      private const ICON_SIZE:int = 71;
      
      private var m_icon:FarmIcon;
      
      private var m_timeRemainingTextField:ZwTextField;
      
      private var m_taskTextField:ZwTextField;
      
      private var m_topFarmersContainerFrame:FarmClubGenericSlotContainerFrame;
      
      private var m_leaderboardCallbackId:int = 0;
      
      private var m_clubDataCallbackId:int = 0;
      
      private var m_clubId:String = null;
      
      private var m_clubInfo:Object = null;
      
      private var m_clubLogo:FarmIcon;
      
      private var m_cropIcon:FarmIcon;
      
      private var m_tierName:ZwTextField;
      
      private var m_totalHarvested:ZwTextField;
      
      private var m_tierRank:ZwTextField;
      
      private var m_clubName:ZwTextField;
      
      private var m_joinButton:FarmAnimatedTextButton;
      
      private var m_loading:Boolean = false;
      
      private var m_farmClubDataObject:FarmClubDataObject;
      
      public function ViewClubFrame(element:DisplayObject)
      {
         super(element);
         this.m_topFarmersContainerFrame = addWidget(new FarmClubGenericSlotContainerFrame(m_element as DisplayObject,"TopFarmersSlot")) as FarmClubGenericSlotContainerFrame;
         this.m_tierName = addWidget(new ZwTextField(m_element.tierName_tf)) as ZwTextField;
         this.m_totalHarvested = addWidget(new ZwTextField(m_element.clubTotal_tf)) as ZwTextField;
         this.m_tierRank = addWidget(new ZwTextField(m_element.tierRank_tf)) as ZwTextField;
         this.m_clubName = addWidget(new ZwTextField(m_element.guildName_tf,"")) as ZwTextField;
         this.m_clubLogo = addWidget(new FarmIcon(m_element.guildLogo_mc)) as FarmIcon;
         this.m_clubLogo.visible = false;
         this.m_cropIcon = addWidget(new FarmIcon(m_element.cropIcon_mc)) as FarmIcon;
         this.m_cropIcon.visible = false;
         this.m_joinButton = addWidget(new FarmAnimatedTextButton(m_element.action_bt,ZLocUtils.t("FarmClub","Join"),this.onJoinButtonClicked)) as FarmAnimatedTextButton;
         addWidget(new FarmButton(m_element.close_bt,this.onClosedButtonClicked));
         addWidget(new ZwTextField(m_element.clubTotalTitle_tf,ZLocUtils.t("FarmClub","MyClub_ClubTotalTitle")));
         this.refresh();
      }
      
      public function onClosedButtonClicked(event:MouseEvent) : void
      {
         this.visible = false;
         this.resetViewClubElements();
      }
      
      public function onJoinButtonClicked(event:MouseEvent) : void
      {
         FarmClubUtility.canJoinClub(this.m_clubId,this.canJoinClubCallback);
      }
      
      private function canJoinClubCallback(result:Boolean) : void
      {
         if(result)
         {
            this.m_joinButton.visible = false;
            FarmClubUtility.joinClub(this.m_clubId,this.onJoinClubComplete);
         }
      }
      
      public function onJoinClubComplete(result:Object) : void
      {
         var popup:GenericPopup = null;
         if(result)
         {
            if(result.hasOwnProperty("success") && result["sucess"] == false)
            {
               popup = new GenericPopup(ZLocUtils.t("FarmClub","JoinClub_private"),GenericPopup.TYPE_ACCEPTCANCEL);
               UI.displayPopup(popup,false);
            }
            else if(result.hasOwnProperty("success") && result["success"] == true)
            {
               FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.ON_JOIN_CLUB_EVENT,true));
            }
         }
      }
      
      override public function release() : void
      {
         this.unregisterClubCallback();
         this.unregisterLeaderboardCallback();
         this.m_icon = null;
         this.m_topFarmersContainerFrame = null;
         this.m_taskTextField = null;
         this.m_timeRemainingTextField = null;
         super.release();
      }
      
      public function set clubId(clubId:String) : void
      {
         this.m_clubId = clubId;
      }
      
      public function set clubInfo(clubInfo:Object) : void
      {
         this.m_clubInfo = clubInfo;
      }
      
      private function unregisterClubCallback() : void
      {
         if(this.m_clubDataCallbackId != 0)
         {
            FarmClubDataManager.getInstance().unregisterCaller(this.m_clubDataCallbackId);
            this.m_clubDataCallbackId = 0;
         }
      }
      
      private function unregisterLeaderboardCallback() : void
      {
         if(this.m_leaderboardCallbackId != 0)
         {
            FarmClubDataManager.getInstance().unregisterCaller(this.m_leaderboardCallbackId);
            this.m_leaderboardCallbackId = 0;
         }
      }
      
      public function refresh() : void
      {
         var farmClubDataObj:FarmClubDataObject = null;
         if(this.m_clubId != null)
         {
            farmClubDataObj = FarmClubDataManager.getInstance().getFarmClubDataObjectForId(this.m_clubId) as FarmClubDataObject;
            if(farmClubDataObj == null)
            {
               this.unregisterClubCallback();
               this.m_clubDataCallbackId = FarmClubDataManager.getInstance().registerCaller(this.m_clubId + FarmClubDataManager.FARM_CLUB_DATA,this.setClubData);
               FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_EVENT,FarmClubWindow.BROWSE_CLUB_FRAME));
               this.m_loading = true;
            }
            else
            {
               this.setClubData(farmClubDataObj);
            }
         }
      }
      
      public function setClubData(farmClubDataObj:FarmClubDataObject) : void
      {
         this.m_farmClubDataObject = farmClubDataObj;
         var leaderboardDataObj:ViewFarmClubObject = FarmClubDataManager.getInstance().getClubViewLeaderboardObject(this.m_clubId) as ViewFarmClubObject;
         if(leaderboardDataObj == null)
         {
            this.unregisterLeaderboardCallback();
            this.m_leaderboardCallbackId = FarmClubDataManager.getInstance().registerCaller(this.m_clubId + FarmClubDataManager.CLUB_VIEW_DATA,this.setViewClubData);
         }
         else
         {
            this.setViewClubData(leaderboardDataObj);
         }
      }
      
      public function setViewClubData(leaderboardDataObj:ViewFarmClubObject) : void
      {
         var itemsToPass:Array = null;
         var entry:Object = null;
         var item:FarmItem = null;
         FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_COMPLETE_EVENT,FarmClubWindow.BROWSE_CLUB_FRAME));
         this.m_loading = false;
         this.unregisterLeaderboardCallback();
         if(leaderboardDataObj != null && Boolean(leaderboardDataObj.data))
         {
            itemsToPass = leaderboardDataObj.data.leaderboards as Array;
            for each(entry in itemsToPass)
            {
               entry.clubData = this.m_farmClubDataObject;
            }
            this.m_topFarmersContainerFrame.items = itemsToPass;
            this.m_clubInfo.value = leaderboardDataObj.data.clubInfo.value;
            item = FarmClubUtility.getFarmItemFromTier(this.m_clubInfo.currentTier);
            this.m_cropIcon.loadIcon(item.iconUrl);
            this.m_cropIcon.visible = true;
            this.m_cropIcon.x = ICON_OFFSET_X;
            this.m_cropIcon.y = ICON_OFFSET_Y;
            this.m_clubLogo.loadIcon(FarmClubUtility.getLogoPathFromId(this.m_clubInfo.clubLogoId));
            this.m_clubLogo.visible = true;
            this.m_clubLogo.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
            this.m_clubLogo.x = CLUB_LOGO_OFFSET_X;
            this.m_clubLogo.y = CLUB_LOGO_OFFSET_Y;
            this.m_clubName.text = this.m_clubInfo.clubName;
            this.m_tierRank.text = ZLocUtils.t("FarmClub","MyClub_StageText",{"value":String(this.m_farmClubDataObject.farmClub.currentTier)});
            this.m_tierName.text = item.friendlyTitle;
            this.m_totalHarvested.text = this.m_clubInfo.value;
         }
         else
         {
            this.m_topFarmersContainerFrame.items = [];
         }
      }
      
      private function resetViewClubElements() : void
      {
         this.m_cropIcon.visible = false;
         this.m_clubLogo.visible = false;
         this.m_clubName.text = "";
         this.m_tierRank.text = "";
         this.m_tierName.text = "";
         this.m_totalHarvested.text = "";
      }
   }
}

