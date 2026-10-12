package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Engine.Managers.StatsManager;
   import Managers.OrderBoard.DreamWorldInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class DreamWorldInnovationWindow extends GenericOrderBoardWindow
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FTUE_SEEN_FLAG:String = "AlaskaInnovation_Tutorial";
      
      private static const FEATURE_NAME:String = "AlaskaInnovation";
      
      private var m_featureName:String = FEATURE_NAME;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const OVERLAY_TF:String = "overlay_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const METER1_MC:String = "meter1_mc";
      
      private const METER2_MC:String = "meter2_mc";
      
      private const METER3_MC:String = "meter3_mc";
      
      private const METER4_MC:String = "meter4_mc";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const TIMER_MC:String = "timer_mc";
      
      private const FINISH_TF:String = "finish_tf";
      
      private const BUILDING_MC:String = "building_mc";
      
      private const FINISH_BODY_TF:String = "finish_subtext_tf";
      
      private const REWARDS_BT:String = "rewards_bt";
      
      private const BOOST_BT:String = "boost_bt";
      
      private const FINISH_MC:String = "finish_mc";
      
      private const TILE_UNLCOK_MC:String = "tileUnlock_mc";
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Really?!","Okay!","Okay!","Okay!","Okay!","Awesome!","Awesome!"];
      
      private const NPC1:String = "npc1";
      
      private const NPC2:String = "npc2";
      
      private const NPC3:String = "npc3";
      
      private const NPC4:String = "npc4";
      
      private const PROFILE_MC:String = "profile_mc";
      
      private const PREVIEW1_MC:String = "preview1_mc";
      
      private const PREVIEW2_MC:String = "preview2_mc";
      
      private const PREVIEW3_MC:String = "preview3_mc";
      
      private const REWARD1_MC:String = "reward1_mc";
      
      private const REWARD2_MC:String = "reward2_mc";
      
      private const REWARD3_MC:String = "reward3_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const TEXT_TITLE:String = "_title";
      
      private const TEXT_BODY:String = "_description";
      
      private const TEXT_FINISH_TITLE:String = "_finish_title";
      
      private const TEXT_FINISH_BODY:String = "_finish_description";
      
      private const TEXT_POSTFINISH_TITLE:String = "_postfinish_title";
      
      private const TEXT_POSTFINISH_BODY:String = "_postfinish_description";
      
      private const TEXT_REWARDS_BT:String = "_rewards_button";
      
      private const TEXT_POSTFINISH_BTN:String = "_post_rewards_button";
      
      private const TEXT_BOOST_BT:String = "_boost_button";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var m_meter1_mc:MovieClip;
      
      private var m_meter2_mc:MovieClip;
      
      private var m_meter3_mc:MovieClip;
      
      private var m_meter4_mc:MovieClip;
      
      private var m_timer_mc:MovieClip;
      
      private var m_profile_mc:MovieClip;
      
      private var m_player_icon:FarmIcon;
      
      private var m_npc1:ZwFrame;
      
      private var m_npc2:ZwFrame;
      
      private var m_npc3:ZwFrame;
      
      private var m_npc4:ZwFrame;
      
      private var m_preview1_mc:ZwFrame;
      
      private var m_preview2_mc:ZwFrame;
      
      private var m_preview3_mc:ZwFrame;
      
      private var m_reward1_mc:MovieClip;
      
      private var m_reward2_mc:MovieClip;
      
      private var m_reward3_mc:MovieClip;
      
      private var m_descriptionTf:ZwTextField;
      
      private var m_finishTitle:ZwTextField;
      
      private var m_finishBody:ZwTextField;
      
      private var m_finishMc:MovieClip;
      
      protected var m_tileUnlock:ZwFrame = null;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 600;
      
      private const NPC_WIDTH_X:int = 124;
      
      private const MAX_POINT:int = 1000;
      
      private var m_isEA:Boolean;
      
      private var m_boostBt:FarmAnimatedButton;
      
      private const TEXT_REWARD1_HOVER:String = "Earn 100 Points";
      
      private const TEXT_REWARD2_HOVER:String = "Earn 300 Points";
      
      private const TEXT_REWARD3_HOVER:String = "Earn 600 Points";
      
      private const TEXT_NPC1_NAME:String = "Barbra";
      
      private const TEXT_NPC2_NAME:String = "Claire";
      
      private const TEXT_NPC3_NAME:String = "Kimberly";
      
      private const TEXT_PLAYER_NAME:String = "You";
      
      public function DreamWorldInnovationWindow(featureBuiilding:FeatureBuilding = null)
      {
         var managerObject:Object = this.manager;
         var dialogURL:String = this.manager.getDialogUrl();
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ALASKA);
         var totalScenes:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,dialogURL,managerObject,totalScenes);
      }
      
      override protected function postLoadComplete() : void
      {
         var showTileUnlockMc:Number = NaN;
         var boostPoints:Number = NaN;
         var iconUrl:String = null;
         var floatBuildingIcon:FarmIcon = null;
         var Url:String = null;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ALASKA);
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            this.m_descriptionTf = addWidget(new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY))) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.FINISH_TF))
         {
            addWidget(this.m_finishTitle = new ZwTextField(m_window[this.FINISH_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_TITLE)));
         }
         if(m_window.hasOwnProperty(this.FINISH_BODY_TF))
         {
            addWidget(this.m_finishBody = new ZwTextField(m_window[this.FINISH_BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_BODY)));
         }
         if(m_window.hasOwnProperty(this.REWARDS_BT))
         {
            if(this.manager.getRewardBuildingName() != null && this.manager.getRewardBuildingName() != "0")
            {
               addWidget(new FarmAnimatedTextButton(m_window[this.REWARDS_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_POSTFINISH_BTN),this.onClickRewardsButton));
               this.m_finishBody.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_POSTFINISH_BODY);
               this.m_finishTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_POSTFINISH_TITLE);
            }
            else
            {
               addWidget(new FarmAnimatedTextButton(m_window[this.REWARDS_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_REWARDS_BT),this.onClickRewardsButton));
            }
         }
         if(m_window.hasOwnProperty(this.BOOST_BT))
         {
            addWidget(this.m_boostBt = new FarmAnimatedTextButton(m_window[this.BOOST_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BOOST_BT),this.onClickBoostButton));
            if(this.manager.isAllTilesUnlocked() || this.manager.isFinalRewardChosen())
            {
               this.m_boostBt.visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.TIMER_TF))
         {
            addWidget(new ZwTextField(m_window[this.TIMER_TF],this.getTimeLeft()));
         }
         if(m_window.hasOwnProperty(this.TIMER_MC))
         {
            this.m_timer_mc = m_window[this.TIMER_MC] as MovieClip;
            this.m_timer_mc.visible = true;
            addWidget(new ZwTextField(this.m_timer_mc[this.TIMER_TF],this.getTimeLeft()));
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.TILE_UNLCOK_MC))
         {
            showTileUnlockMc = 0;
            showTileUnlockMc = this.manager.showTileUnlockCountMc();
            this.m_tileUnlock = addWidget(new ZwFrame(m_window[this.TILE_UNLCOK_MC]),true) as ZwFrame;
            if(m_window[this.TILE_UNLCOK_MC].unlock_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.tileUnlock_mc.unlock_bt,"Thanks!",this.onTileUnlockOkayButtonClick));
            }
            if(m_window[this.TILE_UNLCOK_MC][this.OVERLAY_TF])
            {
               addWidget(new ZwTextField(m_window[this.TILE_UNLCOK_MC][this.OVERLAY_TF],"Congratulations!"));
            }
            if(m_window[this.TILE_UNLCOK_MC][this.DESCRIPTION_TF])
            {
               boostPoints = this.manager.TILE_UNLOCK_POINTS * showTileUnlockMc;
               if(showTileUnlockMc > 1)
               {
                  addWidget(new ZwTextField(m_window[this.TILE_UNLCOK_MC][this.DESCRIPTION_TF],"You have been granted " + boostPoints + " scout cookie points for unlocking " + showTileUnlockMc + " tiles!"));
               }
               else if(showTileUnlockMc == 1)
               {
                  addWidget(new ZwTextField(m_window[this.TILE_UNLCOK_MC][this.DESCRIPTION_TF],"You have been granted " + boostPoints + " scout cookie points for unlocking " + showTileUnlockMc + " tile!"));
               }
            }
            if(!showTileUnlockMc)
            {
               this.m_tileUnlock.visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.METER1_MC))
         {
            this.m_meter1_mc = m_window[this.METER1_MC];
            this.initializeMeterMC(this.m_meter1_mc);
         }
         if(m_window.hasOwnProperty(this.METER2_MC))
         {
            this.m_meter2_mc = m_window[this.METER2_MC];
            this.initializeMeterMC(this.m_meter2_mc);
         }
         if(m_window.hasOwnProperty(this.METER3_MC))
         {
            this.m_meter3_mc = m_window[this.METER3_MC];
            this.initializeMeterMC(this.m_meter3_mc);
         }
         if(m_window.hasOwnProperty(this.METER4_MC))
         {
            this.m_meter4_mc = m_window[this.METER4_MC];
            this.initializeMeterMC(this.m_meter4_mc);
         }
         if(m_window.hasOwnProperty(this.NPC1))
         {
            addWidget(this.m_npc1 = new ZwFrame(m_window[this.NPC1]),true);
            this.m_npc1.visible = true;
            this.m_npc1.attachTooltip(new FarmTextTooltip(this.TEXT_PLAYER_NAME));
            m_window[this.NPC1].visible = true;
            if(m_window[this.NPC1].hasOwnProperty(this.PROFILE_MC))
            {
               this.m_player_icon = addWidget(new FarmIcon(m_window[this.NPC1].profile_mc)) as FarmIcon;
               this.m_player_icon.setIconSize(ICON_SIZE,ICON_SIZE);
               this.m_player_icon.setSmoothing(true);
               iconUrl = Global.player.picture;
               this.m_player_icon.loadIcon(iconUrl);
               this.m_player_icon.visible = true;
            }
         }
         if(m_window.hasOwnProperty(this.NPC2))
         {
            addWidget(this.m_npc2 = new ZwFrame(m_window[this.NPC2]),true);
            this.m_npc2.attachTooltip(new FarmTextTooltip(this.TEXT_NPC1_NAME));
         }
         if(m_window.hasOwnProperty(this.NPC3))
         {
            addWidget(this.m_npc3 = new ZwFrame(m_window[this.NPC3]),true);
            this.m_npc3.attachTooltip(new FarmTextTooltip(this.TEXT_NPC2_NAME));
         }
         if(m_window.hasOwnProperty(this.NPC4))
         {
            addWidget(this.m_npc4 = new ZwFrame(m_window[this.NPC4]),true);
            this.m_npc4.attachTooltip(new FarmTextTooltip(this.TEXT_NPC3_NAME));
         }
         if(m_window.hasOwnProperty(this.PREVIEW1_MC))
         {
            addWidget(this.m_preview1_mc = new ZwFrame(m_window[this.PREVIEW1_MC]),true);
            this.m_preview1_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver1);
            this.m_preview1_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut1);
            if(!this.manager.isFirstMilestoneAchieved())
            {
               this.m_preview1_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD1_HOVER));
            }
         }
         if(m_window.hasOwnProperty(this.PREVIEW2_MC))
         {
            addWidget(this.m_preview2_mc = new ZwFrame(m_window[this.PREVIEW2_MC]),true);
            this.m_preview2_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver2);
            this.m_preview2_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut2);
            if(!this.manager.isSecondMilestoneAchieved())
            {
               this.m_preview2_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD2_HOVER));
            }
         }
         if(m_window.hasOwnProperty(this.PREVIEW3_MC))
         {
            addWidget(this.m_preview3_mc = new ZwFrame(m_window[this.PREVIEW3_MC]),true);
            this.m_preview3_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver3);
            this.m_preview3_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut3);
            if(!this.manager.isThirdMilestoneAchieved())
            {
               this.m_preview3_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD3_HOVER));
            }
         }
         if(m_window.hasOwnProperty(this.REWARD1_MC))
         {
            this.m_reward1_mc = m_window[this.REWARD1_MC] as MovieClip;
         }
         if(m_window.hasOwnProperty(this.REWARD2_MC))
         {
            this.m_reward2_mc = m_window[this.REWARD2_MC] as MovieClip;
         }
         if(m_window.hasOwnProperty(this.REWARD3_MC))
         {
            this.m_reward3_mc = m_window[this.REWARD3_MC] as MovieClip;
         }
         if(m_window.hasOwnProperty(this.FINISH_MC))
         {
            this.m_finishMc = m_window[this.FINISH_MC] as MovieClip;
         }
         this.manager.npcmovements();
         if(Boolean(this.m_tileUnlock) && !this.m_tileUnlock.visible)
         {
            this.NPCMovement();
         }
         if(m_window.hasOwnProperty(this.BUILDING_MC))
         {
            floatBuildingIcon = addWidget(new FarmIcon(m_window[this.BUILDING_MC])) as FarmIcon;
            floatBuildingIcon.setIconSize(150,150);
            floatBuildingIcon.setSmoothing(true);
            Url = this.manager.getBuildingCurrentAsset();
            floatBuildingIcon.loadIcon(Url);
            floatBuildingIcon.visible = true;
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
      }
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         if(this.m_isEA)
         {
            if(sceneNumber == 3)
            {
               tutorialSceneNumber = sceneNumber + 1;
            }
         }
         else if(sceneNumber == 4)
         {
            tutorialSceneNumber = sceneNumber + 1;
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            this.preSwitchChanges(tutorialSceneNumber);
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            hideTutorial();
         }
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
      }
      
      private function initializeMeterMC(meter_mc:MovieClip) : void
      {
         if(meter_mc)
         {
            meter_mc.visible = true;
            this.updateProgressBar(0,meter_mc);
            if(meter_mc[this.POINTS_TF])
            {
               (meter_mc[this.POINTS_TF] as TextField).visible = true;
               (meter_mc[this.POINTS_TF] as TextField).text = "000";
            }
         }
      }
      
      private function updateProgressBar(percentValue:Number, meter_mc:MovieClip) : void
      {
         if(percentValue > this.MAX_POINT)
         {
            percentValue = this.MAX_POINT;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(meter_mc.bar_fill_mc)
         {
            if(percentValue == 0)
            {
               (meter_mc.bar_fill_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(meter_mc.bar_fill_mc,2,{"width":barWidth});
            }
         }
         if(meter_mc[this.POINTS_TF])
         {
            (meter_mc[this.POINTS_TF] as TextField).text = int(percentValue).toString();
         }
      }
      
      private function moveNPCByProgress(percentValue:Number, npc:ZwFrame) : void
      {
         if(percentValue > this.MAX_POINT)
         {
            percentValue = this.MAX_POINT;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         npc.x = this.NPC_WIDTH_X + barWidth;
      }
      
      public function NPCMovement() : void
      {
         this.updateProgressBar(this.manager.getNPCProgress(),this.m_meter1_mc);
         this.moveNPCByProgress(this.manager.getNPCProgress(),this.m_npc1);
         this.updateProgressBar(this.manager.getNPC1Progress(),this.m_meter2_mc);
         this.moveNPCByProgress(this.manager.getNPC1Progress(),this.m_npc2);
         this.updateProgressBar(this.manager.getNPC2Progress(),this.m_meter3_mc);
         this.moveNPCByProgress(this.manager.getNPC2Progress(),this.m_npc3);
         this.updateProgressBar(this.manager.getNPC3Progress(),this.m_meter4_mc);
         this.moveNPCByProgress(this.manager.getNPC3Progress(),this.m_npc4);
         if(this.manager.getNPCProgress() < this.MAX_POINT && !this.m_tileUnlock.visible)
         {
            this.manager.showOtherNPCFinalRewardTaken();
            this.manager.grantMilestoneReward();
         }
         else
         {
            m_taskFrame.visible = false;
            this.m_descriptionTf.visible = false;
            this.m_finishMc.visible = true;
            this.m_finishMc.gotoAndStop(this.manager.getPlayerPosition());
            if(!this.manager.isFinalRewardChosen())
            {
               close();
               this.manager.grantFinalReward();
            }
         }
      }
      
      private function onOver1(evt:MouseEvent) : void
      {
         var gotoFrame:int = this.m_isEA ? 2 : 1;
         this.m_reward1_mc.visible = true;
         this.m_reward1_mc.gotoAndStop(gotoFrame);
         this.m_reward1_mc.tick_mc.visible = this.manager.isFirstMilestoneAchieved();
      }
      
      private function onOut1(evt:MouseEvent) : void
      {
         this.m_reward1_mc.visible = false;
      }
      
      private function onOver2(evt:MouseEvent) : void
      {
         var gotoFrame:int = this.m_isEA ? 2 : 1;
         this.m_reward2_mc.visible = true;
         this.m_reward2_mc.gotoAndStop(gotoFrame);
         this.m_reward2_mc.tick_mc.visible = this.manager.isSecondMilestoneAchieved();
      }
      
      private function onOut2(evt:MouseEvent) : void
      {
         this.m_reward2_mc.visible = false;
      }
      
      private function onOver3(evt:MouseEvent) : void
      {
         var gotoFrame:int = this.m_isEA ? 2 : 1;
         this.m_reward3_mc.visible = true;
         this.m_reward3_mc.gotoAndStop(gotoFrame);
         this.m_reward3_mc.tick_mc.visible = this.manager.isThirdMilestoneAchieved();
      }
      
      private function onOut3(evt:MouseEvent) : void
      {
         this.m_reward3_mc.visible = false;
      }
      
      private function onClickRewardsButton(evt:Event) : void
      {
         if(this.manager.getRewardBuildingName() != null && this.manager.getRewardBuildingName() != "0")
         {
            StatsManager.count(this.m_featureName,"ViewFloat");
            this.manager.panToBuilding(this.manager.getRewardBuildingName());
         }
         else
         {
            StatsManager.count(this.m_featureName,"ViewRewards");
            this.manager.showRewardsUI(this);
            tintWindow();
            enableInput = false;
         }
      }
      
      private function onClickBoostButton(evt:Event) : void
      {
         tintWindow();
         enableInput = false;
         this.manager.showBoostUI(this);
      }
      
      private function getTimeLeft() : String
      {
         var timeRemaining:Array = this.manager.getTimeRemaining();
         var timeLeft:String = "";
         if(parseInt(timeRemaining[0]) > 1)
         {
            timeLeft = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftDays",{"time":timeRemaining[0]});
         }
         else
         {
            timeLeft = HUD.getformattedTimeLeftFromArray(timeRemaining);
         }
         return timeLeft;
      }
      
      private function get manager() : DreamWorldInnovationManager
      {
         return DreamWorldInnovationManager.getInstance(FEATURE_NAME);
      }
      
      private function onTileUnlockOkayButtonClick(event:MouseEvent) : void
      {
         this.m_tileUnlock.visible = false;
         this.manager.addTileFeatureOptions();
         this.NPCMovement();
      }
   }
}

