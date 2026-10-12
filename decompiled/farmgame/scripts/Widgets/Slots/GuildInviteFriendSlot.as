package Widgets.Slots
{
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GuildAddMembersWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildInviteFriendSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_message_tf:ZwTextField;
      
      private var m_slotIndex:int;
      
      private var m_data:Object;
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_name_tf:ZwTextField;
      
      private var checkmark_mc:MovieClip;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_decline_bt:FarmAnimatedTextButton;
      
      private var m_invite_bt:FarmAnimatedTextButton;
      
      private var m_parentWindow:GuildAddMembersWindow;
      
      private var m_icon:FarmIcon;
      
      public function GuildInviteFriendSlot(element:DisplayObject, featureName:String, window:GuildAddMembersWindow)
      {
         this.m_featureName = featureName;
         this.m_parentWindow = window;
         super(element);
         (m_element as MovieClip).visible = true;
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_name_tf = new ZwTextField(m_element["name_tf"],"0"));
         }
         if(m_element.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_element["accept_bt"],"Accept",null));
            this.m_accept_bt.visible = false;
         }
         if(m_element.hasOwnProperty("decline_bt"))
         {
            addWidget(this.m_decline_bt = new FarmAnimatedTextButton(m_element["decline_bt"],"Decline",null));
            this.m_decline_bt.visible = false;
         }
         if(m_element.hasOwnProperty("invite_bt"))
         {
            addWidget(this.m_invite_bt = new FarmAnimatedTextButton(m_element["invite_bt"],"Invite",null));
            this.m_invite_bt.visible = false;
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.checkmark_mc = m_element["checkmark_mc"] as MovieClip;
            this.checkmark_mc.visible = false;
         }
         this.m_icon = new FarmIcon(m_element["icon_mc"] as MovieClip);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data.index;
         if(this.m_isIconPreviewAdded == true)
         {
            removeWidget(this.m_iconPreview);
            this.m_iconPreview.detachTooltip();
         }
         if(this.m_icon)
         {
            this.m_icon.release();
         }
         this.m_icon = new FarmIcon(m_element["icon_mc"] as MovieClip,this.m_data.pic_square);
         this.m_icon.setIconSize(50,50);
         this.m_icon.detachTooltip();
         this.m_icon.visible = true;
         if(this.m_name_tf)
         {
            this.m_name_tf.text = this.m_data.name;
            this.m_name_tf.visible = true;
         }
         this.m_accept_bt.applyGrayOut = false;
         this.m_decline_bt.applyGrayOut = false;
         this.m_invite_bt.applyGrayOut = false;
         if(this.m_parentWindow.selectedTab == 0)
         {
            this.m_accept_bt.visible = false;
            this.m_decline_bt.visible = false;
            this.m_accept_bt.callback = null;
            this.m_decline_bt.callback = null;
            this.m_invite_bt.visible = true;
            this.m_invite_bt.callback = this.onInviteFriendClick;
         }
         else
         {
            this.m_accept_bt.visible = true;
            this.m_decline_bt.visible = true;
            this.m_accept_bt.callback = this.onAcceptClick;
            this.m_decline_bt.callback = this.onDeclineClick;
            this.m_invite_bt.visible = false;
            this.m_invite_bt.callback = null;
         }
         if(this.m_data.hasOwnProperty("isInvited") && this.m_data["isInvited"] == true)
         {
            this.checkmark_mc.visible = true;
            this.m_invite_bt.visible = false;
            this.m_invite_bt.callback = null;
         }
      }
      
      public function onInviteFriendClick(e:Event) : void
      {
         if(this.m_data.hasOwnProperty("playerId"))
         {
            GuildManager.getInstance().inviteFriends(this.m_data["playerId"]);
         }
         this.checkmark_mc.visible = true;
         this.m_invite_bt.visible = false;
         this.m_invite_bt.callback = null;
      }
      
      public function onAcceptClick(e:Event) : void
      {
         if(this.m_data.hasOwnProperty("playerId"))
         {
            GuildManager.getInstance().respondToJoinRequest(this.m_data["playerId"],"accept");
            this.m_accept_bt.applyGrayOut = true;
            this.m_decline_bt.visible = false;
         }
      }
      
      public function onDeclineClick(e:Event) : void
      {
         if(this.m_data.hasOwnProperty("playerId"))
         {
            GuildManager.getInstance().respondToJoinRequest(this.m_data["playerId"],"decline");
            this.m_decline_bt.applyGrayOut = true;
            this.m_accept_bt.visible = false;
         }
      }
      
      override public function clearView() : void
      {
         super.clearView();
         this.checkmark_mc.visible = false;
      }
   }
}

