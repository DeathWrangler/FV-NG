package Widgets.Slots.Leaderboard
{
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public final class LeaderboardSlotPlayerFrame extends ZwFrame
   {
      
      private static const FRIEND_FRAME:int = 1;
      
      private static const SELF_FRAME:int = 2;
      
      private static const ICON_SIZE:int = 25;
      
      private var m_icon:FarmIcon;
      
      private var m_levelTextField:ZwTextField;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      private var m_scoreTextField:ZwTextField;
      
      private var m_trophyWidget:ZwWidget;
      
      public function LeaderboardSlotPlayerFrame(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.friendIcon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_levelTextField = addWidget(new ZwTextField(m_element.levelNumber_mc,"")) as ZwTextField;
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_mc,"")) as ZwTextField;
         this.m_rankTextField = addWidget(new ZwTextField(m_element.rankNumber_tf,"")) as ZwTextField;
         this.m_scoreTextField = addWidget(new ZwTextField(m_element.number_tf,"")) as ZwTextField;
         this.m_trophyWidget = addWidget(new ZwWidget(m_element.trophies_mc)) as ZwWidget;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_levelTextField = null;
         this.m_nameTextField = null;
         this.m_rankTextField = null;
         this.m_scoreTextField = null;
         this.m_trophyWidget = null;
         super.release();
      }
      
      public function populate(data:LeaderboardSlotPlayerData) : void
      {
         var iconUrl:String = null;
         var level:int = 0;
         var name:String = null;
         var friend:Friend = null;
         var uid:String = String(data.uid);
         if(uid == Global.player.uid)
         {
            iconUrl = Global.player.picture;
            level = Global.player.level;
            name = Global.player.firstName;
            (m_element as MovieClip).gotoAndStop(SELF_FRAME);
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
         this.m_levelTextField.text = level > 0 ? String(level) : "?";
         this.m_nameTextField.text = name ? name : ZLocUtils.t("Leaderboard","EmptyName");
         this.m_scoreTextField.text = String(data.score);
         var rank:int = int(data.rank);
         this.m_rankTextField.text = String(rank);
         if(rank >= 1 && rank <= 3)
         {
            this.m_trophyWidget.visible = true;
            (this.m_trophyWidget.element as MovieClip).gotoAndStop(rank);
         }
         else
         {
            this.m_trophyWidget.visible = false;
         }
      }
   }
}

