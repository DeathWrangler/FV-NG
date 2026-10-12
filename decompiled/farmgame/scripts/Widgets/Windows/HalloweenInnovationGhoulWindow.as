package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Engine.Managers.StatsManager;
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.HalloweenInnovationGhoulConsumableFrame;
   import Widgets.Frames.HalloweenInnovationGhoulInventionPreviewFrame;
   import Widgets.Frames.HalloweenInnovationGhoulInventionSlotsFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class HalloweenInnovationGhoulWindow extends GenericOrderBoardWindow
   {
      
      private static const GAMEPLAY_BT:String = "gameplay_bt";
      
      private static const PREVIEW_OVERLAY0_MC:String = "previewOverlay0_mc";
      
      private static const PREVIEW_OVERLAY1_MC:String = "previewOverlay1_mc";
      
      private static const PREVIEW_OVERLAY2_MC:String = "previewOverlay2_mc";
      
      private static const PREVIEW_OVERLAY3_MC:String = "previewOverlay3_mc";
      
      private const FEATURE_NAME:String = "HalloweenInnovationGhoul";
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBTITLE_TF:String = "subtitle_tf";
      
      private const MAIN_BG_MC:String = "main_bg_mc";
      
      private const TIMER_MC:String = "timer_mc";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const WHAT_IS_THIS_MC:String = "whatisthis_mc";
      
      private const SIZE_MC:String = "size_mc";
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const IMAGE_PREVIEW0_MC:String = "imagepreview0_mc";
      
      private const IMAGE_PREVIEW1_MC:String = "imagepreview1_mc";
      
      private const IMAGE_PREVIEW2_MC:String = "imagepreview2_mc";
      
      private const IMAGE_PREVIEW3_MC:String = "imagepreview3_mc";
      
      private const OVERLAY_TF:String = "overlay_tf";
      
      private const OVERLAY_BT:String = "overlay_bt";
      
      private const INVENTIONS_MC:String = "inventions_mc";
      
      private const TILE_UNLOCK_MC:String = "tileUnlock_mc";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private var GAMEPLAY_MC:String = "gameplay_mc";
      
      private const HALLOWEEN_GHOUL_FTUE_FLAG:String = "halloween_ghoul_ftue_flag";
      
      private var NUM_TUTORIAL_SCENES:int = 4;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Next","Next","Next","Let’s go!"];
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY_EA:Array = ["Next","Next","Next","Next","Let’s go!"];
      
      private var m_featureName:String = null;
      
      private var m_mainBgMc:MovieClip = null;
      
      private var m_timerMc:MovieClip = null;
      
      private var m_size_Mc:MovieClip = null;
      
      private var m_previewOverlays:Array = [];
      
      private var m_tileMc:ZwFrame;
      
      private var m_consumableFrame:HalloweenInnovationGhoulConsumableFrame = null;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_imagepreviewFrame:Array = [];
      
      private var m_inventionsSlotsFrame:HalloweenInnovationGhoulInventionSlotsFrame;
      
      private var m_isEA:Boolean = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_HALLOWEENMAD);
      
      private var m_gamePlayMC:MovieClip;
      
      private var m_activeInvention:int;
      
      private var m_activePart:int;
      
      private var m_playGameBT:FarmAnimatedTextButton;
      
      public function HalloweenInnovationGhoulWindow()
      {
         this.setFTUForEA();
         super(this.FEATURE_NAME,this.manager.getDialogUrl(),this.manager,this.NUM_TUTORIAL_SCENES);
         this.m_featureName = this.FEATURE_NAME;
         this.loadGameProgress();
      }
      
      private function loadGameProgress() : void
      {
         var inventionData:Object = this.manager.getActiveGameData();
         this.m_activeInvention = inventionData.activeInvention;
         this.m_activePart = inventionData.activePart;
      }
      
      public function setFTUForEA() : void
      {
         if(this.m_isEA)
         {
            this.NUM_TUTORIAL_SCENES = 5;
         }
      }
      
      private function get manager() : HalloweenInnovationGhoulManager
      {
         return HalloweenInnovationGhoulManager.getInstance(this.FEATURE_NAME);
      }
      
      override protected function postLoadComplete() : void
      {
         var boostPoints:Number = NaN;
         var inventionSlotsData:Object = null;
         var activeInvention:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Marble’s Mad Machine"));
         }
         if(m_window.hasOwnProperty(this.MAIN_BG_MC))
         {
            this.m_mainBgMc = m_window.main_bg_mc as MovieClip;
            this.m_mainBgMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.WHAT_IS_THIS_MC))
         {
            addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window[this.WHAT_IS_THIS_MC],"",this.onHowDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.SIZE_MC))
         {
            this.m_size_Mc = m_window.size_mc as MovieClip;
            this.m_size_Mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.SUBTITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.SUBTITLE_TF],"Collect Firebolts to uncover parts of the decorative inventions!"));
         }
         if(m_window.hasOwnProperty(this.TIMER_MC))
         {
            this.m_timerMc = m_window.timer_mc as MovieClip;
            if(this.m_timerMc.hasOwnProperty(this.TIMER_TF))
            {
               addWidget(new ZwTextField(this.m_timerMc[this.TIMER_TF],this.getTimeLeft()));
            }
            this.m_timerMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.TILE_UNLOCK_MC))
         {
            this.m_tileMc = addWidget(new ZwFrame(m_window[this.TILE_UNLOCK_MC]),true) as ZwFrame;
            if(m_window[this.TILE_UNLOCK_MC][this.OVERLAY_BT])
            {
               addWidget(new FarmAnimatedTextButton(m_window[this.TILE_UNLOCK_MC][this.OVERLAY_BT],"Cool!",this.onTileUnlockOkayButtonClick));
            }
            if(m_window[this.TILE_UNLOCK_MC][this.OVERLAY_TF])
            {
               addWidget(new ZwTextField(m_window[this.TILE_UNLOCK_MC][this.OVERLAY_TF],"Congratulations!"));
            }
            boostPoints = this.manager.TILE_UNLOCK_POINTS * this.manager.unlockedTilesCountCurrent();
            if(m_window[this.TILE_UNLOCK_MC][this.DESCRIPTION_TF])
            {
               addWidget(new ZwTextField(m_window[this.TILE_UNLOCK_MC][this.DESCRIPTION_TF],"You got " + boostPoints + " free firebolts for unlocking tiles!"));
            }
            if(!boostPoints)
            {
               StatsManager.count(this.m_featureName,"UnlockTile","Click","","50",(50 + this.manager.getOrderboardProgress()).toString());
               this.m_tileMc.visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.GAMEPLAY_MC))
         {
            this.m_gamePlayMC = m_window.gameplay_mc as MovieClip;
            if(this.m_gamePlayMC.hasOwnProperty(this.DESCRIPTION_TF))
            {
               new ZwTextField(this.m_gamePlayMC[this.DESCRIPTION_TF],"Discover parts for your invention here!");
            }
            if(this.m_gamePlayMC.hasOwnProperty(GAMEPLAY_BT))
            {
               this.m_playGameBT = new FarmAnimatedTextButton(this.m_gamePlayMC[GAMEPLAY_BT],"Play",this.onPlayBtnClick);
            }
            if(this.m_gamePlayMC.hasOwnProperty(this.TITLE_TF))
            {
               new ZwTextField(this.m_gamePlayMC[this.TITLE_TF],"Marble’s Lab");
            }
            this.m_playGameBT.enabled = this.m_activeInvention <= this.manager.FINAL_INVENTION;
            this.m_gamePlayMC.visible = true;
         }
         if(m_window.hasOwnProperty(this.CONSUMABLE_MC))
         {
            this.m_consumableFrame = new HalloweenInnovationGhoulConsumableFrame(m_window[this.CONSUMABLE_MC],this.m_featureName,this.manager,"mainWindow");
            this.m_consumableFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.IMAGE_PREVIEW0_MC))
         {
            this.m_imagepreviewFrame.push(new HalloweenInnovationGhoulInventionPreviewFrame(m_window[this.IMAGE_PREVIEW0_MC],this.m_featureName,this.manager,0));
         }
         if(m_window.hasOwnProperty(this.IMAGE_PREVIEW1_MC))
         {
            this.m_imagepreviewFrame.push(new HalloweenInnovationGhoulInventionPreviewFrame(m_window[this.IMAGE_PREVIEW1_MC],this.m_featureName,this.manager,1));
         }
         if(m_window.hasOwnProperty(this.IMAGE_PREVIEW2_MC))
         {
            this.m_imagepreviewFrame.push(new HalloweenInnovationGhoulInventionPreviewFrame(m_window[this.IMAGE_PREVIEW2_MC],this.m_featureName,this.manager,2));
         }
         if(m_window.hasOwnProperty(this.IMAGE_PREVIEW3_MC))
         {
            this.m_imagepreviewFrame.push(new HalloweenInnovationGhoulInventionPreviewFrame(m_window[this.IMAGE_PREVIEW3_MC],this.m_featureName,this.manager,3));
         }
         if(m_window.hasOwnProperty(this.INVENTIONS_MC))
         {
            inventionSlotsData = this.manager.getFeatureOptionsKey(this.manager.GAME_INVENTIONS_KEY);
            activeInvention = this.manager.decryptData(inventionSlotsData.activeInvention);
            this.m_inventionsSlotsFrame = new HalloweenInnovationGhoulInventionSlotsFrame(m_window[this.INVENTIONS_MC],this.m_featureName,this.manager,activeInvention);
            if(m_window[this.INVENTIONS_MC].hasOwnProperty(PREVIEW_OVERLAY0_MC))
            {
               this.m_previewOverlays.push(m_window[this.INVENTIONS_MC].previewOverlay0_mc as MovieClip);
            }
            if(m_window[this.INVENTIONS_MC].hasOwnProperty(PREVIEW_OVERLAY1_MC))
            {
               this.m_previewOverlays.push(m_window[this.INVENTIONS_MC].previewOverlay1_mc as MovieClip);
            }
            if(m_window[this.INVENTIONS_MC].hasOwnProperty(PREVIEW_OVERLAY2_MC))
            {
               this.m_previewOverlays.push(m_window[this.INVENTIONS_MC].previewOverlay2_mc as MovieClip);
            }
            if(m_window[this.INVENTIONS_MC].hasOwnProperty(PREVIEW_OVERLAY3_MC))
            {
               this.m_previewOverlays.push(m_window[this.INVENTIONS_MC].previewOverlay3_mc as MovieClip);
            }
            this.m_inventionsSlotsFrame.visible = true;
         }
         if(!Global.player.getSeenFlag(this.HALLOWEEN_GHOUL_FTUE_FLAG))
         {
            Global.player.setSeenFlag(this.HALLOWEEN_GHOUL_FTUE_FLAG);
            this.showTutorial();
         }
      }
      
      private function getTimeLeft() : String
      {
         var timeRemaining:Array = this.getFeatureExpiryTimeOnWall();
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
      
      public function getFeatureExpiryTimeOnWall() : Array
      {
         var remainingDay:int = 0;
         var timeLeftMs:Number = FarmGameUtil.synchronizedDateToNumber("11/27/2018") - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingDay = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingDay.toString();
         }
         return remainingTime;
      }
      
      private function onPlayBtnClick(event:Event) : void
      {
         this.manager.showGameUI();
      }
      
      override public function refreshWindow() : void
      {
         this.m_inventionsSlotsFrame.refresh();
         this.m_consumableFrame.refresh();
         this.loadGameProgress();
         this.m_playGameBT.enabled = this.m_activeInvention <= this.manager.FINAL_INVENTION;
      }
      
      public function refreshConsumableFrame() : void
      {
         this.m_consumableFrame.refresh();
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            preSwitchChanges(tutorialSceneNumber);
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            hideTutorial();
         }
         if(this.m_isEA)
         {
            tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY_EA[tutorialSceneNumber - 1];
         }
         else
         {
            tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
         }
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         if(this.m_isEA)
         {
            tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY_EA[tutorialSceneNumber - 1];
         }
         else
         {
            tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
         }
      }
      
      private function addOverlays(index:int) : void
      {
         var i:int = 0;
         while(i < this.m_previewOverlays.length)
         {
            this.m_previewOverlays[i].visible = i != index;
            i++;
         }
      }
      
      private function removeOverlays() : void
      {
         var i:int = 0;
         while(i < this.m_previewOverlays.length)
         {
            this.m_previewOverlays[i].visible = false;
            i++;
         }
      }
      
      public function showInventionPreviewFrame(invention:int) : void
      {
         this.m_imagepreviewFrame[invention].visible = true;
         this.addOverlays(invention);
         this.m_imagepreviewFrame[invention].setFrameData(invention);
      }
      
      public function closeInventionPreviewFrame() : void
      {
         for(var i:int = 0; i < 4; i++)
         {
            this.m_imagepreviewFrame[i].visible = false;
         }
         this.removeOverlays();
      }
      
      private function onTileUnlockOkayButtonClick(event:MouseEvent) : void
      {
         this.m_tileMc.visible = false;
         this.refreshWindow();
      }
   }
}

