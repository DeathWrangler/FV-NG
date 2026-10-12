package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Managers.GuildEventManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildEventMembersFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import mx.utils.StringUtil;
   
   public class GuildEventDetailWindow extends FarmWindow
   {
      
      private static const coopXML:Class = GuildEventDetailWindow_coopXML;
      
      public static const featureXML:XML = XML(new coopXML());
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "FVGuild";
      
      private static const WINDOW_PREFIX:String = "guild_main_";
      
      private var m_featureName:String = null;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private var m_rewardMcArray:Array = [];
      
      private var m_membersFrame:GuildEventMembersFrame;
      
      private var m_rewardsMc:MovieClip;
      
      private var m_bonusMcArray:Array = [];
      
      private var m_nameTfArray:Array = [];
      
      private const FINAL_REWARD_CODE_ARRAY:Array = [featureXML.child("FINAL_REWARD_CODE_ARRAY").child("reward1"),featureXML.child("FINAL_REWARD_CODE_ARRAY").child("reward2"),featureXML.child("FINAL_REWARD_CODE_ARRAY").child("reward3")];
      
      private var m_highlightMc:MovieClip;
      
      private var m_milestoneMc:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      private const MILESTONEARAYY:Array = [[350,700,1050],[1400,1750,2100],[2567,3033,3500]];
      
      private var m_pointsTf:ZwTextField;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_backgroundMc:MovieClip;
      
      private var m_coop_total_cpoints_tf:ZwTextField;
      
      private var m_hoverMcArray:Array = [];
      
      private var m_rewardHitWidgetArray:Array = [];
      
      private var m_checkmarkRewardMc:MovieClip;
      
      private var m_pointsIconMc:MovieClip;
      
      private var m_pointsIconFrame:ZwFrame;
      
      private var m_lockMc:MovieClip;
      
      public function GuildEventDetailWindow(featureName:String, assetUrl:String)
      {
         this.m_featureName = featureName;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var curTier:int = 0;
         var bonusRewardItem:FarmItem = null;
         var j:int = 0;
         var rewardItemCode:String = null;
         var rewardFarmItem:FarmItem = null;
         var chestIconUrl:String = null;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         curTier = this.eventManager.getCurrentTier();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Event Progress"));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(new ZwTextField(m_window[this.BODY_TF],"BODY_TF"));
         }
         if(m_window.hasOwnProperty("points_icon_mc"))
         {
            this.m_pointsIconMc = m_window["points_icon_mc"] as MovieClip;
            this.m_pointsIconMc.visible = true;
            this.m_pointsIconFrame = new ZwFrame(this.m_pointsIconMc);
            this.m_pointsIconFrame.attachTooltip(new FarmTextTooltip("Clan Event Score"));
         }
         for(var i:int = 0; i < 3; i++)
         {
            if(m_window.hasOwnProperty("hover" + (i + 1).toString() + "_mc"))
            {
               this.m_hoverMcArray[i] = m_window["hover" + (i + 1).toString() + "_mc"] as MovieClip;
               this.m_hoverMcArray[i].visible = false;
            }
         }
         if(m_window.hasOwnProperty("members_mc"))
         {
            this.m_membersFrame = new GuildEventMembersFrame(m_window["members_mc"],this.m_featureName);
            this.m_membersFrame.visible = true;
         }
         if(m_window.hasOwnProperty("rewards_mc"))
         {
            this.m_rewardsMc = m_window["rewards_mc"] as MovieClip;
            this.m_rewardsMc.visible = true;
            for(i = 0; i < 3; i++)
            {
               if(this.m_rewardsMc.hasOwnProperty("reward" + (i + 1).toString() + "_mc"))
               {
                  this.m_rewardMcArray[i] = this.m_rewardsMc["reward" + (i + 1).toString() + "_mc"] as MovieClip;
                  bonusRewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.FINAL_REWARD_CODE_ARRAY[i]);
                  if(this.m_rewardMcArray[i].hasOwnProperty("bonus_mc"))
                  {
                     this.m_bonusMcArray[i] = new FarmIcon(this.m_rewardMcArray[i]["bonus_mc"]);
                     this.m_bonusMcArray[i].loadIcon(bonusRewardItem.iconUrl);
                     this.m_bonusMcArray[i].visible = true;
                  }
                  if(this.m_rewardMcArray[i].hasOwnProperty("hit_area_mc"))
                  {
                     this.m_rewardHitWidgetArray[i] = new ZwFrame(this.m_rewardMcArray[i]["hit_area_mc"] as MovieClip);
                     this.m_rewardHitWidgetArray[i].registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver(i));
                     this.m_rewardHitWidgetArray[i].registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut(i));
                  }
                  if(this.m_rewardMcArray[i].hasOwnProperty("name_tf"))
                  {
                     this.m_nameTfArray[i] = new ZwTextField(this.m_rewardMcArray[i]["name_tf"]);
                     this.m_nameTfArray[i].text = bonusRewardItem.friendlyTitle;
                     this.m_nameTfArray[i].visible = true;
                  }
                  if(this.m_rewardMcArray[i].hasOwnProperty("highlight_mc"))
                  {
                     this.m_highlightMc = this.m_rewardMcArray[i]["highlight_mc"] as MovieClip;
                     this.m_highlightMc.visible = curTier > i;
                  }
                  if(this.m_rewardMcArray[i].hasOwnProperty("lock_mc"))
                  {
                     this.m_lockMc = this.m_rewardMcArray[i]["lock_mc"] as MovieClip;
                     this.m_lockMc.visible = curTier < i;
                  }
                  if(this.m_rewardMcArray[i].hasOwnProperty("checkmark_mc"))
                  {
                     this.m_checkmarkRewardMc = this.m_rewardMcArray[i]["checkmark_mc"] as MovieClip;
                     this.m_checkmarkRewardMc.visible = curTier > i;
                  }
                  for(j = 0; j < 3; j++)
                  {
                     if(this.m_rewardMcArray[i].hasOwnProperty("milestone" + (j + 1).toString() + "_mc"))
                     {
                        rewardItemCode = (this.eventManager.getRewardsForTier(i)[j] as Object).value;
                        rewardFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardItemCode);
                        chestIconUrl = "assets/dialogs/CoopFeature2019_V3/chest{0}_rewards.png";
                        this.m_milestoneMc = this.m_rewardMcArray[i]["milestone" + (j + 1).toString() + "_mc"] as MovieClip;
                        if(this.m_milestoneMc.hasOwnProperty("icon_mc"))
                        {
                           this.m_iconMc = new FarmIcon(this.m_milestoneMc["icon_mc"]);
                           if((j + 1) % 3 == 0 && this.eventManager.getUserGrantedRewardLevel() >= (i + 1) * (j + 1))
                           {
                              this.m_iconMc.loadIcon(StringUtil.substitute(chestIconUrl,i + 1));
                           }
                           else
                           {
                              this.m_iconMc.loadIcon(rewardFarmItem.iconUrl);
                              if((j + 1) % 3 != 0)
                              {
                                 this.attachTooltipToMilestone(this.m_iconMc,rewardFarmItem.friendlyTitle);
                              }
                              else
                              {
                                 this.attachTooltipToMilestone(this.m_iconMc,"This treasure chest with-holds buried mysteries and bounties which can make your life full of riches! Reach this milestone to uncover such fortune.");
                              }
                           }
                           this.m_iconMc.setIconSize(50,50);
                           this.m_iconMc.setSmoothing(true);
                           this.m_iconMc.visible = true;
                        }
                        if(this.m_milestoneMc.hasOwnProperty("points_tf"))
                        {
                           this.m_pointsTf = new ZwTextField(this.m_milestoneMc["points_tf"]);
                           this.m_pointsTf.text = this.MILESTONEARAYY[i][j];
                           this.m_pointsTf.visible = true;
                        }
                        if(this.m_milestoneMc.hasOwnProperty("checkmark_mc"))
                        {
                           this.m_checkmarkMc = this.m_milestoneMc["checkmark_mc"] as MovieClip;
                           this.m_checkmarkMc.visible = 3 * i + j + 1 <= this.eventManager.getUserGrantedRewardLevel();
                        }
                     }
                  }
               }
            }
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
         if(m_window.hasOwnProperty("total_points_tf"))
         {
            this.m_coop_total_cpoints_tf = new ZwTextField(m_window["total_points_tf"],"total_points_tf");
            this.m_coop_total_cpoints_tf.visible = true;
            this.updateGuildPoints();
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
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      private function onMouseOver(index:int) : Function
      {
         return function(event:MouseEvent):void
         {
            if(m_hoverMcArray[index])
            {
               m_hoverMcArray[index].visible = true;
            }
         };
      }
      
      private function onMouseOut(index:int) : Function
      {
         return function(event:MouseEvent):void
         {
            if(m_hoverMcArray[index])
            {
               m_hoverMcArray[index].visible = false;
            }
         };
      }
      
      public function attachTooltipToMilestone(icon:FarmIcon, msg:String) : void
      {
         if(icon.tooltip)
         {
            icon.tooltip.release();
         }
         icon.detachTooltip();
         icon.attachTooltip(new FarmTextTooltip(msg));
      }
      
      override public function close() : void
      {
         var eventManager:GuildEventManager = null;
         eventManager = GuildEventManager.getInstance();
         GuildEventManager.getInstance().m_guildEventDetailWindow = null;
         if(eventManager.m_guildEventMainWindow)
         {
            eventManager.m_guildEventMainWindow.untintWindow();
            eventManager.m_guildEventMainWindow.enableInput = true;
            eventManager.m_guildEventMainWindow.refreshTaskFrame();
            if(GuildEventMainWindow.m_FTUEState == 5)
            {
               GuildEventMainWindow.m_FTUEState = 0;
               eventManager.m_guildEventMainWindow.resumeFTUEFlow();
            }
         }
         super.close();
      }
   }
}

