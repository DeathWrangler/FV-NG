package Widgets.Slots.FriendInvite
{
   import Classes.Friend;
   import Classes.Player;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FriendInvite.FriendInviteFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FriendInviteSlot extends ZwSlotFrame
   {
      
      public static const STATE_COMPLETE:String = "complete";
      
      public static const STATE_REMIND:String = "remind";
      
      public static const STATE_INVITE:String = "invite";
      
      protected var m_partyCode:String;
      
      private var m_uid:String;
      
      private var m_name:ZwTextField = null;
      
      private var m_image:ZwFrame = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_comingFrame:ZwFrame = null;
      
      private var m_invitedFrame:ZwFrame = null;
      
      private var m_reinviteButton:FarmAnimatedTextButton = null;
      
      private var m_initialInviteButton:FarmAnimatedTextButton = null;
      
      private var m_uninvitedFrame:ZwFrame = null;
      
      private var m_friendData:Object;
      
      private var m_friendInviteFrame:FriendInviteFrame = null;
      
      public function FriendInviteSlot(element:DisplayObject, friendInviteFrame:FriendInviteFrame)
      {
         this.m_friendInviteFrame = friendInviteFrame;
         super(element);
         this.buildGuestListSlot();
      }
      
      private function buildGuestListSlot() : void
      {
         this.m_name = addWidget(new ZwTextField(element.name_tf,"Name"),false) as ZwTextField;
         var invitedText:String = ZLocUtils.t("Dialogs",this.m_friendInviteFrame.locPrefix + "InvitedText");
         this.m_comingFrame = addWidget(new ZwFrame(element.coming_mc),false) as ZwFrame;
         this.m_comingFrame.addWidget(new ZwTextField(this.m_comingFrame.element.generic_tf,invitedText));
         this.m_invitedFrame = addWidget(new ZwFrame(element.invited_mc),false) as ZwFrame;
         this.m_invitedFrame.addWidget(new ZwTextField(this.m_invitedFrame.element.generic_tf,invitedText));
         var buttonText:String = ZLocUtils.t("Dialogs",this.m_friendInviteFrame.locPrefix + "PostFeedButton");
         this.m_reinviteButton = this.m_invitedFrame.addWidget(new FarmAnimatedTextButton(this.m_invitedFrame.element.share_bt,buttonText,this.onShare),true) as FarmAnimatedTextButton;
         this.m_uninvitedFrame = addWidget(new ZwFrame(element.uninvited_mc),false) as ZwFrame;
         this.m_initialInviteButton = this.m_uninvitedFrame.addWidget(new FarmAnimatedTextButton(this.m_uninvitedFrame.element.share_bt,buttonText,this.onShare),true) as FarmAnimatedTextButton;
      }
      
      private function setName(name:String) : void
      {
         this.m_name.text = name;
         this.m_name.visible = true;
      }
      
      private function setImage(image:String, fullName:String) : void
      {
         if(this.m_icon)
         {
            this.m_icon.detachTooltip();
         }
         this.m_icon = null;
         this.m_icon = new FarmIcon(element.icon_mc,image);
         this.m_icon.attachTooltip(new FarmTextTooltip(fullName));
         this.m_icon.visible = true;
      }
      
      private function setState(state:String = "complete", wallToWallAllowed:Boolean = true) : void
      {
         switch(state)
         {
            default:
            case STATE_COMPLETE:
               this.m_comingFrame.visible = true;
               this.m_invitedFrame.visible = false;
               this.m_reinviteButton.visible = false;
               this.m_uninvitedFrame.visible = false;
               this.m_initialInviteButton.visible = false;
               break;
            case STATE_INVITE:
               this.m_comingFrame.visible = false;
               this.m_invitedFrame.visible = false;
               this.m_reinviteButton.visible = false;
               this.m_uninvitedFrame.visible = true;
               this.m_initialInviteButton.visible = wallToWallAllowed;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var picUrl:String = null;
         this.m_uid = data.uid;
         this.m_friendData = data;
         var friend:Friend = Global.friendManager.getAppFriendData(data.uid);
         if(friend)
         {
            this.setName(friend.firstName);
            picUrl = friend.picture;
            if(picUrl == null || picUrl == "")
            {
               picUrl = Global.getAssetURL(Player.NO_PROFILE_PIC_URL);
            }
            this.setImage(picUrl,friend.name);
         }
         var enabled:Boolean = true;
         this.setState(data.state,enabled && Boolean(data.enabled));
      }
      
      public function onShare(e:Event = null) : void
      {
         this.m_friendInviteFrame.updateFriend(this.m_uid,{
            "uid":this.m_uid,
            "enabled":false,
            "state":FriendInviteSlot.STATE_COMPLETE
         });
         this.populate({
            "uid":this.m_uid,
            "enabled":false,
            "state":FriendInviteSlot.STATE_COMPLETE
         });
         var callback:Function = this.m_friendInviteFrame.friendInviteCallback;
         if(callback != null)
         {
            callback(this.m_uid,this.m_friendInviteFrame.getCustomMessageText());
         }
      }
      
      override public function release() : void
      {
         this.m_friendData = null;
         this.m_name = null;
         this.m_image = null;
         this.m_icon = null;
         this.m_comingFrame = null;
         this.m_invitedFrame = null;
         this.m_reinviteButton = null;
         this.m_initialInviteButton = null;
         this.m_uninvitedFrame = null;
      }
   }
}

