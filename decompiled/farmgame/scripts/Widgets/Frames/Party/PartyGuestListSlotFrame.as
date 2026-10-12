package Widgets.Frames.Party
{
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Managers.PartyManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class PartyGuestListSlotFrame extends FarmSlotContainerFrame
   {
      
      public static const SLOT_PER_FRAME_PAGE:Number = 16;
      
      protected var m_code:String = "FS01";
      
      protected var m_partyFull:Boolean = false;
      
      public function PartyGuestListSlotFrame(element:DisplayObject, code:String = "FS01", partyFull:Boolean = false)
      {
         var arrowsVisible:Boolean = false;
         this.m_partyFull = partyFull;
         super(element);
         this.m_code = code;
         var numberOfAppFriends:uint = Global.friendManager.appFriendUids.length;
         arrowsVisible = numberOfAppFriends > SLOT_PER_FRAME_PAGE;
         m_pageBackWidget = new ZwButton(m_element.arrowLeft_mc,m_pagingComponent.onPageBack);
         addWidget(m_pageBackWidget,arrowsVisible);
         m_pageForwardWidget = new ZwButton(m_element.arrowRight_mc,m_pagingComponent.onPageForward);
         addWidget(m_pageForwardWidget,arrowsVisible);
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new PartyGuestListSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
         var obj:Object = null;
         var uid:String = null;
         var friendSet:FriendSet = PartyManager.getInstance().getPartyObjectByCode(this.m_code).friendSet;
         var promptAddNeighbors:Boolean = true;
         var friendList:Array = this.getFriendsToDisplay();
         for each(uid in friendList)
         {
            obj = {};
            obj.uid = uid;
            obj.state = PartyGuestListSlot.STATE_INVITE;
            if(friendSet.friends[uid] != null)
            {
               obj.state = PartyGuestListSlot.STATE_REMIND;
               if(friendSet.friends[uid] > 0)
               {
                  obj.state = PartyGuestListSlot.STATE_COMPLETE;
               }
            }
            obj.enabled = friendSet.canRequestFriend(uid);
            promptAddNeighbors &&= !obj.enabled;
            m_slotData.push(obj);
         }
         if(promptAddNeighbors && !this.m_partyFull)
         {
            FarmStatsManager.count("FriendSet_" + this.m_code,"PromptAddNeighbors","impressions");
            UI.displayMessage(ZLocUtils.t("Dialogs","FriendSetEmptyAddNeighborPrompt"),GenericPopup.TYPE_ACCEPTCANCEL,this.onNeighborPrompt,"addNeighborsPrompt",true);
         }
      }
      
      override public function refresh() : void
      {
         super.refresh();
      }
      
      public function onNeighborPrompt(e:GenericPopupEvent) : void
      {
         if(e.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("FriendSet_" + this.m_code,"PromptAddNeighbors","accept");
            MFSRequestManager.getInstance().displayR2AddNeighborWindow("PartyUI");
         }
         else
         {
            FarmStatsManager.count("FriendSet_" + this.m_code,"PromptAddNeighbors","cancel");
         }
      }
      
      protected function getFriendsToDisplay() : Array
      {
         var friendsToDisplay:Array = new Array();
         if(this.m_partyFull)
         {
            friendsToDisplay = PartyManager.getInstance().getPartyObjectByCode(this.m_code).friendSet.completedFriends;
         }
         else
         {
            friendsToDisplay = Global.friendManager.appFriendUids;
            if(friendsToDisplay.length == 0)
            {
               friendsToDisplay = Global.friendManager.neighborUids;
            }
         }
         return friendsToDisplay;
      }
   }
}

