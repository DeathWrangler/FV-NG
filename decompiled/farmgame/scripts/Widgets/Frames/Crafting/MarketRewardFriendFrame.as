package Widgets.Frames.Crafting
{
   import Classes.Friend;
   import Classes.Player;
   import Classes.util.FarmGameUtil;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class MarketRewardFriendFrame extends ZwFrame
   {
      
      public function MarketRewardFriendFrame(element:DisplayObject)
      {
         super(element);
         addWidget(new FarmIcon(this.element.rewardIcon_mc,Player.NO_PROFILE_PIC_URL));
         addWidget(new ZwTextField(this.element.cropType_tf," "),false);
         addWidget(new ZwTextField(this.element.name_tf," "),false);
      }
      
      public function update(uid:String = null, count:String = null) : void
      {
         var friend:Friend = null;
         var countString:String = null;
         var nameField:ZwTextField = getWidget(element.name_tf) as ZwTextField;
         var countField:ZwTextField = getWidget(element.cropType_tf) as ZwTextField;
         nameField.visible = false;
         countField.visible = false;
         var icon:FarmIcon = getWidget(m_element.rewardIcon_mc) as FarmIcon;
         if(uid)
         {
            icon.loadIcon(FarmGameUtil.getFriendIconByUid(uid));
            icon.setIconSize(50,50);
            friend = Global.friendManager.getFriendData(uid);
            if(Boolean(friend) && Boolean(friend.name))
            {
               nameField.text = friend.name;
               nameField.visible = true;
               countString = count + " bushel";
               countField.text = count + " bushel";
               if(Number(count) > 1)
               {
                  countString = count + " bushels";
               }
               countField.text = countString;
               countField.visible = true;
            }
         }
         else
         {
            icon.loadIcon(Player.NO_PROFILE_PIC_URL);
            icon.setIconSize(50,50);
         }
      }
   }
}

