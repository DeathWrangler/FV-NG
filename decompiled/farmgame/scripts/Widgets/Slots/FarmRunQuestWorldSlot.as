package Widgets.Slots
{
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Managers.FarmRunQuestManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Leaderboard.LeaderboardSlotPlayerData;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmRunQuestWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class FarmRunQuestWorldSlot extends ZwSlotFrame
   {
      
      private var m_window:FarmRunQuestWindow;
      
      protected var m_item:FarmItem = null;
      
      private var m_index:int = -1;
      
      private var m_completeIcon:MovieClip;
      
      private var m_lockIcon:MovieClip;
      
      private var m_profileIconFrame1:ZwFrame;
      
      private var m_ProfileIcon1:FarmIcon;
      
      private var m_profileIconFrame2:ZwFrame;
      
      private var m_ProfileIcon2:FarmIcon;
      
      private var m_profileIconFrame3:ZwFrame;
      
      private var m_ProfileIcon3:FarmIcon;
      
      private var m_iconTooltip:FarmTextTooltip;
      
      public function FarmRunQuestWorldSlot(element:DisplayObject, window:FarmRunQuestWindow)
      {
         super(element);
         if(m_element.icon_mc != null)
         {
            addWidget(new FarmIcon(m_element.icon_mc));
         }
         addWidget(new ZwTextField(element["generic_tf"],"-1"));
         this.m_window = window;
         if(m_element.hasOwnProperty("completeIcon_mc"))
         {
            this.m_completeIcon = m_element.completeIcon_mc as MovieClip;
         }
         if(m_element.hasOwnProperty("lock_mc"))
         {
            this.m_lockIcon = m_element.lock_mc as MovieClip;
         }
         this.m_profileIconFrame1 = addWidget(new ZwFrame(m_element.opponent_1_mc)) as ZwFrame;
         this.m_ProfileIcon1 = this.m_profileIconFrame1.addWidget(new FarmIcon(m_element.opponent_1_mc)) as FarmIcon;
         this.m_ProfileIcon1.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
         this.m_ProfileIcon1.setSmoothing(true);
         this.m_ProfileIcon1.visible = false;
         this.m_profileIconFrame2 = addWidget(new ZwFrame(m_element.opponent_2_mc)) as ZwFrame;
         this.m_ProfileIcon2 = this.m_profileIconFrame2.addWidget(new FarmIcon(m_element.opponent_2_mc)) as FarmIcon;
         this.m_ProfileIcon2.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
         this.m_ProfileIcon2.setSmoothing(true);
         this.m_ProfileIcon2.visible = false;
         this.m_profileIconFrame3 = addWidget(new ZwFrame(m_element.opponent_3_mc)) as ZwFrame;
         this.m_ProfileIcon3 = this.m_profileIconFrame3.addWidget(new FarmIcon(m_element.opponent_3_mc)) as FarmIcon;
         this.m_ProfileIcon3.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
         this.m_ProfileIcon3.setSmoothing(true);
      }
      
      private function refreshSlotData() : void
      {
      }
      
      override public function populate(data:Object) : void
      {
         var iconUrl:String = null;
         var itemBox:FarmIcon = null;
         var uid:String = null;
         var friend:Friend = null;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(data.item_code);
         this.m_index = data.index;
         var currentFarmRunStage:int = FarmRunQuestManager.getInstance().getCurrentStage();
         if(this.m_index == currentFarmRunStage)
         {
            m_element.gotoAndStop(2);
         }
         else
         {
            m_element.gotoAndStop(1);
         }
         removeWidget(m_element.generic_tf);
         removeWidget(m_element["icon_mc"]);
         addWidget(new FarmIcon(element.icon_mc));
         addWidget(new ZwTextField(element["generic_tf"],"-1"));
         var stageCount:ZwTextField = getWidget(m_element.generic_tf) as ZwTextField;
         stageCount.text = (this.m_index + 1).toString();
         stageCount.visible = true;
         if(Boolean(m_element) && Boolean(m_element["icon_mc"]))
         {
            itemBox = getWidget(m_element["icon_mc"]) as FarmIcon;
            if(Boolean(itemBox) && Boolean(this.m_item))
            {
               itemBox.loadIcon(this.m_item.icon);
               itemBox.visible = true;
               this.m_iconTooltip = new FarmTextTooltip(this.m_item.friendlyTitle);
               itemBox.attachTooltip(this.m_iconTooltip);
            }
         }
         if(currentFarmRunStage < this.m_index)
         {
            this.m_lockIcon.visible = true;
            this.m_completeIcon.visible = false;
         }
         else if(currentFarmRunStage > this.m_index)
         {
            this.m_lockIcon.visible = false;
            this.m_completeIcon.visible = true;
         }
         else
         {
            this.m_lockIcon.visible = false;
            this.m_completeIcon.visible = false;
         }
         var FriendData:LeaderboardSlotPlayerData = FarmRunQuestManager.getInstance().getFriendsListByStage(data.index);
         if(FriendData)
         {
            uid = String(FriendData.uid);
            if(uid == Global.player.uid)
            {
               iconUrl = Global.player.picture;
            }
            else
            {
               friend = Global.friendManager.getFriendData(uid);
               if(friend)
               {
                  iconUrl = friend.picture;
               }
            }
            this.m_ProfileIcon3.loadIcon(iconUrl);
            this.m_ProfileIcon3.visible = true;
         }
         else
         {
            this.m_ProfileIcon3.visible = false;
         }
         this.refreshSlotData();
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

