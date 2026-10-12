package Widgets.Windows
{
   import Classes.util.FarmGameUtil;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildMembersFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.desktop.Clipboard;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.System;
   
   public class GuildViewWindow extends FarmWindow
   {
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "FVGuild";
      
      private var m_featureName:String = null;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_guildInfo:Object = null;
      
      private var m_coop_mc:MovieClip;
      
      private var m_coop_desciption_tf:ZwTextField;
      
      private var m_coop_members_tf:ZwTextField;
      
      private var m_coop_name_tf:ZwTextField;
      
      private var m_coop_total_cpoints_tf:ZwTextField;
      
      private var m_coop_icon_mc:FarmIcon;
      
      private var m_coop_edit_button:FarmAnimatedTextButton;
      
      private var m_coop_add_button:FarmAnimatedTextButton;
      
      private var m_coop_leave_button:FarmAnimatedTextButton;
      
      private var m_privacy_tf:ZwTextField;
      
      private var m_uid_tf:ZwTextField;
      
      private var m_membersFrame:GuildMembersFrame;
      
      private var m_otherGuildView:Boolean;
      
      private var m_approve_request_tf:ZwTextField;
      
      private var m_copy_guildId_button:FarmAnimatedTextButton;
      
      private var m_copy_mc:MovieClip;
      
      private var m_titleText:ZwTextField;
      
      public const GUILD_DETAIL_WINDOW_FTUE_SEEN_FLAG:String = "GuildDetailWindowFTUESeenflag";
      
      private var m_npcAutoMc:MovieClip;
      
      private var m_npcAutoTalkMc:MovieClip;
      
      private var m_npcAuto1Tf:ZwTextField;
      
      private var m_npcAuto2Tf:ZwTextField;
      
      private var m_coop_pointsIcon_mc:MovieClip;
      
      private var m_coop_pointsIconFrame:ZwFrame;
      
      private var m_coop_memberIcon_mc:MovieClip;
      
      private var m_coop_memberFrame:ZwFrame;
      
      private var m_join_req_tf:ZwTextField;
      
      public function GuildViewWindow(featureName:String, assetUrl:String, result:Object, otherGuild:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_guildInfo = result;
         this.m_otherGuildView = otherGuild;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var logoPath:String = null;
         var pendoingApprovalCount:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(this.m_titleText = new ZwTextField(m_window[this.TITLE_TF],""));
            if(this.m_otherGuildView)
            {
               this.m_titleText.text = this.m_guildInfo["name"];
            }
            else
            {
               this.m_titleText.text = "Your Clan";
            }
         }
         if(m_window.hasOwnProperty("coop_mc"))
         {
            this.m_coop_mc = m_window["coop_mc"] as MovieClip;
            this.m_coop_mc.visible = true;
            if(this.m_coop_mc)
            {
               if(this.m_coop_mc.hasOwnProperty("cpoints_icon_mc"))
               {
                  this.m_coop_pointsIcon_mc = this.m_coop_mc["cpoints_icon_mc"] as MovieClip;
                  this.m_coop_pointsIcon_mc.visible = true;
                  this.m_coop_pointsIconFrame = new ZwFrame(this.m_coop_pointsIcon_mc);
                  this.m_coop_pointsIconFrame.attachTooltip(new FarmTextTooltip("Total Stat Points"));
               }
               if(this.m_coop_mc.hasOwnProperty("member_icon_mc"))
               {
                  this.m_coop_memberIcon_mc = this.m_coop_mc["member_icon_mc"] as MovieClip;
                  this.m_coop_memberIcon_mc.visible = true;
                  this.m_coop_memberFrame = new ZwFrame(this.m_coop_memberIcon_mc);
                  this.m_coop_memberFrame.attachTooltip(new FarmTextTooltip("Number of Members"));
               }
               this.m_coop_desciption_tf = new ZwTextField(this.m_coop_mc["des_tf"],"des_tf");
               this.m_coop_desciption_tf.visible = true;
               this.m_coop_desciption_tf.text = this.m_guildInfo["description"];
               this.m_privacy_tf = new ZwTextField(this.m_coop_mc["privacy_tf"],"privacy_tf");
               this.m_privacy_tf.visible = true;
               this.m_privacy_tf.text = this.m_guildInfo["inviteStatus"] == "OPEN" ? "Public" : "Private";
               this.m_uid_tf = new ZwTextField(this.m_coop_mc["uid_tf"],"uid_tf");
               this.m_uid_tf.visible = true;
               this.m_uid_tf.text = "Unique Id : " + this.m_guildInfo["guildId"];
               this.m_approve_request_tf = new ZwTextField(this.m_coop_mc["approve_request_tf"],"");
               this.m_approve_request_tf.visible = true;
               if(this.m_otherGuildView == false)
               {
                  pendoingApprovalCount = GuildManager.getInstance().getJoinRequestsCount();
                  if(pendoingApprovalCount > 0)
                  {
                     this.m_approve_request_tf.text = pendoingApprovalCount.toString() + " approvals pending";
                  }
               }
               this.m_coop_members_tf = new ZwTextField(this.m_coop_mc["members_tf"],"members_tf");
               this.m_coop_members_tf.visible = true;
               this.m_coop_members_tf.text = this.m_guildInfo["memberCount"].toString() + "/10";
               this.m_coop_name_tf = new ZwTextField(this.m_coop_mc["name_tf"],"name_tf");
               this.m_coop_name_tf.visible = true;
               this.m_coop_name_tf.text = this.m_guildInfo["name"];
               this.m_coop_total_cpoints_tf = new ZwTextField(this.m_coop_mc["total_cpoints_tf"],"total_cpoints_tf");
               this.m_coop_total_cpoints_tf.visible = true;
               if(this.m_guildInfo["guildPoints"])
               {
                  this.m_coop_total_cpoints_tf.text = this.m_guildInfo["guildPoints"].toString();
               }
               else
               {
                  this.m_coop_total_cpoints_tf.text = "0";
               }
               logoPath = GuildManager.GUILD_LOGO_IMAGE_ARRAY[int(this.m_guildInfo["alias"]) + 1];
               this.m_coop_icon_mc = new FarmIcon(this.m_coop_mc["icon_mc"],logoPath);
               this.m_coop_icon_mc.setIconSize(100,100);
               this.m_coop_icon_mc.detachTooltip();
               this.m_coop_icon_mc.visible = true;
               addWidget(this.m_coop_edit_button = new FarmAnimatedTextButton(this.m_coop_mc["edit_bt"],"",null));
               addWidget(this.m_copy_guildId_button = new FarmAnimatedTextButton(this.m_coop_mc["copyID_bt"],"Copy",this.onCopyGuildId));
               this.m_copy_guildId_button.attachTooltip(new FarmTextTooltip("Copy unique clan ID. Your friends can use this to find your clan."));
               this.m_copy_mc = this.m_coop_mc["copyID_bt"] as MovieClip;
               this.m_copy_mc.addEventListener(MouseEvent.ROLL_OUT,this.onCopyButtonMouseOver);
               if(!this.m_otherGuildView)
               {
                  this.m_coop_edit_button.text = "Edit Details";
                  if(GuildManager.getInstance().isLeader())
                  {
                     this.m_coop_edit_button.callback = this.onCoopEditClick;
                  }
                  else
                  {
                     this.m_coop_edit_button.applyGrayOut = true;
                     this.m_coop_edit_button.attachTooltip(new FarmTextTooltip("Require Admin Access"));
                     this.m_coop_edit_button.callback = null;
                  }
               }
               else if(GuildManager.getInstance().isGuildAlreadyRequested(this.m_guildInfo["guildId"]))
               {
                  this.m_coop_edit_button.text = "Request Sent";
                  this.m_coop_edit_button.enabled = false;
                  this.m_coop_edit_button.callback = null;
               }
               else
               {
                  this.m_coop_edit_button.text = "Join Clan";
                  if(GuildManager.getInstance().isGuildMember())
                  {
                     this.m_coop_edit_button.enabled = false;
                     this.m_coop_edit_button.applyGrayOut = true;
                     this.m_coop_edit_button.callback = null;
                  }
                  else
                  {
                     this.m_coop_edit_button.callback = this.onJoinGuild;
                  }
               }
               addWidget(this.m_coop_add_button = new FarmAnimatedTextButton(this.m_coop_mc["add_bt"],"Add Members",this.onCoopAddMembersClick));
               addWidget(this.m_coop_leave_button = new FarmAnimatedTextButton(this.m_coop_mc["leave_bt"],"Leave Clan",this.onLeaveCoopClick));
               if(GuildEventManager.isEventOver() == false && GuildEventManager.getInstance().hasUserStartedCurrentEvent())
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_coop_leave_button,"Leaving your clan is not permitted while an event is active");
                  this.m_coop_leave_button.callback = null;
               }
               if(this.m_coop_mc.hasOwnProperty("join_request_tf"))
               {
                  this.m_join_req_tf = new ZwTextField(this.m_coop_mc["join_request_tf"],"");
                  this.m_join_req_tf.visible = false;
               }
               if(GuildMainWindow.m_FTUEState == 3)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_coop_leave_button,"Please complete the tutorial to activate this button");
                  this.m_coop_leave_button.callback = null;
               }
               if(this.m_otherGuildView)
               {
                  this.m_coop_add_button.visible = false;
                  this.m_coop_leave_button.visible = false;
               }
            }
            if(m_window.hasOwnProperty("members_mc"))
            {
               this.m_membersFrame = new GuildMembersFrame(m_window["members_mc"],this.m_featureName,this.m_otherGuildView);
               if(this.m_otherGuildView)
               {
                  this.m_membersFrame.setupSlotData(this.m_guildInfo.membersData);
                  this.m_membersFrame.refresh();
               }
               this.m_membersFrame.visible = true;
            }
         }
         if(m_window.hasOwnProperty("npc_auto_mc"))
         {
            this.m_npcAutoMc = m_window.npc_auto_mc as MovieClip;
            this.m_npcAutoMc.visible = false;
            if(this.m_npcAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_npcAutoTalkMc = this.m_npcAutoMc.talk_mc as MovieClip;
               this.m_npcAutoTalkMc.visible = true;
               this.m_npcAuto1Tf = new ZwTextField(this.m_npcAutoTalkMc["npc1_tf"]," Auto npc1");
               this.m_npcAuto2Tf = new ZwTextField(this.m_npcAutoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(!Global.player.getSeenFlag(this.GUILD_DETAIL_WINDOW_FTUE_SEEN_FLAG) && this.m_otherGuildView == false)
         {
            this.showAutoHideNPCCallouts("Rock & Role!","See your clan details here along with the roles of your clan friends like Leader, Co-Leader, General & Member.");
            Global.player.setSeenFlag(this.GUILD_DETAIL_WINDOW_FTUE_SEEN_FLAG);
         }
      }
      
      public function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_npcAuto1Tf.text = title;
         this.m_npcAuto2Tf.text = text;
         this.m_npcAutoMc.visible = true;
         this.m_npcAutoMc.gotoAndPlay(1);
      }
      
      public function onCopyGuildId(e:Event) : void
      {
         Clipboard.generalClipboard.clear();
         System.setClipboard(this.m_guildInfo["guildId"]);
         this.m_copy_guildId_button.text = "Copied";
      }
      
      public function onCopyButtonMouseOver(e:MouseEvent) : void
      {
         this.m_copy_guildId_button.text = "Copy";
      }
      
      public function onJoinGuild(e:Event) : void
      {
         GuildManager.getInstance().sendJoinRequest(this.m_guildInfo["guildId"],true);
         if(this.m_otherGuildView && Boolean(this.m_coop_edit_button))
         {
            this.m_coop_edit_button.text = "Requested";
            this.m_coop_edit_button.enabled = false;
         }
      }
      
      public function onCoopEditClick(e:Event) : void
      {
         GuildManager.getInstance().openGuildEditWindow();
      }
      
      public function onCoopAddMembersClick(e:Event) : void
      {
         GuildManager.getInstance().openGuildAddMembersWindow();
      }
      
      private function onConfirmLeaveGuild(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            GuildManager.getInstance().leaveGuild();
         }
      }
      
      public function onLeaveCoopClick(e:Event) : void
      {
         var message:String = "Are you sure you want to leave this clan?";
         UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmLeaveGuild,"",true);
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         this.m_membersFrame.refresh();
      }
      
      public function isOtherGuildView() : Boolean
      {
         return this.m_otherGuildView;
      }
      
      override public function close() : void
      {
         super.close();
         GuildManager.getInstance().m_guildViewWindow = null;
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         if(this.m_otherGuildView)
         {
            GuildManager.getInstance().openGuildListWindow();
         }
         else
         {
            GuildManager.getInstance().showUI();
         }
      }
   }
}

