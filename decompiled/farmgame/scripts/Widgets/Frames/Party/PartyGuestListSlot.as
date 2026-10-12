package Widgets.Frames.Party
{
   import Classes.FeatureDataObjects.PartyDataObject;
   import Classes.Friend;
   import Managers.PartyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class PartyGuestListSlot extends ZwSlotFrame
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
      
      public function PartyGuestListSlot(element:DisplayObject, code:String = "FS01")
      {
         super(element);
         this.buildGuestListSlot();
         this.m_partyCode = code;
      }
      
      private function buildGuestListSlot() : void
      {
         this.m_name = addWidget(new ZwTextField(element.name_tf,"Name"),false) as ZwTextField;
         this.m_comingFrame = addWidget(new ZwFrame(element.coming_mc),false) as ZwFrame;
         this.m_comingFrame.addWidget(new ZwTextField(this.m_comingFrame.element.generic_tf,"Coming"));
         this.m_invitedFrame = addWidget(new ZwFrame(element.invited_mc),false) as ZwFrame;
         this.m_invitedFrame.addWidget(new ZwTextField(this.m_invitedFrame.element.generic_tf,"Invited"));
         this.m_reinviteButton = this.m_invitedFrame.addWidget(new FarmAnimatedTextButton(this.m_invitedFrame.element.share_bt,"Share",this.onShare),false) as FarmAnimatedTextButton;
         this.m_uninvitedFrame = addWidget(new ZwFrame(element.uninvited_mc),false) as ZwFrame;
         this.m_initialInviteButton = this.m_uninvitedFrame.addWidget(new FarmAnimatedTextButton(this.m_uninvitedFrame.element.share_bt,"Share",this.onShare),false) as FarmAnimatedTextButton;
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
            case STATE_REMIND:
               this.m_comingFrame.visible = false;
               this.m_invitedFrame.visible = true;
               this.m_reinviteButton.visible = wallToWallAllowed;
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
         this.m_uid = data.uid;
         this.m_friendData = data;
         var friend:Friend = Global.friendManager.getAppFriendData(data.uid);
         if(friend)
         {
            this.setName(friend.firstName);
            this.setImage(friend.picture,friend.name);
         }
         var enabled:Boolean = PartyManager.getInstance().getPartyObjectByCode(this.m_partyCode).goal.isEnabled();
         this.setState(data.state,enabled && Boolean(data.enabled));
      }
      
      public function onShare(e:Event = null) : void
      {
         var customMessageInput:ZwTextField = null;
         this.populate({
            "uid":this.m_uid,
            "enabled":false,
            "state":PartyGuestListSlot.STATE_REMIND
         });
         var partydata:PartyDataObject = PartyManager.getInstance().getPartyObjectByCode(this.m_partyCode);
         var autoPublish:Boolean = PartyManager.getInstance().autoPublish;
         var customMessage:String = "";
         if(autoPublish)
         {
            customMessageInput = PartyManager.getInstance().customMessageInput;
            if(customMessageInput)
            {
               customMessage = customMessageInput.text;
            }
         }
         partydata.friendSet.inviteFriend(this.m_uid,autoPublish,customMessage);
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

