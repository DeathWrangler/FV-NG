package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildEventHelpOrderboardSlotFrame;
   import Widgets.Frames.GuildPlayerTasksOrderboradSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.GuildEventHelpSelectedTaskSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class GuildEventMainWindow extends FarmWindow
   {
      
      private static const coopXML:Class = GuildEventMainWindow_coopXML;
      
      public static const featureXML:XML = XML(new coopXML());
      
      private static const FEATURE_NAME:String = featureXML.child("featureName");
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      private static const SAGA_MAP_GAP:int = 1050;
      
      private static const SAGA_MAP_HALF_GAP:int = 525;
      
      private static const FINAL_MILESTONE_GAP:int = 1400;
      
      private static const SAGA_MAP_Y_GAP:int = 250;
      
      public static const GUILD_EVENT_MAIN_FTUE_SEEN_FLAG:String = featureXML.child("GUILD_EVENT_MAIN_FTUE_SEEN_FLAG");
      
      public static const GUILD_FIRST_ORDER_SEEN_FLAG:String = featureXML.child("GUILD_FIRST_ORDER_SEEN_FLAG");
      
      public static const GUILD_EVENT_HELP_FTUE_SEEN_FLAG:String = featureXML.child("GUILD_EVENT_HELP_FTUE_SEEN_FLAG");
      
      public static var m_FTUEState:int = 1;
      
      public static const GUILD_EVENT_ALL_SLOT_FULL_FLAG:String = "guildEventAllSlotFullSeenFlag";
      
      private var m_featureName:String = null;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_helptasks_mc:MovieClip;
      
      private var m_help_select_mc:MovieClip;
      
      private var m_help_slots_mc:GuildEventHelpOrderboardSlotFrame;
      
      private var m_help_counter_tf:ZwTextField;
      
      private var m_default_tf:ZwTextField;
      
      public var m_playerTasksFrame:GuildPlayerTasksOrderboradSlotFrame;
      
      private var m_progress_mc:MovieClip;
      
      private var m_selected_help_task_slot:GuildEventHelpSelectedTaskSlot;
      
      private var m_guildInfo:Object;
      
      private var m_guildPtInfo:int;
      
      private var m_coop_total_cpoints_tf:ZwTextField;
      
      private var m_coop_icon_mc:FarmIcon;
      
      private var m_points_tf:ZwTextField;
      
      private var m_scroll_mc:MovieClip;
      
      private var m_coop_name_tf:ZwTextField;
      
      private var m_details_bt:FarmAnimatedTextButton;
      
      private var m_map_bt:FarmAnimatedTextButton;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_meterMcArray:Array = [];
      
      private var m_passMcArray:Array = [];
      
      public var tierMilestoneArray:Array = [0,1050,2100,3500];
      
      private var m_backgroundMc:MovieClip;
      
      public var m_tutorialMc:MovieClip;
      
      public var m_okay1Bt:FarmAnimatedTextButton;
      
      public var m_okay2Bt:FarmAnimatedTextButton;
      
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
      
      private var m_buildingCheckmarkMC:MovieClip;
      
      private var m_checkMarkMc:MovieClip;
      
      private var m_buildingFrame:Array = [];
      
      private var m_sectionFrame:Array = [];
      
      private var m_milestoneFrame:Array = [];
      
      private var m_chestFrame:Array = [];
      
      private var m_milestoneMcArray:Array = [];
      
      private var m_buildingMcArray:Array = [];
      
      private var m_chestMcArray:Array = [];
      
      public const GUILD_EVENT_ADD_ORDER_FLAG:String = "Guild_Event_Add_Order_flag_V1";
      
      public const GUILD_EVENT_SAGA_MAP_FLAG:String = "Guild_Event_Saga_Map_flag_V1";
      
      private var m_scrollInitialY:Number;
      
      private var m_dooberMc:MovieClip;
      
      private var m_dooberIconMc:MovieClip;
      
      private var m_dooberCountTf:ZwTextField;
      
      private var m_pointsIconMc:MovieClip;
      
      private var m_pointsIconFrame:ZwFrame;
      
      private const BUILDING_NAME_ARRAY:Array = [featureXML.child("BUILDING_NAME_ARRAY").child("building1"),featureXML.child("BUILDING_NAME_ARRAY").child("building2"),featureXML.child("BUILDING_NAME_ARRAY").child("building3")];
      
      public var m_overlayMc:MovieClip;
      
      private var m_TimerMc:MovieClip;
      
      private var m_TimerTf:ZwTextField;
      
      private var m_timer:Timer;
      
      public var m_tutorial1Mc:MovieClip;
      
      private var m_npc2AutoMc:MovieClip;
      
      private var m_npc2AutoTalkMc:MovieClip;
      
      private var m_lock_mc:MovieClip;
      
      private var m_checkMarkMcArray:Array = [];
      
      private var m_buildingCheckmarkMCArray:Array = [];
      
      public function GuildEventMainWindow(featureName:String, assetUrl:String)
      {
         this.m_featureName = featureName;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var attachedToolTip:FarmTextTooltip = null;
         var i:int = 0;
         var rewardItemCode:String = null;
         var rewardFarmItem:FarmItem = null;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         if(Boolean(GuildManager.getInstance().m_guildMainWindow) && Boolean(GuildManager.getInstance().m_guildMainWindow.m_closeBt))
         {
            GuildManager.getInstance().m_guildMainWindow.m_closeBt.enabled = false;
            GuildManager.getInstance().m_guildMainWindow.m_closeBt.visible = false;
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],featureXML.child("GUILD_EVENT_NAME_TEXT")));
         }
         if(m_window.hasOwnProperty("tutorial1_mc"))
         {
            this.m_tutorial1Mc = m_window["tutorial1_mc"] as MovieClip;
            this.m_tutorial1Mc.visible = false;
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
               this.m_npc2Tf1 = new ZwTextField(this.m_npc2TalkMc["npc1_tf"]," Auto npc1");
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
            }
         }
         if(m_window.hasOwnProperty("npc2_auto_mc"))
         {
            this.m_npc2AutoMc = m_window.npc2_auto_mc as MovieClip;
            this.m_npc2AutoMc.visible = false;
            if(this.m_npc2AutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_npc2AutoTalkMc = this.m_npc2AutoMc.talk_mc as MovieClip;
               this.m_npc2AutoTalkMc.visible = true;
            }
         }
         if(m_window.hasOwnProperty("lock_mc"))
         {
            this.m_lock_mc = m_window["lock_mc"] as MovieClip;
            this.m_lock_mc.visible = false;
         }
         if(m_window.hasOwnProperty("helptasks_mc"))
         {
            this.m_helptasks_mc = m_window["helptasks_mc"] as MovieClip;
            this.m_helptasks_mc.visible = true;
            if(this.m_helptasks_mc.hasOwnProperty("default_tf"))
            {
               this.m_default_tf = new ZwTextField(this.m_helptasks_mc["default_tf"],"default_tf");
               this.m_default_tf.visible = false;
            }
            if(this.m_helptasks_mc.hasOwnProperty("help_counter_tf"))
            {
               this.m_help_counter_tf = new ZwTextField(this.m_helptasks_mc["help_counter_tf"],"help_counter_tf");
               this.m_help_counter_tf.visible = true;
            }
            if(this.m_helptasks_mc.hasOwnProperty("help_select_mc"))
            {
               this.m_help_select_mc = this.m_helptasks_mc["help_select_mc"] as MovieClip;
               this.m_help_select_mc.visible = false;
            }
            if(this.m_helptasks_mc.hasOwnProperty("help_slots_mc"))
            {
               this.m_help_slots_mc = new GuildEventHelpOrderboardSlotFrame(this.m_helptasks_mc["help_slots_mc"],this.m_featureName,this);
               this.m_help_slots_mc.visible = false;
            }
            this.refreshHelpTaskFrame();
         }
         if(m_window.hasOwnProperty("tasks_mc"))
         {
            this.m_playerTasksFrame = new GuildPlayerTasksOrderboradSlotFrame(m_window["tasks_mc"],this.m_featureName,this);
            this.m_playerTasksFrame.visible = true;
         }
         var curTier:int = this.eventManager.getCurrentTier();
         var usrlvl:int = this.eventManager.getUserGrantedRewardLevel();
         if(m_window.hasOwnProperty("progress_mc"))
         {
            this.m_guildInfo = FeatureOptionsManager.getInstance().getFeatureOption(GuildManager.FEATURE_NAME,GuildManager.TEMP_FO_GUILd_VIEW_INFO);
            this.m_guildPtInfo = int(FeatureOptionsManager.getInstance().getFeatureOption(GuildManager.FEATURE_NAME,GuildEventManager.TEMP_FO_GUILD_OB_POINTS));
            this.m_progress_mc = m_window["progress_mc"] as MovieClip;
            this.m_progress_mc.visible = true;
            if(this.m_progress_mc.hasOwnProperty("total_points_tf"))
            {
               this.m_coop_total_cpoints_tf = new ZwTextField(this.m_progress_mc["total_points_tf"],"total_points_tf");
               this.m_coop_total_cpoints_tf.visible = true;
            }
            this.m_coop_icon_mc = new FarmIcon(this.m_progress_mc["icon_mc"],GuildManager.GUILD_LOGO_IMAGE_ARRAY[int(this.m_guildInfo["alias"]) + 1]);
            this.m_coop_icon_mc.visible = true;
            this.m_coop_icon_mc.setIconSize(50,50);
            this.m_coop_icon_mc.setSmoothing(true);
            attachedToolTip = this.m_coop_icon_mc.tooltip as FarmTextTooltip;
            if(attachedToolTip)
            {
               attachedToolTip.release();
               this.m_coop_icon_mc.detachTooltip();
            }
            this.m_coop_icon_mc.attachTooltip(new FarmTextTooltip(this.m_guildInfo["name"]));
            if(this.m_progress_mc.hasOwnProperty("points_tf"))
            {
               this.m_pointsTf = new ZwTextField(this.m_progress_mc["points_tf"],"Your Event Score\n" + this.eventManager.getUserPoints().toString());
               this.m_pointsTf.visible = true;
            }
            if(this.m_progress_mc.hasOwnProperty("scroll_mc"))
            {
               this.m_scroll_mc = this.m_progress_mc["scroll_mc"] as MovieClip;
               this.m_scroll_mc.visible = true;
               this.m_scrollInitialY = this.m_scroll_mc.y;
               for(i = 0; i < 7; i++)
               {
                  if(this.m_scroll_mc.hasOwnProperty("meter" + (i + 1).toString() + "_mc"))
                  {
                     this.m_meterMcArray[i] = this.m_scroll_mc["meter" + (i + 1).toString() + "_mc"] as MovieClip;
                     this.m_meterMcArray[i].visible = true;
                  }
               }
               for(i = 0; i < 2; i++)
               {
                  if(this.m_scroll_mc.hasOwnProperty("pass" + (i + 1).toString() + "_mc"))
                  {
                     this.m_passMcArray[i] = this.m_scroll_mc["pass" + (i + 1).toString() + "_mc"] as MovieClip;
                     this.m_passMcArray[i].visible = false;
                  }
               }
               for(i = 0; i < 6; i++)
               {
                  if(this.m_scroll_mc.hasOwnProperty("milestone" + (i + 1).toString() + "_mc"))
                  {
                     this.m_milestoneMcArray[i] = this.m_scroll_mc["milestone" + (i + 1).toString() + "_mc"] as MovieClip;
                     this.m_milestoneMcArray[i].visible = true;
                     rewardItemCode = (this.eventManager.getRewardsForTier(i / 2)[i % 2] as Object).value;
                     rewardFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardItemCode);
                     this.m_milestoneFrame[i] = new ZwFrame(this.m_milestoneMcArray[i]);
                     this.m_milestoneFrame[i].attachTooltip(new FarmTextTooltip(rewardFarmItem.friendlyTitle));
                     if(this.m_milestoneMcArray[i].hasOwnProperty("checkmark_mc"))
                     {
                        this.m_checkMarkMcArray[i] = this.m_milestoneMcArray[i]["checkmark_mc"] as MovieClip;
                        this.m_checkMarkMcArray[i].visible = i < 2 ? i + 1 <= this.eventManager.getUserGrantedRewardLevel() : i + 2 <= this.eventManager.getUserGrantedRewardLevel();
                     }
                  }
               }
               for(i = 0; i < 3; i++)
               {
                  if(this.m_scroll_mc.hasOwnProperty("building" + (i + 1).toString() + "_mc"))
                  {
                     this.m_buildingMcArray[i] = this.m_scroll_mc["building" + (i + 1).toString() + "_mc"] as MovieClip;
                     this.m_buildingMcArray[i].visible = true;
                     this.m_buildingFrame[i] = new ZwFrame(this.m_buildingMcArray[i]);
                     this.m_buildingFrame[i].attachTooltip(new FarmTextTooltip(this.BUILDING_NAME_ARRAY[i]));
                     if(this.m_buildingMcArray[i].hasOwnProperty("checkmark_mc"))
                     {
                        this.m_buildingCheckmarkMCArray[i] = this.m_buildingMcArray[i]["checkmark_mc"] as MovieClip;
                        this.m_buildingCheckmarkMCArray[i].visible = 3 * (i + 1) <= this.eventManager.getUserGrantedRewardLevel();
                     }
                  }
               }
               for(i = 0; i < 3; i++)
               {
                  if(this.m_scroll_mc.hasOwnProperty("chest" + (i + 1).toString() + "_mc"))
                  {
                     this.m_chestMcArray[i] = this.m_scroll_mc["chest" + (i + 1).toString() + "_mc"] as MovieClip;
                     this.m_chestMcArray[i].visible = true;
                     if(3 * (i + 1) <= this.eventManager.getUserGrantedRewardLevel())
                     {
                        this.m_chestMcArray[i].gotoAndStop(2);
                     }
                     else
                     {
                        this.m_chestMcArray[i].gotoAndStop(1);
                        this.m_chestFrame[i] = new ZwFrame(this.m_chestMcArray[i]);
                        this.m_chestFrame[i].attachTooltip(new FarmTextTooltip("This treasure chest with-holds buried mysteries and bounties which can make your life full of riches! Reach this milestone to uncover such fortune."));
                     }
                  }
               }
               if(curTier > 0 && curTier < 3)
               {
                  this.m_scroll_mc.y += curTier * 250;
               }
            }
            if(this.m_progress_mc.hasOwnProperty("doober_mc"))
            {
               this.m_dooberMc = this.m_progress_mc["doober_mc"] as MovieClip;
               if(this.m_dooberMc.hasOwnProperty("dooberIcon_mc"))
               {
                  this.m_dooberIconMc = this.m_dooberMc["dooberIcon_mc"];
                  if(this.m_dooberIconMc.hasOwnProperty("dooberCount_tf"))
                  {
                     addWidget(this.m_dooberCountTf = new ZwTextField(this.m_dooberIconMc["dooberCount_tf"]));
                  }
               }
            }
            if(this.m_progress_mc.hasOwnProperty("points_icon_mc"))
            {
               this.m_pointsIconMc = this.m_progress_mc["points_icon_mc"] as MovieClip;
               this.m_pointsIconMc.visible = true;
               this.m_pointsIconFrame = new ZwFrame(this.m_pointsIconMc);
               this.m_pointsIconFrame.attachTooltip(new FarmTextTooltip("Clan Event Score"));
            }
            if(m_window.hasOwnProperty("timer_mc"))
            {
               this.m_TimerMc = m_window["timer_mc"] as MovieClip;
               this.m_TimerMc.visible = true;
               addWidget(this.m_TimerTf = new ZwTextField(this.m_TimerMc["timer_tf"],HUD.getformattedTimeLeft(GuildEventManager.getTimeLeftForEventEnd())));
               this.m_TimerTf.visible = true;
            }
            addWidget(this.m_details_bt = new FarmAnimatedTextButton(this.m_progress_mc["details_bt"],"View Details",this.onDetailButtonClick));
            addWidget(this.m_map_bt = new FarmAnimatedTextButton(this.m_progress_mc["map_bt"],"Map Progress",this.onMapButtonClick));
         }
         if(m_window.hasOwnProperty("background_mc"))
         {
            this.m_backgroundMc = m_window["background_mc"] as MovieClip;
            this.m_backgroundMc.visible = true;
            if(curTier <= 2)
            {
               this.m_backgroundMc.gotoAndStop(curTier + 1);
            }
            else
            {
               this.m_backgroundMc.gotoAndStop(3);
            }
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlayMc = m_window["overlay_mc"] as MovieClip;
            this.m_overlayMc.visible = false;
         }
         this.updateUserPoints();
         this.updateGuildPoints();
         this.updateMiniSagaMap();
         this.updateGuildBackground();
         this.startTimer();
         if(!Global.player.getSeenFlag(GUILD_EVENT_MAIN_FTUE_SEEN_FLAG))
         {
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
               this.m_npcAutoMc.visible = false;
               this.m_npc1Tf1.text = "Clan Event!";
               this.m_npc1Tf1.visible = true;
               this.m_npc1Tf2.visible = true;
               this.m_npc1Tf2.text = "Welcome, Farmer, to your " + featureXML.child("coopEventNumber") + " ever clan event! Embark on a journey & discover mysterious fortune with your clan!";
               break;
            case 2:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(2);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = true;
               this.m_npc2Mc.visible = false;
               this.m_npcAutoMc.visible = false;
               this.m_npc1Tf1.text = "Orders In!";
               this.m_npc1Tf1.visible = true;
               this.m_npc1Tf2.visible = true;
               this.m_npc1Tf2.text = "Click here to add an order for you to complete. You can add up to 3 orders. No 2 orders can be the same.\n";
               break;
            case 3:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(3);
               this.m_okay1Bt.visible = true;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = true;
               this.m_npc2Mc.visible = false;
               this.m_npcAutoMc.visible = false;
               this.m_npc1Tf1.text = "Orders In!";
               this.m_npc1Tf2.text = "Great! You have selected your first order. Now go ahead and select 2 more for the remaining slots!";
               break;
            case 4:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(4);
               this.m_okay2Bt.visible = false;
               this.m_okay1Bt.visible = false;
               this.m_npc2Mc.visible = false;
               this.m_npc1Mc.visible = true;
               this.m_npcAutoMc.visible = false;
               this.m_npc1Tf1.text = "Treasure Map!";
               this.m_npc1Tf2.text = "Click here to see the map of the lost, mysterious fortune! This will show you the path to get to them.";
               break;
            case 5:
               this.m_tutorialMc.visible = true;
               this.m_tutorialMc.gotoAndStop(5);
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = true;
               this.m_npc2Mc.visible = false;
               this.m_npcAutoMc.visible = false;
               this.m_npc1Tf1.text = featureXML.child("GUILD_EVENT_NAME");
               this.m_npc1Tf2.text = "Click here to see your clan’s progress, how close you are to the finish & how your many points your buddies have collected!";
               break;
            default:
               Global.player.setSeenFlag(GUILD_EVENT_MAIN_FTUE_SEEN_FLAG);
               this.m_tutorialMc.visible = false;
               this.m_tutorialMc.gotoAndStop(0);
               this.m_tutorial1Mc.visible = false;
               this.m_okay1Bt.visible = false;
               this.m_okay2Bt.visible = false;
               this.m_npc1Mc.visible = false;
               this.m_npc2Mc.visible = false;
               this.m_npcAutoMc.visible = false;
         }
      }
      
      public function onDetailButtonClick(e:Event) : void
      {
         this.eventManager.openGuildEventDetailWindow();
         FarmStatsManager.count(featureXML.child("statCounter"),"event","event_detail_ui","open","impression");
      }
      
      public function onMapButtonClick(e:Event) : void
      {
         this.eventManager.openGuildEventMapWindow();
         FarmStatsManager.count(featureXML.child("statCounter"),"event","event_map_ui","open","impression");
      }
      
      override public function close() : void
      {
         this.stopTimer();
         this.eventManager.m_guildEventMainWindow = null;
         super.close();
         if(GuildManager.getInstance().m_guildMainWindow)
         {
            GuildManager.getInstance().m_guildMainWindow.refreshGuildEventEntryButton();
            if(GuildManager.getInstance().m_guildMainWindow.m_closeBt)
            {
               GuildManager.getInstance().m_guildMainWindow.m_closeBt.enabled = true;
               GuildManager.getInstance().m_guildMainWindow.m_closeBt.visible = true;
            }
         }
      }
      
      public function resumeWindow() : void
      {
         untintWindow();
         enableInput = true;
         this.refreshTaskFrame();
      }
      
      public function refreshTaskFrame() : void
      {
         this.m_playerTasksFrame.visible = true;
         this.m_playerTasksFrame.refresh();
         this.refreshHelpTaskFrame();
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
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
         this.m_TimerTf.text = HUD.getformattedTimeLeft(GuildEventManager.getTimeLeftForEventEnd());
         this.m_TimerTf.visible = true;
      }
      
      override public function refreshWindow() : void
      {
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
      
      public function refreshHelpTaskFrame() : void
      {
         this.m_default_tf.visible = false;
         this.m_help_select_mc.visible = false;
         this.m_help_slots_mc.visible = false;
         if(this.m_help_counter_tf)
         {
            this.m_help_counter_tf.text = "Tasks Helped:" + this.eventManager.getHelpedTaskCount();
            this.m_help_counter_tf.visible = true;
         }
         if(GuildEventManager.getInstance().isHelpTaskSelected())
         {
            this.m_help_select_mc.visible = true;
            this.setupSelectedHelpTaskSlot();
         }
         else if(this.eventManager.getHelpTaskCount() > 0 && this.eventManager.getRealHelpCount() > 0)
         {
            if(!Global.player.getSeenFlag(GUILD_EVENT_HELP_FTUE_SEEN_FLAG) && GuildEventMainWindow.m_FTUEState == 0)
            {
               this.showAutoHideNPCCallouts();
               Global.player.setSeenFlag(GUILD_EVENT_HELP_FTUE_SEEN_FLAG);
            }
            this.m_help_slots_mc.visible = true;
         }
         else
         {
            this.m_help_slots_mc.visible = false;
            this.m_default_tf.visible = true;
            this.m_default_tf.text = "Be the helper of your Clan! Take up tasks put up by your fellow clan members. On helping, you will earn more Event Points, Stat Points and Goodwill!";
         }
      }
      
      public function setupSelectedHelpTaskSlot() : void
      {
         var fo:Object = null;
         var data:Object = null;
         if(this.m_help_select_mc)
         {
            if(this.m_selected_help_task_slot == null)
            {
               this.m_selected_help_task_slot = new GuildEventHelpSelectedTaskSlot(this.m_featureName,this.m_help_select_mc,this);
            }
            fo = this.eventManager.getFeatureData();
            data = this.eventManager.getActiveHelpTaskObject();
            this.m_selected_help_task_slot.populate(data);
            this.m_selected_help_task_slot.visible = true;
         }
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      public function updateUserPoints() : void
      {
         if(this.m_pointsTf)
         {
            this.m_pointsTf.text = "Your Event Score\n" + this.eventManager.getUserPoints().toString();
            this.m_pointsTf.visible = true;
         }
      }
      
      public function updateGuildPoints() : void
      {
         var points:int = this.eventManager.getGuildPoints();
         if(this.m_coop_total_cpoints_tf)
         {
            this.m_coop_total_cpoints_tf.text = points.toString();
            this.m_coop_total_cpoints_tf.visible = true;
         }
         if(Boolean(this.m_lock_mc) && points >= 3500)
         {
            this.m_lock_mc.visible = true;
         }
      }
      
      public function updateMiniSagaMap() : void
      {
         var pointDiff:int = 0;
         var barAngle:Number = NaN;
         var normalizedPoints:Number = NaN;
         var curTier:int = this.eventManager.getCurrentTier();
         var points:int = this.eventManager.getGuildPoints();
         if(this.m_scroll_mc)
         {
            this.m_scroll_mc.y = this.m_scrollInitialY;
         }
         for(var i:int = 0; i < 2 * curTier; i++)
         {
            if(this.m_meterMcArray.length > i)
            {
               if(i % 2 == 0)
               {
                  if(this.m_meterMcArray[i].fill_mc)
                  {
                     this.m_meterMcArray[i].fill_mc.rotation = -180;
                  }
               }
               else if(this.m_meterMcArray[i].fill_mc)
               {
                  this.m_meterMcArray[i].fill_mc.rotation = -180;
               }
            }
         }
         if(i == 2)
         {
            if(this.m_passMcArray[0])
            {
               this.m_passMcArray[0].visible = true;
            }
         }
         else if(i == 4)
         {
            if(this.m_passMcArray[0])
            {
               this.m_passMcArray[0].visible = true;
            }
            if(this.m_passMcArray[1])
            {
               this.m_passMcArray[1].visible = true;
            }
         }
         if(i > 0 && i < 6 && i % 2 == 0)
         {
            if(this.m_scroll_mc)
            {
               this.m_scroll_mc.y += i / 2 * SAGA_MAP_Y_GAP;
            }
         }
         else if(i == 6)
         {
            if(this.m_scroll_mc)
            {
               this.m_scroll_mc.y += 2 * SAGA_MAP_Y_GAP;
            }
         }
         if(curTier < 3)
         {
            if(curTier == 2)
            {
               normalizedPoints = this.tierMilestoneArray[curTier] + (points - this.tierMilestoneArray[curTier]) * SAGA_MAP_GAP / FINAL_MILESTONE_GAP;
               points = normalizedPoints;
            }
            pointDiff = points - this.tierMilestoneArray[curTier];
            barAngle = 0;
            if(pointDiff > SAGA_MAP_HALF_GAP)
            {
               if(this.m_meterMcArray.length > 2 * curTier)
               {
                  if(this.m_meterMcArray[2 * curTier].fill_mc)
                  {
                     this.m_meterMcArray[2 * curTier].fill_mc.rotation = -180;
                  }
               }
               if(this.m_meterMcArray.length > 2 * curTier + 1)
               {
                  if(this.m_meterMcArray[2 * curTier + 1].fill_mc)
                  {
                     barAngle = (pointDiff - SAGA_MAP_HALF_GAP) * 180 / SAGA_MAP_HALF_GAP;
                     this.m_meterMcArray[2 * curTier + 1].fill_mc.rotation = -barAngle;
                  }
               }
            }
            else if(this.m_meterMcArray.length > 2 * curTier)
            {
               if(this.m_meterMcArray[2 * curTier].fill_mc)
               {
                  barAngle = pointDiff * 180 / SAGA_MAP_HALF_GAP;
                  this.m_meterMcArray[2 * curTier].fill_mc.rotation = -barAngle;
               }
            }
         }
      }
      
      public function updateMiniMilestoneRewards() : void
      {
         for(var i:int = 0; i < 6; i++)
         {
            if(this.m_checkMarkMcArray[i])
            {
               this.m_checkMarkMcArray[i].visible = i < 2 ? i + 1 <= this.eventManager.getUserGrantedRewardLevel() : i + 2 <= this.eventManager.getUserGrantedRewardLevel();
            }
         }
         for(i = 0; i < 3; i++)
         {
            if(this.m_buildingCheckmarkMCArray[i])
            {
               this.m_buildingCheckmarkMCArray[i].visible = 3 * (i + 1) <= this.eventManager.getUserGrantedRewardLevel();
            }
         }
         for(i = 0; i < 3; i++)
         {
            if(this.m_chestMcArray[i])
            {
               this.m_chestMcArray[i].visible = true;
               if(3 * (i + 1) <= this.eventManager.getUserGrantedRewardLevel())
               {
                  if(this.m_chestMcArray[i].tooltip)
                  {
                     this.m_chestMcArray[i].detachTooltip();
                  }
                  this.m_chestMcArray[i].gotoAndStop(2);
               }
               else
               {
                  this.m_chestMcArray[i].gotoAndStop(1);
                  this.m_chestFrame[i] = new ZwFrame(this.m_chestMcArray[i]);
                  this.m_chestFrame[i].attachTooltip(new FarmTextTooltip("This treasure chest with-holds buried mysteries and bounties which can make your life full of riches! Reach this milestone to uncover such fortune."));
               }
            }
         }
      }
      
      public function updateGuildBackground() : void
      {
         var curTier:int = this.eventManager.getCurrentTier();
         if(this.m_backgroundMc)
         {
            this.m_backgroundMc.visible = true;
            if(curTier <= 2)
            {
               this.m_backgroundMc.gotoAndStop(curTier + 1);
            }
            else
            {
               this.m_backgroundMc.gotoAndStop(3);
            }
         }
      }
      
      public function updateTaskDoober(taskPt:int = 0) : void
      {
         if(this.m_dooberMc)
         {
            this.m_dooberMc.visible = true;
            if(this.m_dooberCountTf)
            {
               this.m_dooberCountTf.text = "+" + int(taskPt).toString();
            }
            this.m_dooberMc.gotoAndPlay(2);
         }
      }
      
      public function showAutoHideNPCCallouts() : void
      {
         this.m_npcAutoMc.visible = true;
         this.m_npcAutoMc.gotoAndPlay(1);
      }
      
      public function showAutoHideBottomNPCCallouts() : void
      {
         this.m_npc2AutoMc.visible = true;
         this.m_npc2AutoMc.gotoAndPlay(1);
      }
   }
}

