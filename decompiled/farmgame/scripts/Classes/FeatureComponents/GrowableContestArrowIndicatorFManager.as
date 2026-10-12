package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.Friend;
   import Classes.Growable.GrowableContest;
   import Classes.Growable.GrowableContestConstants;
   import Classes.ZItem.FarmItem;
   import Events.FarmGameWorldEvent;
   import GameMode.GMBuild;
   import Managers.GrowableContestManager;
   import Widgets.Windows.GrowableContestWindow;
   import flash.events.Event;
   
   public class GrowableContestArrowIndicatorFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      public static const STATE_PARTNER_REQUEST:String = "partner_request";
      
      private var m_contest:GrowableContest;
      
      public function GrowableContestArrowIndicatorFManager(owner:FeatureBuilding)
      {
         Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,this.onUserChanged,false,0,true);
         m_owner = owner;
         super(owner);
      }
      
      private function onUserChanged(e:Event) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_CHANGED,this.onUserChanged);
         if(this.contest != null)
         {
            if(this.contest.isInviteStatusLoaded)
            {
               this.conditionallyShowPendingRequest();
            }
            else
            {
               this.contest.addEventListener(GrowableContestConstants.EVENT_INVITE_STATUS_LOADED,this.onContestInviteStatusLoaded);
            }
         }
      }
      
      private function onContestInviteStatusLoaded(event:Event) : void
      {
         if(this.contest != null)
         {
            this.contest.removeEventListener(GrowableContestConstants.EVENT_INVITE_STATUS_LOADED,this.onContestInviteStatusLoaded);
            this.conditionallyShowPendingRequest();
         }
      }
      
      private function conditionallyShowPendingRequest() : void
      {
         var indicatorState:String = null;
         if(this.contest != null)
         {
            if(this.contest.isInviteStatusLoaded)
            {
               indicatorState = this.getArrowIndicatorType();
               show(indicatorState);
            }
         }
      }
      
      private function getArrowIndicatorType() : String
      {
         var currentGMs:Array = null;
         var pendingList:Array = null;
         var firstRequest:Object = null;
         var arrowState:Object = null;
         var type:String = "";
         currentGMs = Global.world.getActiveGameModes();
         m_lookInsideOnClick = false;
         if(!Global.worldManager.isVisiting() || !(currentGMs[0] is GMBuild))
         {
            if(this.contest != null)
            {
               pendingList = this.contest.getPendingList();
               if(pendingList != null && pendingList.length > 0)
               {
                  firstRequest = pendingList[0];
                  if(firstRequest.hasOwnProperty("partner"))
                  {
                     m_lookInsideOnClick = true;
                     type = STATE_PARTNER_REQUEST;
                     arrowState = this.getState(type);
                     arrowState.icon = this.getLastHelpFriendPic(firstRequest.partner);
                     this.setState(type,arrowState);
                     m_lookInsideOnClick = false;
                  }
               }
            }
         }
         return type;
      }
      
      private function get contest() : GrowableContest
      {
         var ownerItem:FarmItem = null;
         var contestId:String = null;
         if(this.m_contest == null)
         {
            if(m_owner)
            {
               ownerItem = m_owner.getItem();
               if(ownerItem)
               {
                  contestId = GrowableContestManager.instance.getContestIdForBuildingCode(ownerItem.code);
                  if(contestId)
                  {
                     this.m_contest = GrowableContestManager.instance.getContest(contestId);
                     if(this.m_contest)
                     {
                        this.m_contest.addEventListener(GrowableContestConstants.EVENT_PARTNER_REQUEST_UPDATE,this.onNewContestRequests);
                     }
                  }
               }
            }
         }
         return this.m_contest;
      }
      
      private function onNewContestRequests(event:Event) : void
      {
         this.conditionallyShowPendingRequest();
      }
      
      private function getLastHelpFriendPic(friendId:String) : String
      {
         var iconUrl:String = "";
         var friend:Friend = Global.friendManager.getAppFriendData(friendId);
         if(friend)
         {
            iconUrl = friend.picture;
         }
         return iconUrl;
      }
      
      override public function canDisplay() : Boolean
      {
         return true;
      }
      
      override public function onClick() : void
      {
         GrowableContestWindow.showWindowForBuilding(owner);
      }
      
      override public function onDetatch() : void
      {
         if(this.m_contest)
         {
            this.m_contest.removeEventListener(GrowableContestConstants.EVENT_PARTNER_REQUEST_UPDATE,this.onNewContestRequests);
         }
         super.onDetatch();
      }
      
      override public function hide() : void
      {
         super.hide();
      }
   }
}

