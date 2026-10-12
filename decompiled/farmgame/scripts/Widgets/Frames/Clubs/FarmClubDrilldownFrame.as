package Widgets.Frames.Clubs
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.FarmClubConstants;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.DataObjects.FarmClubBaseObject;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.DataObjects.IFarmClubObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmClubDrilldownFrame extends ZwSlotFrame
   {
      
      private var m_parentWindow:FarmWindow = null;
      
      private var m_loading:Boolean = false;
      
      private var m_callbackIdx:int;
      
      private var m_userClubData:FarmClubDataObject = null;
      
      public function FarmClubDrilldownFrame(element:DisplayObject, clubId:String, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         if(element.hasOwnProperty("leaderPic_mc"))
         {
            addWidget(new FarmIcon(element["leaderPic_mc"]),false);
         }
         if(element.hasOwnProperty("leaderMessage_tf"))
         {
            addWidget(new ZwTextField(element["leaderMessage_tf"]),false);
         }
         if(element.hasOwnProperty("leaderMessageBG_mc"))
         {
            addWidget(new ZwWidget(element["leaderMessageBG_mc"]),false);
         }
         if(element.hasOwnProperty("leaderPicBG_mc"))
         {
            addWidget(new ZwWidget(element["leaderPicBG_mc"]),false);
         }
         if(element.hasOwnProperty("clubName_tf"))
         {
            addWidget(new FarmTextField(element["clubName_tf"]));
         }
         if(element.hasOwnProperty("join_bt"))
         {
            addWidget(new FarmAnimatedTextButton(element["join_bt"],ZLocUtils.t("FarmClub","Join")),false);
         }
         this.m_userClubData = FarmClubDataManager.getInstance().getClubDrillDownDataObject(clubId);
         if(this.m_userClubData == null)
         {
            this.handleUnloadedData(this.populateDrillDownData);
         }
         else
         {
            this.populateDrillDownData(this.m_userClubData);
         }
         if(element.hasOwnProperty("close_bt"))
         {
            addWidget(new FarmAnimatedTextButton(element["close_bt"],ZLocUtils.tk_pk_asTitle("FarmClub:drillDownBack"),this.closeFrame));
         }
         if(this.m_loading)
         {
            this.setLoadingSpinnerVisible(true);
         }
      }
      
      private function setUpLeaderboard(inputKey:String, element:DisplayObject, view:String, inputData:FarmClubDataObject, type:String = null) : void
      {
         var leaderboards:Object = null;
         var leaders:Array = null;
         var deleteIndices:Array = null;
         var index:String = null;
         var indexToDelete:String = null;
         var baseObjectType:String = inputKey;
         if(type != null)
         {
            baseObjectType = type;
         }
         var baseObject:FarmClubBaseObject = new FarmClubBaseObject(baseObjectType,FarmClubDataManager.DEFAULT_TTL);
         if(inputData.data[inputKey] != null && inputData.data[inputKey]["leaderboard"] != null)
         {
            leaderboards = inputData.data[inputKey];
            leaders = leaderboards["leaderboard"] as Array;
            deleteIndices = [];
            for(index in leaders)
            {
               if(!leaders[index].hasOwnProperty("friendInfo"))
               {
                  deleteIndices.push(index);
               }
            }
            for each(indexToDelete in deleteIndices)
            {
               leaders.splice(Number(indexToDelete),1);
            }
            leaderboards["leaderboard"] = leaders;
            if(leaders != null && leaders.length > 0)
            {
               baseObject.onLoadData(leaderboards);
               addWidget(new FarmClubLeaderboardSlotContainerFrame(element,inputData.farmClub.currentTier,view,-1,inputData.farmClub,baseObject),true) as FarmClubLeaderboardSlotContainerFrame;
            }
         }
      }
      
      public function populateDrillDownData(inputData:FarmClubDataObject = null) : void
      {
         var data:Object = null;
         var leaderPic:FarmIcon = null;
         var leaderMessage:ZwTextField = null;
         var clubName:FarmTextField = null;
         var oldMember:FarmClubLeaderboardSlotContainerFrame = null;
         var oldFriends:FarmClubLeaderboardSlotContainerFrame = null;
         var oldAllstars:FarmClubLeaderboardSlotContainerFrame = null;
         var iconUrl:String = null;
         var joinButton:FarmAnimatedTextButton = null;
         if(this.m_userClubData == null)
         {
            this.m_userClubData = inputData;
         }
         if(inputData != null)
         {
            data = inputData.data;
            if(m_element.hasOwnProperty("allMembers_mc") && data.hasOwnProperty("members"))
            {
               oldMember = getWidget(m_element["allMembers_mc"]) as FarmClubLeaderboardSlotContainerFrame;
               if(oldMember != null)
               {
                  removeWidget(m_element["allMembers_mc"]);
               }
               this.setUpLeaderboard("members",m_element["allMembers_mc"],FarmClubLeaderboardSlotContainerFrame.LEADERBOARD_VIEW_ROSTER,inputData);
            }
            if(m_element.hasOwnProperty("friendMembers_mc") && data.hasOwnProperty("my_friends"))
            {
               oldFriends = getWidget(m_element["friendMembers_mc"]) as FarmClubLeaderboardSlotContainerFrame;
               if(oldFriends != null)
               {
                  oldFriends.visible = false;
                  removeWidget(m_element["friendMembers_mc"]);
               }
               this.setUpLeaderboard(FarmClubDataManager.CLUB_FRIENDS_DATA,m_element["friendMembers_mc"],FarmClubLeaderboardSlotContainerFrame.LEADERBOARD_VIEW_FRIEND_ROSTER,inputData);
            }
            if(m_element.hasOwnProperty("allstars_mc") && data.hasOwnProperty("champions"))
            {
               oldAllstars = getWidget(m_element["allstars_mc"]) as FarmClubLeaderboardSlotContainerFrame;
               if(oldAllstars != null)
               {
                  removeWidget(m_element["allstars_mc"]);
               }
               this.setUpLeaderboard("champions",m_element["allstars_mc"],FarmClubLeaderboardSlotContainerFrame.LEADERBOARD_VIEW_ALL_STARS,inputData);
            }
            leaderPic = getWidget(m_element["leaderPic_mc"]) as FarmIcon;
            if(leaderPic != null)
            {
               iconUrl = "";
               if(ObjectUtil.pathExists(this.m_userClubData,["leaderInfo","pic_square"]))
               {
                  iconUrl = this.m_userClubData.leaderInfo["pic_square"];
               }
               else
               {
                  iconUrl = FarmClubUtility.getBadgePathForClubRank("leader");
               }
               leaderPic.loadIcon(iconUrl);
               leaderPic.visible = true;
               leaderPic.setIconSize(50,50);
               getWidget(m_element["leaderPicBG_mc"]).visible = true;
            }
            if(m_element.hasOwnProperty("join_bt") && !data.myClub)
            {
               joinButton = getWidget(m_element["join_bt"]) as FarmAnimatedTextButton;
               joinButton.callback = ZCacheUtil.applyPartial(this.onJoinCallback,this,[inputData.farmClub.clubId]);
               joinButton.visible = true;
            }
            leaderMessage = getWidget(m_element["leaderMessage_tf"]) as ZwTextField;
            if(leaderMessage != null)
            {
               leaderMessage.text = this.m_userClubData.farmClub.message;
               leaderMessage.visible = true;
               getWidget(m_element["leaderMessageBG_mc"]).visible = true;
            }
            clubName = getWidget(m_element["clubName_tf"]) as FarmTextField;
            if(clubName != null)
            {
               clubName.text = this.m_userClubData.farmClub.clubName;
               clubName.visible = true;
            }
         }
      }
      
      private function handleUnloadedData(populateFunction:Function) : void
      {
         this.m_loading = true;
         this.m_callbackIdx = FarmClubDataManager.getInstance().registerCaller(FarmClubDataManager.DRILLDOWN_VIEW_DATA,function(result:IFarmClubObject):void
         {
            m_loading = false;
            setLoadingSpinnerVisible(false);
            populateFunction(result);
            FarmClubDataManager.getInstance().unregisterCaller(m_callbackIdx);
         });
      }
      
      private function setLoadingSpinnerVisible(visible:Boolean) : void
      {
         var loadingWidget:ZwWidget = null;
         var element:MovieClip = null;
         var childIndex:int = 0;
         var child:MovieClip = null;
         if(m_element != null && Boolean(m_element["loading_mc"]))
         {
            loadingWidget = getWidget(m_element["loading_mc"]) as ZwWidget;
            if(loadingWidget == null)
            {
               loadingWidget = addWidget(new ZwWidget(m_element["loading_mc"])) as ZwWidget;
            }
            loadingWidget.visible = visible;
            element = loadingWidget.element as MovieClip;
            for(childIndex = 0; childIndex < element.numChildren; childIndex++)
            {
               child = element.getChildAt(childIndex) as MovieClip;
               if(!child)
               {
                  continue;
               }
               switch(visible)
               {
                  case true:
                     child.gotoAndPlay(1);
                     break;
                  case false:
                     child.stop();
               }
            }
         }
      }
      
      private function hideElements() : void
      {
         var leaderPic:ZwBaseWidget = null;
         var leaderMess:ZwTextField = null;
         var leaderMessBG:ZwBaseWidget = null;
         var leaderPicBG:ZwBaseWidget = null;
         var clubName:FarmTextField = null;
         var joinBt:ZwBaseWidget = null;
         var membersBoard:ZwBaseWidget = null;
         var friendsBoard:ZwBaseWidget = null;
         var allstarsBoard:ZwBaseWidget = null;
         if(m_element.hasOwnProperty("leaderPic_mc"))
         {
            leaderPic = getWidget(m_element["leaderPic_mc"]);
            if(leaderPic != null)
            {
               leaderPic.visible = false;
            }
         }
         if(m_element.hasOwnProperty("leaderMessage_tf"))
         {
            leaderMess = getWidget(m_element["leaderMessage_tf"]) as ZwTextField;
            if(leaderMess != null)
            {
               leaderMess.text = "";
               leaderMess.visible = false;
            }
         }
         if(m_element.hasOwnProperty("leaderMessageBG_mc"))
         {
            leaderMessBG = getWidget(m_element["leaderMessageBG_mc"]);
            if(leaderMessBG != null)
            {
               leaderMessBG.visible = false;
            }
         }
         if(m_element.hasOwnProperty("leaderPicBG_mc"))
         {
            leaderPicBG = getWidget(m_element["leaderPicBG_mc"]);
            if(leaderPicBG != null)
            {
               leaderPicBG.visible = false;
            }
         }
         if(m_element.hasOwnProperty("clubName_tf"))
         {
            clubName = getWidget(m_element["clubName_tf"]) as FarmTextField;
            if(clubName != null)
            {
               clubName.text = "";
            }
         }
         if(m_element.hasOwnProperty("join_bt"))
         {
            joinBt = getWidget(m_element["join_bt"]);
            if(joinBt != null)
            {
               joinBt.visible = false;
            }
         }
         if(m_element.hasOwnProperty("allMembers_mc"))
         {
            membersBoard = getWidget(m_element["allMembers_mc"]);
            if(membersBoard != null)
            {
               membersBoard.visible = false;
            }
         }
         if(m_element.hasOwnProperty("friendMembers_mc"))
         {
            friendsBoard = getWidget(m_element["friendMembers_mc"]);
            if(friendsBoard != null)
            {
               friendsBoard.visible = false;
            }
         }
         if(m_element.hasOwnProperty("allstars_mc"))
         {
            allstarsBoard = getWidget(m_element["allstars_mc"]);
            if(allstarsBoard != null)
            {
               allstarsBoard.visible = false;
            }
         }
      }
      
      public function setUserClub(clubId:String) : void
      {
         this.hideElements();
         var forceStale:Boolean = this.m_userClubData != null && this.m_userClubData.farmClub != null ? this.m_userClubData.farmClub.clubId != clubId : false;
         this.m_userClubData = FarmClubDataManager.getInstance().getClubDrillDownDataObject(clubId,false,forceStale);
         if(this.m_userClubData == null)
         {
            this.handleUnloadedData(this.populateDrillDownData);
         }
         else
         {
            this.populateDrillDownData(this.m_userClubData);
         }
         if(this.m_loading)
         {
            this.setLoadingSpinnerVisible(true);
         }
         this.visible = true;
      }
      
      public function closeFrame(event:MouseEvent) : void
      {
         this.visible = false;
      }
      
      private function onJoinCallback(clubId:String, event:MouseEvent) : void
      {
         FarmClubUtility.canJoinClub(clubId,function(result:Boolean):void
         {
            if(result)
            {
               FarmClubUtility.joinClub(clubId,joinedClubCallback);
               hideElements();
               setLoadingSpinnerVisible(true);
            }
         });
      }
      
      private function joinedClubCallback(result:Object) : void
      {
         this.m_parentWindow.close();
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.CREATE_CLUB_EVENT,function(event:DynamicObjectEvent):void
         {
            FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.CREATE_CLUB_EVENT,arguments.callee);
            FarmClubUtility.showDialog();
         });
      }
   }
}

