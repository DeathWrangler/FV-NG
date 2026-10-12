package Widgets.Frames
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.CommunityMatchmakingUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.MFSCurrentNeighborSlot;
   import Widgets.Windows.MFSAddNeighbor;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MFSCurrentNeighborSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_clickCallback:Function;
      
      private var m_parentWindow:MFSAddNeighbor;
      
      private var m_header:ZwTextField = null;
      
      private var m_multiDeleteMode:Boolean = false;
      
      private var m_multiDeleteButton:FarmAnimatedTextButton;
      
      public function MFSCurrentNeighborSlotFrame(element:MovieClip, clickCallback:Function, parentWindow:MFSAddNeighbor)
      {
         this.m_clickCallback = clickCallback;
         this.m_parentWindow = parentWindow;
         super(element);
      }
      
      public static function sortPlayedDaysAgoDescending(userInfo1:Object, userInfo2:Object) : int
      {
         var result:int = 0;
         var playedDaysAgoStr:String = "played_days_ago";
         if(Boolean(userInfo1[playedDaysAgoStr]) && Boolean(userInfo2[playedDaysAgoStr]))
         {
            if(userInfo1[playedDaysAgoStr] > userInfo2[playedDaysAgoStr])
            {
               result = -1;
            }
            else if(userInfo1[playedDaysAgoStr] < userInfo2[playedDaysAgoStr])
            {
               result = 1;
            }
            else
            {
               result = 0;
            }
         }
         else if(userInfo1[playedDaysAgoStr])
         {
            result = 1;
         }
         else if(userInfo2[playedDaysAgoStr])
         {
            result = -1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      public function get multiDeleteMode() : Boolean
      {
         return this.m_multiDeleteMode;
      }
      
      public function set multiDeleteMode(mode:Boolean) : void
      {
         this.m_multiDeleteMode = mode;
      }
      
      public function set multiDeleteButtonEnabled(enabled:Boolean) : void
      {
         if(this.m_multiDeleteButton)
         {
            this.m_multiDeleteButton.enabled = enabled;
         }
      }
      
      public function set items(items:Array) : void
      {
         var numToAutoSelect:int = 0;
         var datum:Object = null;
         if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment())
         {
            this.m_parentWindow.clearSelectedNeighborsToDeleteData();
            items.sort(sortPlayedDaysAgoDescending);
            if(this.m_multiDeleteMode)
            {
               StatsManager.count(CommunityMatchmakingUtility.FEATURE_NAME,"purge_neighbors_dialog",StatsTrackingConstants.IMPRESSIONS);
               numToAutoSelect = 0;
               for each(datum in items)
               {
                  datum.multiDelete = true;
                  if(numToAutoSelect < this.m_parentWindow.numNeighborsNeededToDelete && (!datum.played_days_ago || datum.played_days_ago >= 3))
                  {
                     datum.autoSelect = true;
                     numToAutoSelect++;
                  }
               }
            }
         }
         m_slotData = items;
         refresh();
      }
      
      public function setState(data:Object) : void
      {
         var slot:MFSCurrentNeighborSlot = null;
         for each(slot in m_slots)
         {
            if(slot.visible && slot.data["uid"] == data["uid"])
            {
               slot.visible = false;
            }
         }
      }
      
      override public function release() : void
      {
         this.m_clickCallback = null;
         this.m_parentWindow = null;
         this.m_header = null;
         super.release();
      }
      
      override protected function setupData() : void
      {
         if(this.m_header == null)
         {
            this.m_header = addWidget(new ZwTextField(m_element.header_tf," ")) as ZwTextField;
         }
      }
      
      public function addMultiDeleteButton() : void
      {
         if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment() && !this.m_multiDeleteButton)
         {
            this.m_multiDeleteButton = new FarmAnimatedTextButton(m_element.addNeighbors_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"community_matchmaking_v3_remove_and_add"),this.onMultiDeleteButtonClicked);
            addWidget(this.m_multiDeleteButton);
         }
      }
      
      private function onMultiDeleteButtonClicked(event:MouseEvent) : void
      {
         this.m_parentWindow.removeAndAddNeighbors();
      }
      
      public function updateHeader(neighborCount:int) : void
      {
         this.m_header.text = ZLocUtils.t("Dialogs","AddNeighborCurrentFriends",{"count":neighborCount});
         this.m_header.visible = true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MFSCurrentNeighborSlot(slotElement,this.m_clickCallback,this.m_parentWindow);
      }
   }
}

