package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildConsumableSlotContainerFrame;
   import Widgets.Frames.GuildKeyRequestFrame;
   import Widgets.Frames.GuildMembersStatuSlotFrame;
   import Widgets.Frames.GuildMessageFrame;
   import Widgets.Frames.TabMenu;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import mx.utils.StringUtil;
   
   public class GuildMainWindow extends FarmWindow
   {
      
      private static const coopXML:Class = GuildMainWindow_coopXML;
      
      public static const featureXML:XML = XML(new coopXML());
      
      public static const ICON_SIZE:int = 50;
      
      public static var m_FTUEState:int = 1;
      
      private static const WINDOW_PREFIX:String = "guild_main_";
      
      public static const GUILD_MAIN_WINDOW_FTUE_SEEN_FLAG:String = "GUILD_MAIN_WINDOW_FTUE_SEEN_FLAG";
      
      public static const GUILD_HELP_KEY_FTUE_SEEN_FLAG:String = "GUILD_HELP_KEY_FTUE_SEEN_FLAG";
      
      public static const GUILD_RECEIVED_HELP_KEY_FTUE_SEEN_FLAG:String = "GUILD_RECEIVED_HELP_KEY_FTUE_SEEN_FLAG";
      
      private var m_featureName:String = null;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_consumable_mc:MovieClip;
      
      private var m_count_tf:ZwTextField;
      
      private var m_collect_tf:ZwTextField;
      
      private var m_ask_tf:ZwTextField;
      
      private var m_marketing_mc:MovieClip;
      
      private var m_banner_mc:MovieClip;
      
      private var m_tabs_mc:MovieClip;
      
      private var m_tab0Content_mc:MovieClip;
      
      private var m_tab1Content_mc:MovieClip;
      
      private var m_coop_mc:MovieClip;
      
      private var m_cpoints_tf:ZwTextField;
      
      private var m_coop_desciption_tf:ZwTextField;
      
      private var m_coop_join_request_tf:ZwTextField;
      
      private var m_coop_members_tf:ZwTextField;
      
      private var m_coop_name_tf:ZwTextField;
      
      private var m_coop_other_tf:ZwTextField;
      
      private var m_coop_role_tf:ZwTextField;
      
      private var m_coop_total_cpoints_tf:ZwTextField;
      
      private var m_consumable_icon_mc:MovieClip;
      
      private var m_coop_icon_mc:FarmIcon;
      
      private var m_coop_browse_button:FarmAnimatedTextButton;
      
      private var m_coop_view_button:FarmAnimatedTextButton;
      
      private var m_guildInfo:Object = null;
      
      private var m_requests_mc:MovieClip = null;
      
      private var m_npc1Mc:MovieClip;
      
      private var m_npc2Mc:MovieClip;
      
      private var m_npcAutoMc:MovieClip;
      
      private var m_npc1TalkMc:MovieClip;
      
      private var m_npc2TalkMc:MovieClip;
      
      private var m_npcAutoTalkMc:MovieClip;
      
      private var m_npc1Tf1:ZwTextField;
      
      private var m_npc1Tf2:ZwTextField;
      
      private var m_npc2Tf1:ZwTextField;
      
      private var m_npc2Tf2:ZwTextField;
      
      private var m_npcAuto1Tf:ZwTextField;
      
      private var m_npcAuto2Tf:ZwTextField;
      
      private var m_consumable_tf:ZwTextField;
      
      private var m_keyIcon:FarmIcon;
      
      private var m_requestFrameHelp_tf:ZwTextField;
      
      private var m_requestFrame:GuildKeyRequestFrame;
      
      private var m_tabMenu:TabMenu;
      
      private var m_input_tf:ZwTextField;
      
      private var m_sendMessage_bt:FarmAnimatedTextButton;
      
      public var m_consumableSlotFrame:GuildConsumableSlotContainerFrame;
      
      public var m_sentMessageFrame:GuildMessageFrame;
      
      public var m_notificationsFrame:GuildMessageFrame;
      
      public var m_receivedMessageFrame:GuildMessageFrame;
      
      private var m_guildEventEntryButton:FarmAnimatedTextButton;
      
      private var m_points_dooberMc:MovieClip;
      
      private var m_points_dooberIconMc:MovieClip;
      
      private var m_points_dooberCountTf:ZwTextField;
      
      private var m_chatMark:MovieClip;
      
      private var m_notifMark:MovieClip;
      
      private var m_membersStatusFrame:GuildMembersStatuSlotFrame;
      
      private var m_consumable_dooberMc:MovieClip;
      
      private var m_consumable_dooberIconMc:MovieClip;
      
      private var m_consumable_dooberCountTf:ZwTextField;
      
      private var m_approve_request_tf:ZwTextField;
      
      private var m_tutorialMc:MovieClip;
      
      private var m_okay1Bt:FarmAnimatedTextButton;
      
      private var m_okay2Bt:FarmAnimatedTextButton;
      
      public var m_closeBt:SimpleButton;
      
      private var m_marketing_tf:ZwTextField;
      
      private var m_prereq_tf:ZwTextField;
      
      private var m_status_tf:ZwTextField;
      
      public var m_askGuildKey:FarmAnimatedTextButton;
      
      private var m_craftBt:FarmAnimatedTextButton;
      
      public var m_requestFrameDefault_tf:ZwTextField;
      
      private var m_coop_pointsIcon_mc:MovieClip;
      
      private var m_coop_pointsIconFrame:ZwFrame;
      
      private var m_coop_memberIcon_mc:MovieClip;
      
      private var m_coop_memberFrame:ZwFrame;
      
      private var m_rankicon_mc:MovieClip;
      
      private var m_input_mc:*;
      
      private var m_timer:Timer;
      
      public var m_overlayMC:MovieClip;
      
      private var m_messageLoader_mc:MovieClip;
      
      public function GuildMainWindow(featureName:String, assetUrl:String, result:Object)
      {
         this.m_featureName = featureName;
         this.m_guildInfo = result;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var consumableItem:FarmItem = null;
         var bannerIcon:FarmIcon = null;
         var role:String = null;
         var pendoingApprovalCount:int = 0;
         var requestCount:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "title")));
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            this.m_closeBt = m_window.close_bt;
            this.m_closeBt.enabled = true;
            this.m_closeBt.visible = true;
         }
         if(m_window.hasOwnProperty("consumable_mc"))
         {
            this.m_consumable_mc = m_window["consumable_mc"] as MovieClip;
            this.m_consumable_mc.visible = true;
            if(this.m_consumable_mc)
            {
               consumableItem = Global.farmGameSettingsManager.getFarmItemByName("clantoken");
               this.populateConsumables();
               this.m_keyIcon = new FarmIcon(this.m_consumable_mc["icon_mc"],consumableItem.iconUrl);
               this.m_keyIcon.attachTooltip(new FarmTextTooltip(consumableItem.friendlyTitle));
               this.m_keyIcon.setIconSize(70,70);
               this.m_keyIcon.setSmoothing(true);
               addWidget(this.m_keyIcon,true);
               addWidget(this.m_count_tf = new ZwTextField(this.m_consumable_mc["count_tf"]));
               this.m_count_tf.visible = true;
               this.m_count_tf.text = GuildManager.getInstance().getKeyCount().toString();
               addWidget(this.m_consumable_tf = new ZwTextField(this.m_consumable_mc["consumable_tf"]));
               this.m_consumable_tf.visible = true;
               this.m_consumable_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "consumable_title");
               addWidget(this.m_collect_tf = new ZwTextField(this.m_consumable_mc["collect_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "consumable_subtitle")));
               this.m_collect_tf.visible = true;
               addWidget(this.m_ask_tf = new ZwTextField(this.m_consumable_mc["ask_tf"],"Requested : "));
               this.m_ask_tf.visible = true;
               this.m_ask_tf.text = "Requested: " + GuildManager.getInstance().getRequestedKeyCount().toString() + "/" + GuildManager.MAX_REQUESTED_GUILD_KEY_CAP.toString();
               this.m_consumable_icon_mc = this.m_consumable_mc["icon_mc"] as MovieClip;
               this.m_consumable_icon_mc.visible = true;
               addWidget(this.m_askGuildKey = new FarmAnimatedTextButton(this.m_consumable_mc["ask_bt"],"Request",this.onAskClick));
               if(GuildManager.getInstance().canAskForGuildKeys() == false)
               {
                  this.m_askGuildKey.applyGrayOut = true;
                  this.m_askGuildKey.callback = null;
               }
               addWidget(this.m_craftBt = new FarmAnimatedTextButton(this.m_consumable_mc["craft_bt"],"Craft",this.onCraftClick));
               if(GuildManager.getInstance().hasGuildKeyCapReached())
               {
                  this.m_craftBt.callback = null;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_craftBt,"Your token inventory is full");
               }
               if(this.m_consumable_mc.hasOwnProperty("doober_mc"))
               {
                  this.m_consumable_dooberMc = this.m_consumable_mc["doober_mc"] as MovieClip;
                  if(this.m_consumable_dooberMc.hasOwnProperty("dooberIcon_mc"))
                  {
                     this.m_consumable_dooberIconMc = this.m_consumable_dooberMc["dooberIcon_mc"];
                     if(this.m_consumable_dooberIconMc.hasOwnProperty("dooberCount_tf"))
                     {
                        this.m_consumable_dooberCountTf = new ZwTextField(this.m_consumable_dooberIconMc["dooberCount_tf"]);
                     }
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("marketing_mc"))
         {
            this.m_marketing_mc = m_window["marketing_mc"] as MovieClip;
            this.m_marketing_mc.visible = true;
            if(this.m_marketing_mc)
            {
               this.m_banner_mc = this.m_marketing_mc["banner_mc"] as MovieClip;
               addWidget(this.m_guildEventEntryButton = new FarmAnimatedTextButton(this.m_marketing_mc["okay_bt"],"Coming Soon",null));
               bannerIcon = new FarmIcon(this.m_banner_mc,Global.flashHotParams["GUILD_WELCOME_WINDOW_FEATURE_BANNER"]);
               bannerIcon.visible = true;
               bannerIcon.setIconSize(400,300);
               this.m_membersStatusFrame = new GuildMembersStatuSlotFrame(this.m_marketing_mc["status_mc"],this.m_featureName);
               addWidget(this.m_marketing_tf = new ZwTextField(this.m_marketing_mc["marketing_tf"]));
               this.m_marketing_tf.visible = true;
               this.m_marketing_tf.text = HUD.getformattedTimeLeft(GuildEventManager.getTimeLeftForEventStart()) + " Remaining";
               addWidget(this.m_prereq_tf = new ZwTextField(this.m_marketing_mc["prereq_tf"]));
               this.m_prereq_tf.visible = true;
               this.m_prereq_tf.text = "Use " + GuildEventManager.getInstance().getKeysRequiredForCurrentEvent().toString() + " tokens to embark on an adventure!";
               addWidget(this.m_status_tf = new ZwTextField(this.m_marketing_mc["status_tf"]));
               this.m_status_tf.visible = true;
               this.m_status_tf.text = GuildManager.getInstance().getGuildeventJoinedMembersCount().toString() + "/" + GuildManager.getInstance().guildMembersCount().toString() + " already joined";
               this.refreshGuildEventEntryButton();
            }
         }
         if(m_window.hasOwnProperty("tabs_mc"))
         {
            this.m_tabs_mc = m_window["tabs_mc"] as MovieClip;
            this.m_messageLoader_mc = this.m_tabs_mc["loader_mc"];
            if(this.m_tabs_mc)
            {
               this.m_tabs_mc.visible = true;
               if(this.m_tabs_mc.hasOwnProperty("mark0_mc"))
               {
                  this.m_chatMark = this.m_tabs_mc["mark0_mc"] as MovieClip;
                  this.m_chatMark.visible = false;
               }
               if(this.m_tabs_mc.hasOwnProperty("mark1_mc"))
               {
                  this.m_notifMark = this.m_tabs_mc["mark1_mc"] as MovieClip;
                  this.m_notifMark.visible = false;
               }
               this.m_tab0Content_mc = this.m_tabs_mc["tab0_content_mc"] as MovieClip;
               this.m_tab0Content_mc.visible = true;
               if(this.m_tab0Content_mc.hasOwnProperty("input_tf"))
               {
                  this.m_input_tf = new ZwTextField(this.m_tab0Content_mc["input_tf"],"");
                  this.m_input_tf.visible = true;
                  this.m_input_mc = this.m_tab0Content_mc["input_tf"];
                  this.m_input_mc.addEventListener(MouseEvent.CLICK,this.onChatInputBoxClick);
                  this.m_input_mc.addEventListener(KeyboardEvent.KEY_UP,this.checkMessageLength);
               }
               addWidget(this.m_sendMessage_bt = new FarmAnimatedTextButton(this.m_tab0Content_mc["send_bt"],"Send",this.onSendChatMessageButtonClick));
               this.m_sentMessageFrame = new GuildMessageFrame(this.m_tabs_mc["tab0_content_mc"],this.m_featureName,"sent",this);
               this.m_sentMessageFrame.visible = true;
               this.m_receivedMessageFrame = new GuildMessageFrame(this.m_tabs_mc["tab0_content_mc"],this.m_featureName,"received",this);
               this.m_receivedMessageFrame.visible = true;
               this.m_notificationsFrame = new GuildMessageFrame(this.m_tabs_mc["tab1_content_mc"],this.m_featureName,"feed",this);
               this.m_notificationsFrame.visible = true;
               this.m_tab1Content_mc = this.m_tabs_mc["tab1_content_mc"] as MovieClip;
               this.m_tab1Content_mc.visible = false;
            }
            this.m_tabMenu = new TabMenu(m_window["tabs_mc"],2,0,this.onTabClick,"tab_","_mc");
         }
         if(m_window.hasOwnProperty("npc1_mc"))
         {
            this.m_npc1Mc = m_window.npc1_mc as MovieClip;
            this.m_npc1Mc.visible = false;
            this.m_npc1Mc.play();
            if(this.m_npc1Mc.hasOwnProperty("talk_mc"))
            {
               this.m_npc1TalkMc = this.m_npc1Mc.talk_mc as MovieClip;
               this.m_npc1TalkMc.visible = true;
               this.m_npc1Tf1 = new ZwTextField(this.m_npc1TalkMc["npc1_tf"]," Auto npc1");
               this.m_npc1Tf2 = new ZwTextField(this.m_npc1TalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(m_window.hasOwnProperty("npc2_mc"))
         {
            this.m_npc2Mc = m_window.npc2_mc as MovieClip;
            this.m_npc2Mc.visible = false;
            this.m_npc2Mc.play();
            if(this.m_npc2Mc.hasOwnProperty("talk_mc"))
            {
               this.m_npc2TalkMc = this.m_npc2Mc.talk_mc as MovieClip;
               this.m_npc2TalkMc.visible = true;
               this.m_npc2Tf1 = new ZwTextField(this.m_npc2TalkMc["npc1_tf"]," Auto npc2");
               this.m_npc2Tf2 = new ZwTextField(this.m_npc2TalkMc["npc2_tf"],"Auto Default NPC Text");
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
               this.m_cpoints_tf = new ZwTextField(this.m_coop_mc["cpoints_tf"],"cpoints_tf");
               this.m_cpoints_tf.visible = true;
               this.m_cpoints_tf.text = "Your Stat Points: " + GuildManager.getInstance().getUserPoints().toString();
               this.m_coop_desciption_tf = new ZwTextField(this.m_coop_mc["des_tf"],"des_tf");
               this.m_coop_desciption_tf.visible = true;
               this.m_coop_desciption_tf.text = this.m_guildInfo["description"];
               this.m_coop_join_request_tf = new ZwTextField(this.m_coop_mc["join_request_tf"],"");
               this.m_coop_join_request_tf.visible = true;
               this.m_coop_join_request_tf.text = GuildManager.getInstance().getOtherRequestText();
               this.m_coop_members_tf = new ZwTextField(this.m_coop_mc["members_tf"],"members_tf");
               this.m_coop_members_tf.visible = true;
               this.m_coop_members_tf.text = this.m_guildInfo["memberCount"].toString() + "/10";
               this.m_coop_name_tf = new ZwTextField(this.m_coop_mc["name_tf"],"name_tf");
               this.m_coop_name_tf.visible = true;
               this.m_coop_name_tf.text = this.m_guildInfo["name"];
               this.m_coop_other_tf = new ZwTextField(this.m_coop_mc["other_tf"],"Other Clans");
               this.m_coop_other_tf.visible = true;
               this.m_coop_role_tf = new ZwTextField(this.m_coop_mc["role_tf"],"role_tf");
               this.m_coop_role_tf.visible = true;
               if(this.m_coop_mc.hasOwnProperty("rankicon_mc"))
               {
                  this.m_rankicon_mc = this.m_coop_mc["rankicon_mc"] as MovieClip;
                  this.m_rankicon_mc.visible = true;
               }
               role = "Member";
               if(this.m_guildInfo["role"] == "Owner")
               {
                  role = "Leader";
                  this.m_rankicon_mc.gotoAndStop(1);
               }
               else if(this.m_guildInfo["role"] == "Leader")
               {
                  role = "Co-Leader";
                  this.m_rankicon_mc.gotoAndStop(2);
               }
               else if(this.m_guildInfo["role"] == "Elder")
               {
                  role = "General";
                  this.m_rankicon_mc.gotoAndStop(3);
               }
               else
               {
                  role = "Member";
                  this.m_rankicon_mc.gotoAndStop(4);
               }
               this.m_coop_role_tf.text = role;
               this.m_coop_total_cpoints_tf = new ZwTextField(this.m_coop_mc["total_cpoints_tf"],"total_cpoints_tf");
               this.m_coop_total_cpoints_tf.visible = true;
               this.m_coop_total_cpoints_tf.text = GuildManager.getInstance().getGuildtotalPoints().toString();
               this.m_coop_icon_mc = new FarmIcon(this.m_coop_mc["icon_mc"],GuildManager.GUILD_LOGO_IMAGE_ARRAY[int(this.m_guildInfo["alias"]) + 1]);
               this.m_coop_icon_mc.visible = true;
               this.m_approve_request_tf = new ZwTextField(this.m_coop_mc["approve_request_tf"],"");
               this.m_approve_request_tf.visible = true;
               pendoingApprovalCount = GuildManager.getInstance().getJoinRequestsCount();
               if(pendoingApprovalCount > 0 && role != "Member")
               {
                  this.m_approve_request_tf.text = pendoingApprovalCount.toString() + " approvals pending";
               }
               addWidget(this.m_coop_browse_button = new FarmAnimatedTextButton(this.m_coop_mc["browse_bt"],"Browse",this.onCoopBrowseClick));
               this.m_coop_browse_button.attachTooltip(new FarmTextTooltip("Click here to see other clans and their details"));
               addWidget(this.m_coop_view_button = new FarmAnimatedTextButton(this.m_coop_mc["view_bt"],"View My Clan",this.onCoopViewClick));
               if(this.m_coop_mc.hasOwnProperty("doober_mc"))
               {
                  this.m_points_dooberMc = this.m_coop_mc["doober_mc"] as MovieClip;
                  if(this.m_points_dooberMc.hasOwnProperty("dooberIcon_mc"))
                  {
                     this.m_points_dooberIconMc = this.m_points_dooberMc["dooberIcon_mc"];
                     if(this.m_points_dooberIconMc.hasOwnProperty("dooberCount_tf"))
                     {
                        this.m_points_dooberCountTf = new ZwTextField(this.m_points_dooberIconMc["dooberCount_tf"]);
                     }
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("requests_mc"))
         {
            this.m_requests_mc = m_window["requests_mc"];
            this.m_requests_mc.visible = true;
            this.m_requestFrameHelp_tf = new ZwTextField(this.m_requests_mc["help_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "help_title"));
            this.m_requestFrameHelp_tf.visible = true;
            this.m_requestFrameDefault_tf = new ZwTextField(this.m_requests_mc["default_tf"],"Help requests from your clan members will appear here. Help them to earn Stat Points.");
            this.m_requestFrameDefault_tf.visible = false;
            this.m_requestFrame = new GuildKeyRequestFrame(this.m_requests_mc["request_slots_mc"],this.m_featureName);
            this.m_requestFrame.visible = false;
            requestCount = int(GuildManager.getInstance().getKeyRequestData().length);
            if(requestCount > 0)
            {
               this.m_requestFrameDefault_tf.visible = false;
               this.m_requestFrame.visible = true;
            }
            else
            {
               this.m_requestFrameDefault_tf.visible = true;
               this.m_requestFrame.visible = false;
            }
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            this.m_tutorialMc = m_window["tutorial_mc"] as MovieClip;
            if(this.m_tutorialMc.hasOwnProperty("okay1_bt"))
            {
               this.m_okay1Bt = new FarmAnimatedTextButton(this.m_tutorialMc["okay1_bt"],"Okay",this.onOkayButtonClick);
            }
            if(this.m_tutorialMc.hasOwnProperty("okay2_bt"))
            {
               this.m_okay2Bt = new FarmAnimatedTextButton(this.m_tutorialMc["okay2_bt"],"Okay",this.onOkayButtonClick);
            }
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlayMC = m_window["overlay_mc"] as MovieClip;
            this.m_overlayMC.visible = false;
         }
         this.m_sentMessageFrame.refresh();
         this.m_receivedMessageFrame.refresh();
         if(!Global.player.getSeenFlag(GUILD_MAIN_WINDOW_FTUE_SEEN_FLAG))
         {
            this.resumeFTUEFlow();
         }
         else if(!Global.player.getSeenFlag(GUILD_HELP_KEY_FTUE_SEEN_FLAG) && requestCount > 0 && GuildManager.getInstance().getKeyCount() > 0)
         {
            this.showAutoHideNPCCallouts("Helping Hand!","Help your clan members out by completing their request. Remember, every token you give, goes from your inventory!");
            Global.player.setSeenFlag(GUILD_HELP_KEY_FTUE_SEEN_FLAG);
         }
         else if(!Global.player.getSeenFlag(GUILD_RECEIVED_HELP_KEY_FTUE_SEEN_FLAG) && GuildManager.getInstance().canTriggerReceivedHelpFTUE() > 0)
         {
            m_FTUEState = 10;
            this.resumeFTUEFlow();
         }
         else
         {
            this.m_tutorialMc.visible = false;
            this.m_okay1Bt.visible = false;
            this.m_okay2Bt.visible = false;
            this.m_npc1Mc.visible = false;
            this.m_npc2Mc.visible = false;
            this.m_npcAutoMc.visible = false;
            this.m_npc1Tf1.visible = false;
            this.m_npc1Tf2.visible = false;
         }
         this.startTimer();
         MovieClipUtils.recursivePlay(this.m_messageLoader_mc);
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function checkMessageLength(event:KeyboardEvent) : void
      {
         var msgString:String = this.m_input_tf.text;
         if(msgString.length > 45)
         {
            this.m_input_tf.text = msgString.substr(0,45);
         }
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshConnectionTimerText();
      }
      
      private function refreshConnectionTimerText() : void
      {
         if(GuildEventManager.getInstance().hasUserStartedCurrentEvent())
         {
            if(GuildEventManager.getTimeLeftForEventStart() > 0)
            {
               this.m_prereq_tf.text = "Your fate is about to change! Start a journey to riches with your clan " + HUD.getformattedTimeLeft(GuildEventManager.getTimeLeftForEventStart());
            }
         }
      }
      
      public function resumeFTUEFlow() : void
      {
         switch(m_FTUEState)
         {
            case 1:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(1);
               this.m_okay2Bt.visible = false;
               this.m_okay1Bt.visible = true;
               this.m_npc1Mc.visible = true;
               this.m_npc2Mc.visible = false;
               this.m_npc1TalkMc.visible = true;
               this.m_npc2TalkMc.visible = false;
               this.m_npcAutoMc.visible = true;
               this.m_npc1Tf1.text = "Clan-warming!";
               this.m_npc1Tf1.visible = true;
               this.m_npc1Tf2.visible = true;
               this.m_npc1Tf2.text = "Welcome to your clan, Farmer. A whole lotta fun awaits you!";
               break;
            case 2:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(2);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = true;
               this.m_npc2Mc.visible = false;
               this.m_npcAutoMc.visible = false;
               this.m_npc1TalkMc.visible = true;
               this.m_npc2TalkMc.visible = false;
               this.m_npc1Tf1.text = "Clan Pals!";
               this.m_npc1Tf2.text = "Click here to see who else is part of your awesome clan!";
               break;
            case 3:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(3);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = true;
               this.m_npc2Mc.visible = false;
               this.m_npcAutoMc.visible = false;
               this.m_npc1Tf1.text = "Chatty Cathy!";
               this.m_npc1Tf2.text = "Want to talk to your clan buddies? We have the thing for you. An all new Clan Chat! Send a message to start!";
               break;
            case 4:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(4);
               this.m_okay2Bt.visible = true;
               this.m_okay1Bt.visible = false;
               this.m_npc1Mc.visible = false;
               this.m_npc2Mc.visible = true;
               this.m_npcAutoMc.visible = false;
               this.m_npc2Tf1.text = "Clan Token!";
               this.m_npc2Tf2.text = "You can play events with your clan members! To enter a feature, Clan Tokens need to be used. Craft them here.";
               break;
            case 5:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(5);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = false;
               this.m_npc2Mc.visible = true;
               this.m_npcAutoMc.visible = false;
               this.m_npc2Tf1.text = "Chatty Token!";
               this.m_npc2Tf2.text = "There are 3 ingredients required to craft tokens. These ingredients replenish with time. You can see the timer on hover.";
               break;
            case 6:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(6);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = false;
               this.m_npc2Mc.visible = true;
               this.m_npcAutoMc.visible = false;
               this.m_npc2Tf1.text = "Crafty Clan!";
               this.m_npc2Tf2.text = "Go here and Craft Clan Tokens. Make sure you have enough ingredients!";
               break;
            case 7:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(7);
               this.m_okay1Bt.visible = true;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = true;
               this.m_npc2Mc.visible = false;
               this.m_npcAutoMc.visible = false;
               this.m_npc1Tf1.text = "Stats Up!";
               this.m_npc1Tf2.text = "See yours and your clan’s Stat Points here. Help clan buddies with tokens & finish tasks in features to upgrade these points!";
               break;
            case 8:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(8);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = false;
               this.m_npc2Mc.visible = true;
               this.m_npcAutoMc.visible = false;
               this.m_npc2Tf1.text = "Helping Hand!";
               this.m_npc2Tf2.text = "Don’t have enough tokens to play the event? No worries, just ask your clan for Help! Try it now to get a helping hand.";
               break;
            case 9:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(9);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = false;
               this.m_npc2Mc.visible = true;
               this.m_npcAutoMc.visible = false;
               this.m_npc2Tf1.text = "Latest Feeds!";
               this.m_npc2Tf2.text = "Click here to always be updated with what’s happening in your clan. You can see who is helping, who left or joined, etc.";
               break;
            case 10:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(10);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = false;
               this.m_npc2Mc.visible = true;
               this.m_npcAutoMc.visible = false;
               this.m_npc2Tf1.text = "Helping Hand!";
               this.m_npc2Tf2.text = "Helping your clan members can help you and your clan grow as it adds to your Stat Points. Be a helper by fulfilling token requests from clan members.";
               Global.player.setSeenFlag(GUILD_RECEIVED_HELP_KEY_FTUE_SEEN_FLAG);
               break;
            default:
               Global.player.setSeenFlag(GUILD_MAIN_WINDOW_FTUE_SEEN_FLAG);
               this.m_tutorialMc.visible = false;
               this.m_tutorialMc.gotoAndStop(0);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = false;
               this.m_npc2Mc.visible = false;
               this.m_npcAutoMc.visible = false;
               this.m_npc1Tf1.visible = false;
               this.m_npc1Tf2.visible = false;
         }
      }
      
      public function onOkayButtonClick(e:Event) : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = false;
         }
         m_FTUEState += 1;
         this.resumeFTUEFlow();
      }
      
      private function onSendChatMessageButtonClick(e:Event) : void
      {
         var msg:String = this.m_input_tf.text;
         var trimStr:String = StringUtil.trim(msg);
         if(Boolean(msg) && Boolean(msg != "") && trimStr != "")
         {
            GuildManager.getInstance().sendMessageToGuild(msg);
         }
         this.m_input_tf.text = "";
         if(m_FTUEState == 3)
         {
            ++m_FTUEState;
            this.resumeFTUEFlow();
         }
      }
      
      private function populateConsumables() : void
      {
         if(!this.m_consumableSlotFrame)
         {
            this.m_consumableSlotFrame = new GuildConsumableSlotContainerFrame(this.m_consumable_mc["reqs_mc"],this.m_featureName) as GuildConsumableSlotContainerFrame;
         }
         this.m_consumableSlotFrame.visible = true;
      }
      
      private function onTabClick(tabNum:int) : void
      {
         switch(tabNum)
         {
            case 0:
               this.m_tab1Content_mc.visible = false;
               this.m_tab0Content_mc.visible = true;
               this.m_input_tf.visible = true;
               this.m_sendMessage_bt.visible = true;
               this.m_chatMark.visible = false;
               break;
            case 1:
            default:
               if(m_FTUEState == 9)
               {
                  m_FTUEState = 0;
                  this.resumeFTUEFlow();
               }
               else if(m_FTUEState == 10)
               {
                  m_FTUEState = 0;
                  this.resumeFTUEFlow();
               }
               this.m_tab1Content_mc.visible = true;
               this.m_tab0Content_mc.visible = false;
               this.m_notifMark.visible = false;
         }
      }
      
      private function onAskClick(e:Event) : void
      {
         GuildManager.getInstance().askGuildKey();
         this.m_ask_tf.text = "Requested: " + GuildManager.getInstance().getRequestedKeyCount().toString() + "/" + GuildManager.MAX_REQUESTED_GUILD_KEY_CAP.toString();
         if(m_FTUEState == 8)
         {
            ++m_FTUEState;
            this.resumeFTUEFlow();
         }
         this.refreshAskGuildKeyButton();
      }
      
      public function refreshAskGuildKeyButton() : void
      {
         this.m_askGuildKey.callback = null;
         if(GuildManager.getInstance().canAskForGuildKeys() == false)
         {
            this.m_askGuildKey.applyGrayOut = true;
         }
         else
         {
            this.m_askGuildKey.enabled = true;
            this.m_askGuildKey.applyGrayOut = false;
            if(this.m_askGuildKey.tooltip)
            {
               this.m_askGuildKey.detachTooltip();
            }
            this.m_askGuildKey.callback = this.onAskClick;
         }
      }
      
      private function onCraftClick(e:Event) : void
      {
         GuildManager.getInstance().openConsumableCraftWindow();
      }
      
      private function onCoopBrowseClick(e:Event) : void
      {
         GuildManager.getInstance().openGuildListWindow();
      }
      
      private function onCoopViewClick(e:Event) : void
      {
         GuildManager.getInstance().openGuildViewWindow();
         if(GuildMainWindow.m_FTUEState == 2)
         {
            ++GuildMainWindow.m_FTUEState;
            this.resumeFTUEFlow();
         }
      }
      
      public function refreshGuildEventEntryButton() : void
      {
         var requiredKeys:int = GuildEventManager.getInstance().getKeysRequiredForCurrentEvent();
         if(GuildEventManager.getInstance().hasUserStartedCurrentEvent())
         {
            this.m_guildEventEntryButton.text = "Play";
            this.m_prereq_tf.visible = false;
            if(GuildEventManager.getTimeLeftForEventStart() > 0)
            {
               this.m_guildEventEntryButton.enabled = false;
               this.m_guildEventEntryButton.callback = null;
               this.m_guildEventEntryButton.attachTooltip(new FarmTextTooltip("The adventure starts on " + featureXML.child("formalFeatureStartDate") + ". You can chat and exchange tokens amongst clan members. You cannot leave the clan once you have given tokens and until the event ends."));
               this.m_marketing_tf.text = "Road to Riches!";
               this.m_prereq_tf.text = "Your fate is about to change! Start a journey to riches with your clan " + HUD.getformattedTimeLeft(GuildEventManager.getTimeLeftForEventStart());
               this.m_prereq_tf.visible = true;
               this.m_status_tf.text = GuildManager.getInstance().getGuildeventJoinedMembersCount().toString() + "/" + GuildManager.getInstance().guildMembersCount().toString() + " have joined";
            }
            else if(GuildEventManager.getInstance().hasCompletedCurrentEvent() || GuildEventManager.getTimeLeftForEventEnd() <= 0)
            {
               this.m_marketing_tf.text = "Next Adventure Start Soon!";
               this.m_guildEventEntryButton.visible = false;
               this.m_guildEventEntryButton.callback = null;
               this.m_prereq_tf.text = "Watch out for this space for the next exciting event with your clan members!";
               this.m_prereq_tf.visible = true;
               this.m_status_tf.text = "";
            }
            else
            {
               this.m_marketing_tf.text = "Your Crusade Awaits!";
               this.m_prereq_tf.text = "It’s finally time to uncover the hidden mysteries and ring in the fortunes until " + featureXML.child("formalFeatureEndDate") + "!";
               this.m_prereq_tf.visible = true;
               this.m_guildEventEntryButton.enabled = true;
               this.m_guildEventEntryButton.callback = this.enterInGuildEvent;
               this.m_status_tf.text = GuildManager.getInstance().getGuildeventJoinedMembersCount().toString() + "/" + GuildManager.getInstance().guildMembersCount().toString() + " have joined";
            }
         }
         else if(GuildManager.getInstance().isSinkForEventActive())
         {
            if(GuildManager.getInstance().hasSufficientKeysToEnterInEvent() == false)
            {
               this.m_marketing_tf.text = "Not Enough Tokens";
               this.m_prereq_tf.text = "Collect 80 Clan Tokens to be a part of the adventure";
               this.m_prereq_tf.visible = true;
               this.m_guildEventEntryButton.text = "Use Tokens";
               FarmGameUtil.disableButtonAndShowTooltip(this.m_guildEventEntryButton,"Collect " + requiredKeys.toString() + " tokens to activate this button");
               this.m_guildEventEntryButton.callback = null;
               this.m_status_tf.text = GuildManager.getInstance().getGuildeventJoinedMembersCount().toString() + "/" + GuildManager.getInstance().guildMembersCount().toString() + " have joined";
            }
            else
            {
               this.m_marketing_tf.text = " Adventure Time!";
               this.m_prereq_tf.text = "Use 80 Clan Tokens to embark on an adventure of a lifetime!";
               this.m_prereq_tf.visible = true;
               this.m_guildEventEntryButton.enabled = true;
               this.m_guildEventEntryButton.text = "Use Tokens";
               this.m_guildEventEntryButton.callback = this.unlockGuildEvent;
               this.m_guildEventEntryButton.detachTooltip();
               this.m_status_tf.text = GuildManager.getInstance().getGuildeventJoinedMembersCount().toString() + "/" + GuildManager.getInstance().guildMembersCount().toString() + " have joined";
            }
         }
         else if(GuildEventManager.timeLeftInNextSinkStart() > 0)
         {
            this.m_guildEventEntryButton.text = "Sink " + requiredKeys.toString() + " Tokens";
            FarmGameUtil.disableButtonAndShowTooltip(this.m_guildEventEntryButton,"Event will start in " + HUD.getformattedTimeLeft(GuildEventManager.timeLeftInNextSinkStart()));
            this.m_guildEventEntryButton.callback = null;
         }
         else
         {
            this.m_marketing_tf.text = "Escaped the Escapade until " + featureXML.child("formalFeatureEndDate") + "!";
            this.m_guildEventEntryButton.visible = true;
            this.m_guildEventEntryButton.text = "Play";
            FarmGameUtil.disableButtonAndShowTooltip(this.m_guildEventEntryButton,"Joining time for this event is over. Come back during the next event to be a part of it!");
            this.m_guildEventEntryButton.callback = null;
            this.m_prereq_tf.text = "You didn’t join your clan to search for gold, on time. But, don’t worry, there’s always a next time!";
         }
      }
      
      private function unlockGuildEvent(e:Event) : void
      {
         GuildEventManager.getInstance().unlockGuildEventForUser();
         this.refreshGuildEventEntryButton();
      }
      
      private function enterInGuildEvent(e:Event) : void
      {
         GuildEventManager.getInstance().openGuildEventMainWindow();
      }
      
      private function onCollect(slotIndex:int) : Function
      {
         return function(e:Event):void
         {
            GuildManager.getInstance().collectConsumable(slotIndex);
         };
      }
      
      public function canCollectForTheDay(slotIndex:int) : Boolean
      {
         var canCollect:Boolean = true;
         var key:String = this.m_featureName + GuildManager.COLLECT_TIME_KEY + slotIndex.toString();
         if(this.getTimeLeft(key,GuildManager.THROTTLE_TIME_ARRAY[slotIndex]) > 0)
         {
            canCollect = false;
         }
         return canCollect;
      }
      
      public function getTimeLeft(key:String, throttleTime:int) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function refreshChatWindow() : void
      {
         this.m_sentMessageFrame.setupSlotData(GuildManager.getInstance().getChatMessages());
         this.m_receivedMessageFrame.setupSlotData(GuildManager.getInstance().getChatMessages());
         this.m_sentMessageFrame.refresh();
         this.m_receivedMessageFrame.refresh();
      }
      
      override public function close() : void
      {
         this.stopTimer();
         GuildManager.getInstance().m_guildMainWindow = null;
         super.close();
      }
      
      public function refreshKeyFrame() : void
      {
         if(this.m_requestFrame)
         {
            this.m_requestFrame.refresh();
            this.m_count_tf.text = GuildManager.getInstance().getKeyCount().toString();
         }
         this.refreshUserPoints();
         this.refreshGuildPoints();
      }
      
      public function refreshNotificationWindow() : void
      {
         if(this.m_notificationsFrame)
         {
            this.m_notificationsFrame.setupSlotData(GuildManager.getInstance().getNotificationMessages());
            this.m_notificationsFrame.refresh();
            if(!Global.player.getSeenFlag(GuildManager.COMPLETED_NOTIFICATION_LOADING))
            {
               this.showMessageLoader();
            }
            else
            {
               this.hideMessageLoader();
            }
         }
      }
      
      public function refreshKeyCount() : void
      {
         if(this.m_count_tf)
         {
            this.m_count_tf.text = GuildManager.getInstance().getKeyCount().toString();
            this.m_count_tf.visible = true;
         }
         this.refreshGuildEventEntryButton();
         if(GuildManager.getInstance().hasGuildKeyCapReached())
         {
            if(GuildManager.getInstance().m_guildConsumableCraftWindow)
            {
               GuildManager.getInstance().m_guildConsumableCraftWindow.refreshGuildCraftWindow();
            }
            this.m_craftBt.callback = null;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_craftBt,"Your token inventory is full");
         }
         else
         {
            if(this.m_craftBt.tooltip)
            {
               this.m_craftBt.detachTooltip();
            }
            this.m_craftBt.callback = null;
            this.m_craftBt.callback = this.onCraftClick;
            this.m_craftBt.enabled = true;
         }
      }
      
      override public function refreshWindow() : void
      {
         if(this.m_requestFrame)
         {
            this.m_requestFrame.refresh();
         }
         if(GuildManager.getInstance().getKeyRequestData().length < 0)
         {
            if(m_FTUEState == 10)
            {
               m_FTUEState = -1;
               this.resumeFTUEFlow();
            }
         }
         this.refreshKeyCount();
         this.refreshAskGuildKeyButton();
         this.populateConsumables();
         this.refreshUserPoints();
         this.refreshGuildPoints();
      }
      
      public function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_npcAuto1Tf.text = title;
         this.m_npcAuto2Tf.text = text;
         this.m_npcAutoMc.visible = true;
         this.m_npcAutoMc.gotoAndPlay(1);
      }
      
      public function refreshUserPoints() : void
      {
         if(this.m_cpoints_tf)
         {
            this.m_cpoints_tf.text = "Your Stat Points: " + GuildManager.getInstance().getUserPoints().toString();
         }
      }
      
      public function refreshGuildPoints() : void
      {
         if(this.m_coop_total_cpoints_tf)
         {
            this.m_coop_total_cpoints_tf.text = GuildManager.getInstance().getGuildtotalPoints().toString();
         }
      }
      
      public function updatePlayerPointsDoober(quantity:int = 1) : void
      {
         if(this.m_points_dooberMc)
         {
            this.m_points_dooberMc.visible = true;
            if(this.m_points_dooberCountTf)
            {
               this.m_points_dooberCountTf.text = "+" + int(quantity).toString();
            }
            this.m_points_dooberMc.gotoAndPlay(2);
         }
      }
      
      public function updateConsumableDoober(quantity:int = 1) : void
      {
         if(this.m_consumable_dooberMc)
         {
            this.m_consumable_dooberMc.visible = true;
            if(this.m_consumable_dooberCountTf)
            {
               this.m_consumable_dooberCountTf.text = "+" + int(quantity).toString();
            }
            this.m_consumable_dooberMc.gotoAndPlay(2);
         }
      }
      
      public function getSelectedMessageTab() : int
      {
         if(this.m_tabMenu)
         {
            return this.m_tabMenu.selectedTab;
         }
         return -1;
      }
      
      public function highlighMessageFrameMark(tabNum:int) : void
      {
         if(tabNum == 0)
         {
            this.m_chatMark.visible = true;
            this.m_chatMark.play();
         }
         else
         {
            this.m_notifMark.visible = true;
            this.m_notifMark.play();
         }
      }
      
      public function updateMembersStatus() : void
      {
         if(this.m_membersStatusFrame)
         {
            this.m_membersStatusFrame.refresh();
         }
      }
      
      public function refreshRequestCount() : void
      {
         this.m_ask_tf.text = "Requested: " + GuildManager.getInstance().getRequestedKeyCount().toString() + "/" + GuildManager.MAX_REQUESTED_GUILD_KEY_CAP.toString();
      }
      
      private function onChatInputBoxClick(event:MouseEvent) : void
      {
         Global.farmGame.switchOutFullScreen();
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = true;
      }
      
      public function showMessageLoader() : void
      {
         this.m_messageLoader_mc.visible = true;
      }
      
      public function hideMessageLoader() : void
      {
         this.m_messageLoader_mc.visible = false;
      }
   }
}

