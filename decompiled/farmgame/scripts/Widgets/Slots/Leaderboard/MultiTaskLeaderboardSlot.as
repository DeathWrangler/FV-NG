package Widgets.Slots.Leaderboard
{
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class MultiTaskLeaderboardSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_data:LeaderboardSlotPlayerData;
      
      private var m_iconFrame:ZwFrame;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_scoreTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      public function MultiTaskLeaderboardSlot(element:DisplayObject)
      {
         super(element);
         this.m_iconFrame = addWidget(new ZwFrame(m_element.profile_mc)) as ZwFrame;
         this.m_icon = this.m_iconFrame.addWidget(new FarmIcon(m_element.profile_mc.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf,"")) as ZwTextField;
         this.m_scoreTextField = addWidget(new ZwTextField(m_element.points_tf,"")) as ZwTextField;
         this.m_rankTextField = addWidget(new ZwTextField(m_element.rank_tf,"")) as ZwTextField;
      }
      
      override public function populate(data:Object) : void
      {
         var iconUrl:String = null;
         var level:int = 0;
         var name:String = null;
         var uid:String = null;
         var rank:int = 0;
         var friend:Friend = null;
         super.populate(data);
         this.m_data = data as LeaderboardSlotPlayerData;
         if(this.m_data)
         {
            uid = String(this.m_data.uid);
            if(uid == Global.player.uid)
            {
               iconUrl = Global.player.picture;
               name = Global.player.firstName;
            }
            else
            {
               friend = Global.friendManager.getFriendData(uid);
               if(friend)
               {
                  iconUrl = friend.picture;
                  name = friend.firstName;
               }
            }
            this.m_iconFrame.visible = true;
            this.m_icon.loadIcon(iconUrl);
            this.m_icon.visible = true;
            this.m_nameTextField.text = name ? name : ZLocUtils.t("Leaderboard","EmptyName");
            this.m_nameTextField.visible = true;
            this.m_scoreTextField.text = String(this.m_data.score);
            this.m_scoreTextField.visible = true;
            rank = int(this.m_data.rank);
            this.m_rankTextField.text = String(rank);
            this.m_rankTextField.visible = true;
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_iconFrame = null;
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_scoreTextField = null;
         this.m_rankTextField = null;
         super.release();
      }
   }
}

