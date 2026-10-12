package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LandBundleUnlockFeatureManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LandBundleUnlockFeatureAllTilesFrame;
   import Widgets.Frames.LandBundleUnlockFeatureSelectionMenuFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class LandBundleUnlockFeatureWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const FEATURE_TRACKING:String = "landbundle";
      
      private static const FEATURE_NAME:String = "LandBundleUnlockFeatureWindow";
      
      private static const BONUS_REWARD_NAME:String = "Pack of Farm Essentials";
      
      private var m_featureName:String = null;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private const LAND_BUNDLE_UNLOCK_FEATURE_FTUE_SEEN:String;
      
      private var m_selectionMenuFrame:LandBundleUnlockFeatureSelectionMenuFrame;
      
      private var m_tilesFrame:LandBundleUnlockFeatureAllTilesFrame;
      
      private var m_selectTilesMC:MovieClip;
      
      private var m_selectedTilesMC:MovieClip;
      
      private var m_daysLeftMC:MovieClip;
      
      private var m_bonusRewardMC:MovieClip;
      
      private var m_overlay_mc:MovieClip;
      
      private var m_buyBundle_bt:FarmAnimatedCashButton;
      
      private var m_buyBundle2_bt:FarmAnimatedCashButton;
      
      private var m_deselect_all_bt:FarmAnimatedTextButton;
      
      private var m_before_disc_tf:ZwTextField;
      
      private var m_disc_tf:ZwTextField;
      
      private var m_discounted_tf:ZwTextField;
      
      private var m_timer:Timer;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      public function LandBundleUnlockFeatureWindow(featureName:String = "LandBundleUnlockFeatureWindow", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.LAND_BUNDLE_UNLOCK_FEATURE_FTUE_SEEN = this.manager.CURRENT_FEATURE_WORLD + "_landbundle_ftue_seen";
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var m_bonus_icon_mc:FarmIcon = null;
         var m_all_offer_tf:MovieClip = null;
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"CHOOSE YOUR LAND!"));
         }
         if(m_window.hasOwnProperty("all_selected_tile_item"))
         {
            this.m_selectionMenuFrame = new LandBundleUnlockFeatureSelectionMenuFrame(m_window["all_selected_tile_item"],this,FEATURE_NAME);
            this.m_selectionMenuFrame.setData();
            this.m_selectionMenuFrame.visible = true;
         }
         if(m_window.hasOwnProperty("land_mc"))
         {
            this.m_tilesFrame = new LandBundleUnlockFeatureAllTilesFrame(m_window["land_mc"],this,FEATURE_NAME);
            this.m_tilesFrame.visible = true;
         }
         if(m_window.hasOwnProperty("select_4_mc"))
         {
            this.m_selectTilesMC = m_window["select_4_mc"] as MovieClip;
            this.m_selectTilesMC.visible = true;
            if(this.m_selectTilesMC.hasOwnProperty("buy_bt"))
            {
               addWidget(this.m_buyBundle_bt = new FarmAnimatedCashButton(this.m_selectTilesMC["buy_bt"],"Buy","",null));
               this.m_buyBundle_bt.visible = true;
               this.m_buyBundle_bt.enabled = false;
            }
         }
         if(m_window.hasOwnProperty("selected_4_mc"))
         {
            this.m_selectedTilesMC = m_window["selected_4_mc"] as MovieClip;
            this.m_selectedTilesMC.visible = false;
            if(this.m_selectedTilesMC.hasOwnProperty("before_disc_tf"))
            {
               addWidget(this.m_before_disc_tf = new ZwTextField(this.m_selectedTilesMC["before_disc_tf"],""));
               this.m_before_disc_tf.visible = false;
            }
            if(this.m_selectedTilesMC.hasOwnProperty("disc_tf"))
            {
               addWidget(this.m_disc_tf = new ZwTextField(this.m_selectedTilesMC["disc_tf"],""));
               this.m_disc_tf.visible = false;
            }
            if(this.m_selectedTilesMC.hasOwnProperty("discount_tf"))
            {
               addWidget(this.m_discounted_tf = new ZwTextField(this.m_selectedTilesMC["discount_tf"],""));
               this.m_discounted_tf.visible = false;
            }
            if(this.m_selectedTilesMC.hasOwnProperty("buy2_bt"))
            {
               addWidget(this.m_buyBundle2_bt = new FarmAnimatedCashButton(this.m_selectedTilesMC["buy2_bt"],"Buy","",this.buyTilesCallBack));
               this.m_buyBundle2_bt.visible = false;
               this.m_buyBundle2_bt.enabled = false;
            }
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlay_mc = m_window["overlay_mc"] as MovieClip;
            if(this.m_overlay_mc.hasOwnProperty("text_tf"))
            {
               addWidget(new ZwTextField(this.m_overlay_mc["text_tf"],"Hurray! You own all the tiles in Bora Bora Isles!"));
            }
            this.m_overlay_mc.visible = false;
         }
         if(m_window.hasOwnProperty("deselect_bt"))
         {
            addWidget(this.m_deselect_all_bt = new FarmAnimatedTextButton(m_window["deselect_bt"],"Remove All",this.deselectAllButtonCallback));
            this.m_deselect_all_bt.visible = true;
            this.m_deselect_all_bt.enabled = false;
         }
         if(m_window.hasOwnProperty("daily_clock_mc"))
         {
            this.m_daysLeftMC = m_window["daily_clock_mc"] as MovieClip;
            this.m_daysLeftMC.visible = true;
            if(this.m_daysLeftMC.hasOwnProperty("days_tf"))
            {
               addWidget(new ZwTextField(this.m_daysLeftMC["days_tf"],""));
               this.m_daysLeftMC["days_tf"].visible = true;
            }
         }
         if(m_window.hasOwnProperty("bonus_mc"))
         {
            this.m_bonusRewardMC = m_window["bonus_mc"] as MovieClip;
            this.m_bonusRewardMC.visible = true;
            if(this.m_bonusRewardMC.hasOwnProperty("name_tf"))
            {
               addWidget(new ZwTextField(this.m_bonusRewardMC["name_tf"],"Bonus Reward!"));
               this.m_bonusRewardMC["name_tf"].visible = true;
            }
            m_bonus_icon_mc = new FarmIcon(this.m_bonusRewardMC);
            m_bonus_icon_mc.attachTooltip(new FarmTextTooltip(BONUS_REWARD_NAME));
            m_bonus_icon_mc.visible = true;
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            this.m_tutorial_mc = m_window["tutorial_mc"] as MovieClip;
            this.m_tutorial_frame = addWidget(new ZwFrame(this.m_tutorial_mc),false) as ZwFrame;
            if(this.m_tutorial_mc.hasOwnProperty("okay_bt"))
            {
               this.m_tutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_tutorial_mc["okay_bt"],"Great!",this.howDoesThisWorkFrameSwitch));
               this.m_tutorial_mc["okay_bt"].visible = true;
            }
            this.m_tutorial_mc.visible = false;
         }
         if(m_window.hasOwnProperty("all_offer_tf"))
         {
            m_all_offer_tf = m_window["all_offer_tf"] as MovieClip;
            if(m_all_offer_tf.hasOwnProperty("offer_1_tf"))
            {
               addWidget(new ZwTextField(m_all_offer_tf["offer_1_tf"],"10% off on spend of 1 FC or more!"));
            }
            if(m_all_offer_tf.hasOwnProperty("offer_2_tf"))
            {
               addWidget(new ZwTextField(m_all_offer_tf["offer_2_tf"],"20% off on spend of 250 FC or more!"));
            }
            if(m_all_offer_tf.hasOwnProperty("offer_3_tf"))
            {
               addWidget(new ZwTextField(m_all_offer_tf["offer_3_tf"],"30% off on spend of 400 FC or more!"));
            }
            m_all_offer_tf.visible = true;
         }
         this.refreshAllTilesState();
         this.startTimer();
         if(!Global.player.getSeenFlag(this.LAND_BUNDLE_UNLOCK_FEATURE_FTUE_SEEN))
         {
            Global.player.setSeenFlag(this.LAND_BUNDLE_UNLOCK_FEATURE_FTUE_SEEN);
            this.howDoesThisWorkClick(null);
         }
         if(!this.manager.shouldFeatureContinue() && Boolean(this.m_overlay_mc))
         {
            if(this.manager.allTilesPurchased())
            {
               this.m_overlay_mc["text_tf"].text = "Hurray! You own all the land tiles in Bora Bora Isles!";
            }
            else
            {
               this.m_overlay_mc["text_tf"].text = "Ooh! Looks like you own all the land tile packages!";
            }
            this.m_overlay_mc.visible = true;
         }
      }
      
      private function get manager() : LandBundleUnlockFeatureManager
      {
         return LandBundleUnlockFeatureManager.getInstance(FEATURE_NAME);
      }
      
      private function buyTilesCallBack(e:Event = null) : *
      {
         var tilesList:Array = this.manager.getTileSelectionList();
         this.close();
         this.manager.onBuyBundleClick(tilesList,this.manager.getDiscountedFinalPrice(tilesList));
      }
      
      public function showSelectedTilesMenu() : void
      {
         this.m_selectTilesMC.visible = false;
         this.m_buyBundle2_bt.enabled = true;
         this.m_buyBundle2_bt.visible = true;
         var tilesList:Array = this.manager.getTileSelectionList();
         this.m_buyBundle2_bt.setAmountText(this.manager.getDiscountedFinalPrice(tilesList).toString());
         this.m_before_disc_tf.text = "Before Discount: " + this.manager.getTotalTilesCost().toString() + " FC";
         this.m_selectedTilesMC.visible = true;
         this.m_before_disc_tf.visible = true;
         this.m_disc_tf.text = "Your Discount: " + this.manager.getDiscountPercentage().toString() + "%";
         this.m_disc_tf.visible = true;
         this.m_discounted_tf.text = "Your price: " + this.manager.getDiscountedFinalPrice(tilesList).toString() + " FC!";
         this.m_discounted_tf.visible = true;
      }
      
      public function showSelectTilesMenu() : void
      {
         this.m_selectedTilesMC.visible = false;
         this.m_before_disc_tf.visible = false;
         this.m_disc_tf.visible = false;
         this.m_discounted_tf.visible = false;
         this.m_selectTilesMC.visible = true;
         this.m_buyBundle_bt.enabled = false;
         this.m_buyBundle2_bt.visible = false;
      }
      
      public function refreshTilesMenu() : void
      {
         this.m_selectionMenuFrame.refresh();
      }
      
      public function refreshAllTilesState() : void
      {
         this.m_tilesFrame.refresh();
      }
      
      public function enableRemoveButton() : void
      {
         this.m_deselect_all_bt.enabled = true;
      }
      
      public function disableRemoveButton() : void
      {
         this.m_deselect_all_bt.enabled = false;
      }
      
      public function disselectTileOnLand(tileName:String) : void
      {
         this.m_tilesFrame.onTileUnselect(tileName);
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_tutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_tutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_tutorial_frame.visible = false;
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_tutorial_frame)
         {
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_tutorial_frame.visible = true;
            FarmStatsManager.count(FEATURE_TRACKING,"FTUE","START");
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes && Boolean(this.m_tutorial_frame))
         {
            ++tutorialSceneNumber;
            preSwitchChanges(tutorialSceneNumber);
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            this.m_tutorial_mc.visible = false;
         }
      }
      
      private function deselectAllButtonCallback(e:Event = null) : void
      {
         this.manager.resetSelectedTileList();
         this.refreshTilesMenu();
         this.refreshAllTilesState();
         this.showSelectTilesMenu();
         this.disableRemoveButton();
         FarmStatsManager.count(FEATURE_TRACKING,"tile_remove","all");
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshConnectionTimerText();
      }
      
      private function refreshConnectionTimerText() : void
      {
         this.m_daysLeftMC["days_tf"].text = this.manager.getFeatureEndDaysLeftText();
      }
      
      override public function close() : void
      {
         super.close();
         this.manager.resetSelectedTileList();
         FarmStatsManager.count("LandBundleUnlockFeatureWindow","Main_UI","close_window");
      }
   }
}

