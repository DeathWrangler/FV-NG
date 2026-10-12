package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Managers.FeatureOptionsManager;
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildEventMembersFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildEventMapWindow extends FarmWindow
   {
      
      private static const coopXML:Class = GuildEventMapWindow_coopXML;
      
      public static const featureXML:XML = XML(new coopXML());
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "FVGuild";
      
      private static const WINDOW_PREFIX:String = "guild_main_";
      
      private static const SAGA_MAP_GAP:int = 1050;
      
      private static const SAGA_MAP_HALF_GAP:int = 525;
      
      private static const FINAL_MILESTONE_GAP:int = 1400;
      
      private static const SAGA_MAP_Y_GAP:int = 500;
      
      private var m_featureName:String = null;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private var m_membersFrame:GuildEventMembersFrame;
      
      private var m_guildInfo:Object;
      
      private var m_guildPtInfo:int;
      
      private var m_coop_name_tf:ZwTextField;
      
      private var m_coop_icon_mc:FarmIcon;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_coop_total_cpoints_tf:ZwTextField;
      
      private var m_scroll_mc:MovieClip;
      
      private var m_meterMcArray:Array = [];
      
      private var m_sectionMcArray:Array = [];
      
      private var m_milestoneMcArray:Array = [];
      
      private var m_buildingMcArray:Array = [];
      
      private var m_chestMcArray:Array = [];
      
      private var m_bonusMcArray:Array = [];
      
      private const BUILDING_NAME_ARRAY:Array = [featureXML.child("BUILDING_NAME_ARRAY").child("building1"),featureXML.child("BUILDING_NAME_ARRAY").child("building2"),featureXML.child("BUILDING_NAME_ARRAY").child("building3")];
      
      public var tierMilestoneArray:Array = [0,1050,2100,3500];
      
      private var m_highlightMcArray:Array = [];
      
      private var m_nextBt:ZwButton;
      
      private var m_backBt:ZwButton;
      
      private const FINAL_REWARD_CODE_ARRAY:Array = [featureXML.child("FINAL_REWARD_CODE_ARRAY").child("reward1"),featureXML.child("FINAL_REWARD_CODE_ARRAY").child("reward2"),featureXML.child("FINAL_REWARD_CODE_ARRAY").child("reward3")];
      
      private var m_backgroundMc:MovieClip;
      
      private var m_scrollInitialY:Number;
      
      private var m_pointsIconMc:MovieClip;
      
      private var m_buildingCheckmarkMC:MovieClip;
      
      private var m_checkMarkMc:MovieClip;
      
      private var m_pointsIconFrame:ZwFrame;
      
      private var m_buildingFrame:Array = [];
      
      private var m_sectionFrame:Array = [];
      
      private var m_milestoneFrame:Array = [];
      
      private var m_chestFrame:Array = [];
      
      private var m_passMcArray:Array = [];
      
      private var m_indUp:int = 0;
      
      private var m_indBottom:int = 0;
      
      private var m_ind:int = 0;
      
      public function GuildEventMapWindow(featureName:String, assetUrl:String)
      {
         this.m_featureName = featureName;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var bonusRewardItem:FarmItem = null;
         var rewardItemCode:String = null;
         var rewardFarmItem:FarmItem = null;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         this.m_guildInfo = FeatureOptionsManager.getInstance().getFeatureOption(GuildManager.FEATURE_NAME,GuildManager.TEMP_FO_GUILd_VIEW_INFO);
         this.m_guildPtInfo = int(FeatureOptionsManager.getInstance().getFeatureOption(GuildManager.FEATURE_NAME,GuildEventManager.TEMP_FO_GUILD_OB_POINTS));
         var curTier:int = this.eventManager.getCurrentTier();
         this.m_indUp = curTier;
         this.m_indBottom = curTier;
         this.m_ind = curTier;
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Treasure Map"));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(new ZwTextField(m_window[this.BODY_TF],"Keep collecting Event Points to help your Clan progress and uncover the lost fortune!"));
         }
         if(m_window.hasOwnProperty("name_tf"))
         {
            this.m_coop_name_tf = new ZwTextField(m_window["name_tf"],"name_tf");
            this.m_coop_name_tf.visible = true;
            this.m_coop_name_tf.text = this.m_guildInfo["name"];
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            this.m_coop_icon_mc = new FarmIcon(m_window["icon_mc"],GuildManager.GUILD_LOGO_IMAGE_ARRAY[int(this.m_guildInfo["alias"]) + 1]);
            this.m_coop_icon_mc.visible = true;
         }
         if(m_window.hasOwnProperty("points_tf"))
         {
            this.m_pointsTf = new ZwTextField(m_window["points_tf"],"Your Event Points: " + this.eventManager.getUserPoints().toString());
            this.m_pointsTf.visible = true;
         }
         if(m_window.hasOwnProperty("points_icon_mc"))
         {
            this.m_pointsIconMc = m_window["points_icon_mc"] as MovieClip;
            this.m_pointsIconMc.visible = true;
            this.m_pointsIconFrame = new ZwFrame(this.m_pointsIconMc);
            this.m_pointsIconFrame.attachTooltip(new FarmTextTooltip("Clan Event Score"));
         }
         if(m_window.hasOwnProperty("total_points_tf"))
         {
            this.m_coop_total_cpoints_tf = new ZwTextField(m_window["total_points_tf"],"total_points_tf");
            this.m_coop_total_cpoints_tf.visible = true;
            this.updateGuildPoints();
         }
         if(m_window.hasOwnProperty("scroll_mc"))
         {
            this.m_scroll_mc = m_window["scroll_mc"] as MovieClip;
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
            if(curTier > 0 && curTier < 3)
            {
               this.m_scroll_mc.y += curTier * 500;
            }
         }
         for(i = 0; i < 3; i++)
         {
            if(m_window.hasOwnProperty("section" + (i + 1).toString() + "_mc"))
            {
               this.m_sectionMcArray[i] = m_window["section" + (i + 1).toString() + "_mc"] as MovieClip;
               this.m_sectionMcArray[i].visible = true;
               this.m_sectionFrame[i] = new ZwFrame(this.m_sectionMcArray[i]);
               this.m_sectionFrame[i].attachTooltip(new FarmTextTooltip(this.BUILDING_NAME_ARRAY[i]));
               if(this.m_sectionMcArray[i].hasOwnProperty("bonus_mc"))
               {
                  bonusRewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.FINAL_REWARD_CODE_ARRAY[i]);
                  this.m_bonusMcArray[i] = new FarmIcon(this.m_sectionMcArray[i]["bonus_mc"]);
                  this.m_bonusMcArray[i].loadIcon(bonusRewardItem.iconUrl);
                  this.m_bonusMcArray[i].visible = true;
               }
               if(this.m_sectionMcArray[i].hasOwnProperty("highlight_mc"))
               {
                  this.m_highlightMcArray[i] = this.m_sectionMcArray[i]["highlight_mc"] as MovieClip;
                  this.m_highlightMcArray[i].visible = curTier < 3 ? i == curTier : i == 2;
               }
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
                  this.m_checkMarkMc = this.m_milestoneMcArray[i]["checkmark_mc"] as MovieClip;
                  this.m_checkMarkMc.visible = i + 1 <= this.eventManager.getUserGrantedRewardLevel();
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
                  this.m_buildingCheckmarkMC = this.m_buildingMcArray[i]["checkmark_mc"] as MovieClip;
                  this.m_buildingCheckmarkMC.visible = 3 * (i + 1) <= this.eventManager.getUserGrantedRewardLevel();
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
         if(m_window.hasOwnProperty("next_bt"))
         {
            addWidget(this.m_nextBt = new ZwButton(m_window["next_bt"],this.onNextButtonClick));
            this.m_nextBt.visible = true;
         }
         if(m_window.hasOwnProperty("back_bt"))
         {
            addWidget(this.m_backBt = new ZwButton(m_window["back_bt"],this.onBackButtonClick));
            this.m_backBt.visible = true;
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
         this.updateSagaMap();
      }
      
      override public function close() : void
      {
         if(this.eventManager.m_guildEventMainWindow)
         {
            this.eventManager.m_guildEventMainWindow.untintWindow();
            this.eventManager.m_guildEventMainWindow.enableInput = true;
            this.eventManager.m_guildEventMainWindow.refreshTaskFrame();
            if(GuildEventMainWindow.m_FTUEState == 4)
            {
               ++GuildEventMainWindow.m_FTUEState;
               this.eventManager.m_guildEventMainWindow.resumeFTUEFlow();
            }
         }
         super.close();
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      public function updateGuildPoints() : void
      {
         var points:int = this.eventManager.getGuildPoints();
         if(this.m_coop_total_cpoints_tf)
         {
            this.m_coop_total_cpoints_tf.text = points.toString();
            this.m_coop_total_cpoints_tf.visible = true;
         }
      }
      
      public function updateSagaMap() : void
      {
         var barAngle:Number = NaN;
         var pointDiff:int = 0;
         var normalizedPoints:Number = NaN;
         var curTier:int = this.eventManager.getCurrentTier();
         var points:int = this.eventManager.getGuildPoints();
         if(this.m_scroll_mc)
         {
            this.m_scroll_mc.y = this.m_scrollInitialY;
         }
         for(var i:int = 0; i < 2 * curTier; i++)
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
            if(pointDiff > SAGA_MAP_HALF_GAP)
            {
               if(this.m_meterMcArray[2 * curTier].fill_mc)
               {
                  this.m_meterMcArray[2 * curTier].fill_mc.rotation = -180;
               }
               if(this.m_meterMcArray[2 * curTier + 1].fill_mc)
               {
                  barAngle = (pointDiff - SAGA_MAP_HALF_GAP) * 180 / SAGA_MAP_HALF_GAP;
                  this.m_meterMcArray[2 * curTier + 1].fill_mc.rotation = -barAngle;
               }
            }
            else if(this.m_meterMcArray[2 * curTier].fill_mc)
            {
               barAngle = pointDiff * 180 / SAGA_MAP_HALF_GAP;
               this.m_meterMcArray[2 * curTier].fill_mc.rotation = -barAngle;
            }
         }
      }
      
      private function onNextButtonClick(event:Event) : void
      {
         var i:int = 0;
         if(this.m_scroll_mc)
         {
            if(this.m_scroll_mc.y < 85)
            {
               this.m_scroll_mc.y += 500;
            }
            if(this.m_ind < 2)
            {
               for(i = 0; i < this.m_ind + 1; i++)
               {
                  this.m_highlightMcArray[i].visible = false;
               }
               this.m_highlightMcArray[this.m_ind + 1].visible = true;
               for(i = this.m_ind + 2; i < 3; i++)
               {
                  this.m_highlightMcArray[i].visible = false;
               }
               this.m_ind += 1;
            }
         }
      }
      
      private function onBackButtonClick(event:Event) : void
      {
         var i:int = 0;
         if(this.m_scroll_mc)
         {
            if(this.m_scroll_mc.y > -915)
            {
               this.m_scroll_mc.y -= 500;
            }
            if(this.m_ind > 0)
            {
               for(i = 0; i < this.m_ind - 1; i++)
               {
                  this.m_highlightMcArray[i].visible = false;
               }
               this.m_highlightMcArray[this.m_ind - 1].visible = true;
               for(i = this.m_ind; i < 3; i++)
               {
                  this.m_highlightMcArray[i].visible = false;
               }
               --this.m_ind;
            }
         }
      }
   }
}

