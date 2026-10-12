package Widgets.Slots
{
   import Classes.util.FarmGameUtil;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuildListSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_total_cpoints_tf:ZwTextField;
      
      private var m_slotIndex:int;
      
      private var m_data:Object;
      
      private var m_des_tf:ZwTextField;
      
      private var m_name_tf:ZwTextField;
      
      private var m_join_request_tf:ZwTextField;
      
      private var m_members_tf:ZwTextField;
      
      private var m_hover_mc:MovieClip;
      
      private var m_highlight_mc:MovieClip;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_action_bt:FarmAnimatedTextButton;
      
      private var m_decline_bt:FarmAnimatedTextButton;
      
      private var m_view_bt:FarmAnimatedTextButton;
      
      private var m_id_tf:ZwTextField;
      
      private var m_coop_pointsIcon_mc:MovieClip;
      
      private var m_coop_pointsIconFrame:ZwFrame;
      
      private var m_coop_memberIcon_mc:MovieClip;
      
      private var m_coop_memberFrame:ZwFrame;
      
      private var m_privacy_tf:ZwTextField;
      
      public function GuildListSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         (m_element as MovieClip).visible = true;
         if(m_element.hasOwnProperty("total_cpoints_tf"))
         {
            addWidget(this.m_total_cpoints_tf = new ZwTextField(m_element["total_cpoints_tf"],"Total CP : "));
         }
         if(m_element.hasOwnProperty("privacy_tf"))
         {
            addWidget(this.m_privacy_tf = new ZwTextField(m_element["privacy_tf"],"InviteStatus"));
         }
         if(m_element.hasOwnProperty("des_tf"))
         {
            addWidget(this.m_des_tf = new ZwTextField(m_element["des_tf"],"description"));
         }
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_name_tf = new ZwTextField(m_element["name_tf"],""));
         }
         if(m_element.hasOwnProperty("join_request_tf"))
         {
            addWidget(this.m_join_request_tf = new ZwTextField(m_element["join_request_tf"],"join_request_tf"));
         }
         if(m_element.hasOwnProperty("id_tf"))
         {
            addWidget(this.m_id_tf = new ZwTextField(m_element["id_tf"],""));
         }
         if(m_element.hasOwnProperty("members_tf"))
         {
            addWidget(this.m_members_tf = new ZwTextField(m_element["members_tf"],"members_tf"));
         }
         if(m_element.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_element["accept_bt"],"Accept",this.onActionButtonClick));
            this.m_accept_bt.visible = false;
         }
         if(m_element.hasOwnProperty("action_bt"))
         {
            addWidget(this.m_action_bt = new FarmAnimatedTextButton(m_element["action_bt"],"Join",this.onActionButtonClick));
         }
         if(m_element.hasOwnProperty("decline_bt"))
         {
            addWidget(this.m_decline_bt = new FarmAnimatedTextButton(m_element["decline_bt"],"Decline",this.onDeclineButtonClick));
            this.m_decline_bt.visible = false;
         }
         if(m_element.hasOwnProperty("view_bt"))
         {
            addWidget(this.m_view_bt = new FarmAnimatedTextButton(m_element["view_bt"],"View",this.onViewButtonClick));
            this.m_view_bt.attachTooltip(new FarmTextTooltip("Click here to view clan and clan members details"));
         }
         if(m_element.hasOwnProperty("hover_mc"))
         {
            this.m_hover_mc = m_element["hover_mc"] as MovieClip;
            this.m_hover_mc.visible = true;
         }
         if(m_element.hasOwnProperty("highlight_mc"))
         {
            this.m_highlight_mc = m_element["highlight_mc"] as MovieClip;
            this.m_highlight_mc.visible = true;
         }
         if(m_element.hasOwnProperty("cpoints_icon_mc"))
         {
            this.m_coop_pointsIcon_mc = m_element["cpoints_icon_mc"] as MovieClip;
            this.m_coop_pointsIcon_mc.visible = true;
            this.m_coop_pointsIconFrame = new ZwFrame(this.m_coop_pointsIcon_mc);
            this.m_coop_pointsIconFrame.attachTooltip(new FarmTextTooltip("Total Stat Points"));
         }
         if(m_element.hasOwnProperty("member_icon_mc"))
         {
            this.m_coop_memberIcon_mc = m_element["member_icon_mc"] as MovieClip;
            this.m_coop_memberIcon_mc.visible = true;
            this.m_coop_memberFrame = new ZwFrame(this.m_coop_memberIcon_mc);
            this.m_coop_memberFrame.attachTooltip(new FarmTextTooltip("Number of Members"));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var inviteStatus:String = null;
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data.index;
         var icon:FarmIcon = new FarmIcon(m_element["icon_mc"] as MovieClip,this.m_data.logo);
         icon.setIconSize(50,50);
         icon.detachTooltip();
         icon.visible = true;
         if(this.m_data.hasOwnProperty("name"))
         {
            this.m_name_tf.text = this.m_data["name"];
            this.m_name_tf.visible = true;
         }
         if(this.m_data.hasOwnProperty("inviteStatus"))
         {
            inviteStatus = this.m_data["inviteStatus"];
            this.m_privacy_tf.text = inviteStatus == "OPEN" ? "Public" : "Private";
            this.m_privacy_tf.visible = true;
         }
         if(this.m_data.hasOwnProperty("description"))
         {
            this.m_des_tf.text = this.m_data.description;
            this.m_des_tf.visible = true;
         }
         if(this.m_data.hasOwnProperty("total_points") && Boolean(this.m_data["total_points"]))
         {
            this.m_total_cpoints_tf.text = this.m_data["total_points"].toString();
         }
         else
         {
            this.m_total_cpoints_tf.text = "0";
         }
         this.m_total_cpoints_tf.visible = true;
         if(this.m_data.hasOwnProperty("memberCount"))
         {
            this.m_members_tf.text = this.m_data.memberCount.toString() + "/10";
            this.m_members_tf.visible = true;
         }
         if(Boolean(this.m_id_tf) && this.m_data.hasOwnProperty("guildId"))
         {
            this.m_id_tf.text = this.m_data["guildId"];
            this.m_id_tf.visible = true;
            this.m_id_tf.attachTooltip(new FarmTextTooltip("Unique ID"));
         }
         this.m_highlight_mc.visible = false;
         this.m_hover_mc.visible = false;
         this.m_action_bt.enabled = true;
         this.hideAllButtons();
         if(GuildManager.getInstance().isGuildMember())
         {
            this.m_action_bt.enabled = false;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_action_bt,"Member can leave their clan and join another only when an event is not running");
            this.m_action_bt.callback = null;
         }
         if(this.m_data.hasOwnProperty("isInvited") && this.m_data["isInvited"] == true && this.m_data.hasOwnProperty("isInvitedByAdmin"))
         {
            this.m_action_bt.visible = false;
            this.m_accept_bt.visible = true;
            this.m_decline_bt.visible = true;
            this.m_highlight_mc.visible = true;
            this.m_view_bt.visible = true;
            this.m_des_tf.visible = false;
            if(this.m_data["isInvitedByAdmin"] == true)
            {
               this.m_accept_bt.text = "Accept";
               this.m_decline_bt.text = "Decline";
               if(this.m_data.hasOwnProperty("hostNames"))
               {
                  this.m_join_request_tf.visible = true;
                  this.m_join_request_tf.text = "Invited by " + this.m_data.hostNames;
               }
            }
            else
            {
               this.m_accept_bt.text = "Join";
               this.m_decline_bt.text = "Ignore";
               if(this.m_data.hasOwnProperty("hostNames"))
               {
                  this.m_join_request_tf.visible = true;
                  this.m_join_request_tf.text = "Suggested by " + this.m_data.hostNames;
               }
            }
            if(GuildManager.getInstance().isGuildMember())
            {
               this.m_accept_bt.enabled = false;
            }
            m_element.removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            m_element.removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
         else
         {
            m_element.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            m_element.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
         if(this.m_data["guildId"] == GuildManager.getInstance().getGuildId())
         {
            this.hideAllButtons();
            this.m_view_bt.visible = true;
         }
         else if(this.m_data.memberCount == 10)
         {
            if(this.m_accept_bt.enabled && this.m_accept_bt.visible)
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_accept_bt,"Clan is full");
            }
            if(this.m_action_bt.enabled && this.m_action_bt.visible)
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_action_bt,"Clan is full");
            }
            this.m_view_bt.visible = true;
         }
      }
      
      public function onActionButtonClick(e:Event) : void
      {
         GuildManager.getInstance().sendJoinRequest(this.m_data.guildId,this.m_data.isInvited);
         if(this.m_accept_bt)
         {
            this.m_accept_bt.text = "Requested";
            this.m_accept_bt.enabled = false;
         }
         if(this.m_action_bt)
         {
            this.m_action_bt.text = "Requested";
            this.m_action_bt.enabled = false;
         }
      }
      
      public function onViewButtonClick(e:Event) : void
      {
         if(this.m_data["guildId"] == GuildManager.getInstance().getGuildId())
         {
            GuildManager.getInstance().openGuildViewWindow();
         }
         else
         {
            GuildManager.getInstance().viewOtherGuildDetail(this.m_data["guildId"]);
         }
      }
      
      public function onDeclineButtonClick(e:Event) : void
      {
         GuildManager.getInstance().rejectJoinRequest(this.m_data["guildId"]);
      }
      
      override public function release() : void
      {
         if(m_element)
         {
            m_element.removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            m_element.removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
         super.release();
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         if(this.m_hover_mc)
         {
            this.m_hover_mc.visible = true;
            this.m_view_bt.visible = true;
            this.showActionButtons();
            this.m_des_tf.visible = false;
         }
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
         if(this.m_hover_mc)
         {
            this.m_hover_mc.visible = false;
            this.m_view_bt.visible = false;
            this.hideAllButtons();
            this.m_des_tf.visible = true;
         }
      }
      
      public function hideAllButtons() : void
      {
         this.m_action_bt.visible = false;
         this.m_view_bt.visible = false;
         this.m_accept_bt.visible = false;
         this.m_decline_bt.visible = false;
      }
      
      public function showActionButtons() : void
      {
         if(GuildManager.getInstance().isGuildAlreadyRequested(this.m_data.guildId))
         {
            this.m_action_bt.text = "Requested";
            this.m_action_bt.enabled = false;
            this.m_action_bt.visible = true;
         }
         else if(!(this.m_data.hasOwnProperty("isInvited") && this.m_data["isInvited"] == true))
         {
            this.m_action_bt.text = "Join";
            this.m_action_bt.visible = true;
         }
         if(this.m_data["guildId"] == GuildManager.getInstance().getGuildId())
         {
            this.hideAllButtons();
            this.m_view_bt.visible = true;
         }
      }
   }
}

