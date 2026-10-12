package Widgets.Slots.FarmRunQuests
{
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Managers.FarmRunQuestManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Leaderboard.LeaderboardSlotPlayerData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public final class FarmRunQuestLeaderBoardSlotPlayerFrame extends ZwFrame
   {
      
      private static const FRIEND_FRAME:int = 1;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      private var m_scoreTextField:ZwTextField;
      
      public function FarmRunQuestLeaderBoardSlotPlayerFrame(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.friendIcon_mc)) as FarmIcon;
         this.m_icon.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_mc,"")) as ZwTextField;
         this.m_rankTextField = addWidget(new ZwTextField(m_element.rankNumber_tf,"")) as ZwTextField;
         this.m_scoreTextField = addWidget(new ZwTextField(m_element.number_tf,"")) as ZwTextField;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_rankTextField = null;
         this.m_scoreTextField = null;
         super.release();
      }
      
      public function populate(data:LeaderboardSlotPlayerData) : void
      {
         var iconUrl:String = null;
         var level:int = 0;
         var name:String = null;
         var uid:String = null;
         var rank:int = 0;
         var friend:Friend = null;
         if(data)
         {
            uid = String(data.uid);
            if(uid == Global.player.uid)
            {
               iconUrl = Global.player.picture;
               level = Global.player.level;
               name = Global.player.firstName;
               (m_element as MovieClip).gotoAndStop(FarmRunQuestManager.SELF_FRAME);
            }
            else
            {
               friend = Global.friendManager.getFriendData(uid);
               if(friend)
               {
                  iconUrl = friend.picture;
                  level = friend.level;
                  name = friend.firstName;
               }
               (m_element as MovieClip).gotoAndStop(FRIEND_FRAME);
            }
            this.m_icon.loadIcon(iconUrl);
            this.m_nameTextField.text = name ? name : ZLocUtils.t("Leaderboard","EmptyName");
            this.m_scoreTextField.text = String(data.score);
            rank = int(data.rank);
            this.m_rankTextField.text = String(rank);
         }
      }
   }
}

