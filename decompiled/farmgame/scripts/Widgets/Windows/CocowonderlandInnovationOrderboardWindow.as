package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class CocowonderlandInnovationOrderboardWindow extends GenericOrderBoardWindow
   {
      
      private static const GAMEPLAY_BT:String = "gameplay_bt";
      
      private const FEATURE_NAME:String = "CocowonderlandInnovation";
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBTITLE_TF:String = "subtitle_tf";
      
      private const MAIN_BG_MC:String = "main_bg_mc";
      
      private const TIMER_MC:String = "timer_mc";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const WHAT_IS_THIS_MC:String = "whatisthis_mc";
      
      private const SIZE_MC:String = "size_mc";
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const OVERLAY_TF:String = "overlay_tf";
      
      private const OVERLAY_BT:String = "overlay_bt";
      
      private const INVENTIONS_MC:String = "inventions_mc";
      
      private const TILE_UNLOCK_MC:String = "tileUnlock_mc";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private var GAMEPLAY_MC:String = "gameplay_mc";
      
      private const COCOLAND_FTUE_FLAG:String = "cocoland_ftue_flag";
      
      private var NUM_TUTORIAL_SCENES:int = 4;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Next","Next","Next","Let’s go!"];
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY_EA:Array = ["Next","Next","Next","Next","Let’s go!"];
      
      private var m_featureName:String = null;
      
      private var m_mainBgMc:MovieClip = null;
      
      private var m_timerMc:MovieClip = null;
      
      private var m_size_Mc:MovieClip = null;
      
      private var m_land_unlock_mc:MovieClip = null;
      
      private var m_coupons_mc:MovieClip = null;
      
      private var m_task_points_mc:MovieClip = null;
      
      private var m_coupon_count_tf:ZwTextField;
      
      private var m_taskPointsTf:ZwTextField;
      
      private var m_tasks_mc:MovieClip = null;
      
      private var m_previewOverlays:Array = [];
      
      private var m_tileMc:ZwFrame;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_unlock_land_Bt:FarmAnimatedTextButton;
      
      private var m_imagepreviewFrame:Array = [];
      
      private var m_isEA:Boolean = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_HOME);
      
      private var m_gamePlayMC:MovieClip;
      
      private var m_activePart:int;
      
      private var m_playGameBT:FarmAnimatedTextButton;
      
      public function CocowonderlandInnovationOrderboardWindow(windowURL:String)
      {
         this.setFTUForEA();
         super(this.FEATURE_NAME,windowURL,this.manager,this.NUM_TUTORIAL_SCENES);
         this.m_featureName = this.FEATURE_NAME;
      }
      
      public function setFTUForEA() : void
      {
         if(this.m_isEA)
         {
            this.NUM_TUTORIAL_SCENES = 5;
         }
      }
      
      private function get manager() : CocowonderlandInnovationManager
      {
         return CocowonderlandInnovationManager.getInstance(this.FEATURE_NAME);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"EARN COUPONS"));
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
            addWidget(new ZwTextField(m_window[this.SUBTITLE_TF],"Collect more coupons from the orderboard tasks!"));
         }
         if(m_window.hasOwnProperty("land_unlock_mc"))
         {
            this.m_land_unlock_mc = m_window.land_unlock_mc as MovieClip;
            this.m_land_unlock_mc.visible = true;
            if(m_window["land_unlock_mc"].hasOwnProperty("unlock_land_bt"))
            {
               addWidget(this.m_unlock_land_Bt = new FarmAnimatedTextButton(m_window["land_unlock_mc"].unlock_land_bt,"Unlock Tiles",this.onTileUnlockOkayButtonClick));
            }
         }
         if(m_window.hasOwnProperty("total_coupons_mc"))
         {
            this.m_coupons_mc = m_window.total_coupons_mc as MovieClip;
            this.m_coupons_mc.visible = true;
            if(m_window["total_coupons_mc"].hasOwnProperty("coupons_counter_tf"))
            {
               addWidget(this.m_coupon_count_tf = new ZwTextField(m_window["total_coupons_mc"].coupons_counter_tf,this.manager.getOrderboardProgress().toString()));
            }
         }
         m_taskFrame.visible = true;
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
         }
         if(!Global.player.getSeenFlag(this.COCOLAND_FTUE_FLAG))
         {
            Global.player.setSeenFlag(this.COCOLAND_FTUE_FLAG);
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
         var timeLeftMs:Number = FarmGameUtil.synchronizedDateToNumber("08/26/2019") - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingDay = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingDay.toString();
         }
         return remainingTime;
      }
      
      override public function refreshWindow() : void
      {
         this.m_coupon_count_tf.text = this.manager.getOrderboardProgress().toString();
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
      
      private function onTileUnlockOkayButtonClick(event:MouseEvent) : void
      {
         this.manager.unlockLandFromOBWindow();
      }
      
      override public function close() : void
      {
         super.close();
         this.manager.mainWindow.untintWindow();
         this.manager.mainWindow.enableInput = true;
         if(isTaskClicked())
         {
            this.manager.mainWindow.close();
         }
         else
         {
            this.manager.mainWindow.refreshWindow();
         }
         this.manager.orderboardWindow = null;
      }
   }
}

