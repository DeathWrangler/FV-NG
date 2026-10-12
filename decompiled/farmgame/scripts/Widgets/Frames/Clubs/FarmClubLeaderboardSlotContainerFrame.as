package Widgets.Frames.Clubs
{
   import Classes.util.ZLocUtils;
   import Managers.Clubs.DataObjects.FarmClub;
   import Managers.Clubs.DataObjects.FarmClubBaseObject;
   import Managers.Clubs.FarmClubDataManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Clubs.FarmClubLeaderboardSlot;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmClubLeaderboardSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public static const LEADERBOARD_VIEW_ROSTER:String = "my_rank";
      
      public static const LEADERBOARD_VIEW_FRIEND_ROSTER:String = "my_friends";
      
      public static const LEADERBOARD_VIEW_MY_TIER:String = "our_rank";
      
      public static const LEADERBOARD_VIEW_ALL_STARS:String = "all_stars";
      
      private static const INDICATOR_ARROW_PREFIX:String = "indicatorArrow_";
      
      private static const INDICATOR_ARROW_SUFFIX:String = "_mc";
      
      private var m_window:FarmClubWindow2;
      
      private var m_dataCallbackIndex:int = 0;
      
      private var m_currentView:String = "";
      
      private var m_clubLeaderboardData:FarmClubBaseObject = null;
      
      private var m_tierClubCountText:ZwTextField = null;
      
      private var m_tierNameText:ZwTextField = null;
      
      private var m_loadingSpinner:ZwWidget = null;
      
      private var m_currentArrowIndex:int = -1;
      
      private var m_indicatorArrows:Object = null;
      
      private var m_currentTier:int = -1;
      
      private var m_userClub:FarmClub = null;
      
      public function FarmClubLeaderboardSlotContainerFrame(element:DisplayObject, clubCurrentTier:int, view:String = "", arrowIndex:int = -1, userClub:FarmClub = null, userClubData:FarmClubBaseObject = null, window:FarmClubWindow2 = null)
      {
         this.m_userClub = userClub;
         this.m_window = window;
         super(element);
         this.m_currentTier = clubCurrentTier;
         if(view == "")
         {
            view = LEADERBOARD_VIEW_ROSTER;
         }
         this.m_currentView = view;
         this.m_currentArrowIndex = arrowIndex;
         this.m_indicatorArrows = new Object();
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack),false) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward),false) as ZwButton;
         if(m_element.hasOwnProperty("clubCount_tf"))
         {
            this.m_tierClubCountText = new ZwTextField(m_element.clubCount_tf,"");
            addWidget(this.m_tierClubCountText,false);
         }
         this.m_loadingSpinner = new ZwWidget(m_element.loadingSpinner_mc);
         addWidget(this.m_loadingSpinner,false);
         addWidget(new ZwTextField(m_element.title_tf,ZLocUtils.t("FarmClub","leaderboardTitle")));
         if(userClubData == null)
         {
            this.fetchViewData();
         }
         else
         {
            this.m_clubLeaderboardData = userClubData;
            this.populateLeaderboardData();
         }
         if(m_element.hasOwnProperty("stageName_tf"))
         {
            this.m_tierNameText = addWidget(new ZwTextField(m_element.stageName_tf,ZLocUtils.t("FarmClub","stageName_" + clubCurrentTier))) as ZwTextField;
         }
         if(m_element.hasOwnProperty("close_bt"))
         {
            addWidget(new FarmButton(m_element.close_bt,this.onClose));
         }
         if(this.m_currentArrowIndex != -1)
         {
            this.showIndicatorArrow();
         }
      }
      
      private function populateLeaderboardData() : void
      {
         m_slotData = this.m_clubLeaderboardData.data.leaderboard ? this.m_clubLeaderboardData.data.leaderboard : new Array();
         m_pagingComponent.reset();
         refresh();
         if(this.m_currentView == LEADERBOARD_VIEW_MY_TIER)
         {
            if(this.m_tierClubCountText != null)
            {
               this.m_tierClubCountText.text = ZLocUtils.t("FarmClub","numClubsCompeting",{"num":(this.m_clubLeaderboardData.data.leaderboardTotal ? this.m_clubLeaderboardData.data.leaderboardTotal : 0)});
               this.m_tierClubCountText.visible = true;
            }
         }
         else if(this.m_currentView == LEADERBOARD_VIEW_ROSTER && this.m_userClub != null)
         {
            if(this.m_tierClubCountText != null)
            {
               this.m_tierClubCountText.text = ZLocUtils.t("FarmClub","numUsersInClub",{"num":this.m_userClub.numMembers});
               this.m_tierClubCountText.visible = true;
            }
            (getWidget(m_element.title_tf) as ZwTextField).text = ZLocUtils.t("FarmClub","rosterLeaderboardTitle");
         }
         else if(this.m_currentView == LEADERBOARD_VIEW_FRIEND_ROSTER)
         {
            (getWidget(m_element.title_tf) as ZwTextField).text = ZLocUtils.t("FarmClub","friendsLeaderboardTitle");
         }
         else if(this.m_currentView == LEADERBOARD_VIEW_ALL_STARS)
         {
            (getWidget(m_element.title_tf) as ZwTextField).text = ZLocUtils.t("FarmClub","allstarsLeaderboardTitle");
         }
         this.m_loadingSpinner.visible = false;
         (this.m_loadingSpinner.element as MovieClip).stop();
      }
      
      override protected function getSlotPrefix() : String
      {
         return "clubSlot_";
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmClubLeaderboardSlot(slotElement,this.m_userClub,this.m_window);
      }
      
      override protected function setupData() : void
      {
      }
      
      private function onClose(event:Event) : void
      {
         this.visible = false;
      }
      
      private function fetchViewData() : void
      {
         switch(this.m_currentView)
         {
            case FarmClubDataManager.TOP_50_DATA:
               this.m_clubLeaderboardData = FarmClubDataManager.getInstance().getTop50LeaderboardObject();
               break;
            case FarmClubDataManager.TIER_TOP_10_DATA:
               this.m_currentView = FarmClubDataManager.getTop10DataKey(this.m_currentTier);
               this.m_clubLeaderboardData = FarmClubDataManager.getInstance().getTierTop10Data(this.m_currentTier);
               break;
            default:
               this.m_clubLeaderboardData = FarmClubDataManager.getInstance().getMyClubLeaderboardObject(this.m_currentView);
         }
         if(this.m_clubLeaderboardData == null)
         {
            this.m_loadingSpinner.visible = true;
            (this.m_loadingSpinner.element as MovieClip).gotoAndPlay(1);
            this.m_dataCallbackIndex = FarmClubDataManager.getInstance().registerCaller(this.m_currentView,function(result:FarmClubBaseObject):void
            {
               FarmClubDataManager.getInstance().unregisterCaller(m_dataCallbackIndex);
               m_clubLeaderboardData = result;
               populateLeaderboardData();
            });
         }
         else
         {
            this.populateLeaderboardData();
         }
      }
      
      public function setView(newView:String) : void
      {
         if(newView != this.m_currentView)
         {
            this.m_currentView = newView;
            FarmClubDataManager.getInstance().unregisterCaller(this.m_dataCallbackIndex);
            clearSlots();
            m_pageBackWidget.visible = false;
            m_pageForwardWidget.visible = false;
            if(this.m_tierClubCountText != null)
            {
               this.m_tierClubCountText.visible = false;
            }
            this.fetchViewData();
         }
      }
      
      public function setArrowIndex(newIndex:int) : void
      {
         var arrowName:String = null;
         if(this.m_currentArrowIndex != newIndex)
         {
            arrowName = this.getIndicatorArrowName();
            this.m_indicatorArrows[arrowName].visible = false;
            this.m_currentArrowIndex = newIndex;
            this.showIndicatorArrow();
         }
      }
      
      public function setCurrentTierIndex(newTier:int) : void
      {
         if(this.m_currentTier != newTier && this.m_tierNameText != null)
         {
            this.m_currentTier = newTier;
            this.m_tierNameText.text = ZLocUtils.t("FarmClub","stageName_" + this.m_currentTier);
         }
      }
      
      public function setUserClub(userClub:FarmClub) : void
      {
         var slot:FarmClubLeaderboardSlot = null;
         this.m_userClub = userClub;
         for each(slot in m_slots)
         {
            slot.setUserClub(this.m_userClub);
         }
      }
      
      private function getIndicatorArrowName() : String
      {
         return INDICATOR_ARROW_PREFIX + this.m_currentArrowIndex + INDICATOR_ARROW_SUFFIX;
      }
      
      private function showIndicatorArrow() : void
      {
         var arrowName:String = this.getIndicatorArrowName();
         if(m_element.hasOwnProperty(arrowName))
         {
            if(!this.m_indicatorArrows.hasOwnProperty(arrowName))
            {
               this.m_indicatorArrows[arrowName] = addWidget(new ZwWidget(m_element[arrowName])) as ZwWidget;
            }
            else
            {
               this.m_indicatorArrows[arrowName].visible = true;
            }
         }
      }
   }
}

