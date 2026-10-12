package Widgets.Frames.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.DataObjects.FarmClubLeaderboardObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Clubs.FarmClubWindow;
   import flash.display.DisplayObject;
   
   public final class Top50ClubFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_lastClickTime:int;
      
      private var m_icon:FarmIcon;
      
      private var m_timeRemainingTextField:ZwTextField;
      
      private var m_taskTextField:ZwTextField;
      
      private var m_top50ClubSlotFrame:FarmClubGenericSlotContainerFrame;
      
      private var m_idx:int = FarmClubDataManager.UNREGISTERED;
      
      private var m_loading:Boolean = false;
      
      public function Top50ClubFrame(element:DisplayObject)
      {
         super(element);
         this.m_top50ClubSlotFrame = addWidget(new FarmClubGenericSlotContainerFrame(m_element as DisplayObject,"Top50ClubSlot")) as FarmClubGenericSlotContainerFrame;
         this.refresh();
      }
      
      override public function release() : void
      {
         this.unregisterCallback();
         this.m_icon = null;
         this.m_top50ClubSlotFrame = null;
         this.m_taskTextField = null;
         this.m_timeRemainingTextField = null;
         super.release();
      }
      
      public function refresh() : void
      {
         var leaderboardDataObj:FarmClubLeaderboardObject = FarmClubDataManager.getInstance().getTop50LeaderboardObject() as FarmClubLeaderboardObject;
         if(leaderboardDataObj == null)
         {
            this.unregisterCallback();
            this.m_idx = FarmClubDataManager.getInstance().registerCaller(FarmClubDataManager.TOP_50_DATA,this.setData);
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_EVENT,FarmClubWindow.TOP_50_FRAME));
            this.m_loading = true;
         }
         else
         {
            this.setData(leaderboardDataObj);
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
      
      public function setData(leaderboardDataObj:FarmClubLeaderboardObject) : void
      {
         FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_COMPLETE_EVENT,FarmClubWindow.TOP_50_FRAME));
         this.m_loading = false;
         this.unregisterCallback();
         if(leaderboardDataObj != null && Boolean(leaderboardDataObj.data))
         {
            this.m_top50ClubSlotFrame.items = leaderboardDataObj.data as Array;
         }
         else
         {
            this.m_top50ClubSlotFrame.items = [];
         }
      }
   }
}

