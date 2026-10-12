package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Breeding.DragonBreedingProgSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.DragonBreedingMacroProgBar;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DragonBreedingProgressWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_PRIZE_MARKERS:int = 6;
      
      private static const PRIZE_MARKER_FRAME_UNLOCKED:int = 1;
      
      private static const PRIZE_MARKER_FRAME_LOCKED:int = 2;
      
      private static const PRIZE_MARKER_ROLLOVER_FRAME_UNLOCKED:int = 3;
      
      private static const PRIZE_MARKER_ROLLOVER_FRAME_LOCKED:int = 4;
      
      private static const PRIZE_MARKER_SIZE:int = 25;
      
      private static const NO_OF_SCENES:int = 3;
      
      private const MAIN_MC:String = "progress_mc";
      
      private const WHAT_IS_THIS:String = "whatisthis_mc";
      
      private const MACRO_METER:String = "macroMeter_mc";
      
      private const BIG_METER:String = "bigMeter_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBTITLE_TF:String = "subtitle_tf";
      
      private var m_featureName:String = "";
      
      private var m_mainMc:MovieClip;
      
      private var m_whatIsThis_mc:FarmAnimatedButton;
      
      protected var m_skillState:DragonBreedingSkillState = null;
      
      private var m_macroProgressBar:DragonBreedingMacroProgBar = null;
      
      private var m_progressSlotContainerFrame:DragonBreedingProgSlotContainerFrame = null;
      
      private var m_prizeMarkerWidgets:Array = new Array();
      
      private var m_hasNests:Array = new Array();
      
      private var m_closeCallback:Function = null;
      
      private var m_owner:DragonBreedingWindow;
      
      public function DragonBreedingProgressWindow(featureName:String, closeCallback:Function = null, owner:DragonBreedingWindow = null)
      {
         this.m_featureName = featureName;
         this.m_closeCallback = closeCallback;
         this.m_owner = owner;
         var dialogPath:String = DragonBreedingManager.getInstance(this.m_featureName).getProgressDialogURL();
         super(featureName,dialogPath,NO_OF_SCENES);
      }
      
      override protected function postLoadComplete() : void
      {
         var currentLevel:int = 0;
         var gainedXp:int = 0;
         var totalXpNeededPerLevel:int = 0;
         var subtitle:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.MAIN_MC))
         {
            this.m_mainMc = m_window[this.MAIN_MC] as MovieClip;
            this.m_mainMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.WHAT_IS_THIS))
         {
            this.m_whatIsThis_mc = addWidget(new FarmAnimatedButton(m_window[this.WHAT_IS_THIS],this.howDoesThisWorkClick),true) as FarmAnimatedButton;
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_progress_tile")),true);
         }
         if(m_window.hasOwnProperty(this.SUBTITLE_TF))
         {
            currentLevel = DragonBreedingManager.getInstance(this.m_featureName).getPlayerCurrentLevel();
            gainedXp = DragonBreedingManager.getInstance(this.m_featureName).getPlayerCurrentXp();
            totalXpNeededPerLevel = DragonBreedingConfigManager.getInstance(this.m_featureName).getXpForLevel(currentLevel);
            subtitle = "";
            if(currentLevel < DragonBreedingManager.getInstance(this.m_featureName).getMaxProgressLevel())
            {
               subtitle = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_progress_subtitle",{
                  "xp":totalXpNeededPerLevel - gainedXp,
                  "level":currentLevel + 1
               });
            }
            addWidget(new ZwTextField(m_window[this.SUBTITLE_TF],subtitle),true);
         }
         if(this.m_mainMc.hasOwnProperty(this.MACRO_METER))
         {
            this.m_macroProgressBar = new DragonBreedingMacroProgBar(this.m_mainMc[this.MACRO_METER],this.m_featureName);
            addWidget(this.m_macroProgressBar);
         }
         if(this.m_mainMc.hasOwnProperty(this.BIG_METER))
         {
            this.m_progressSlotContainerFrame = new DragonBreedingProgSlotContainerFrame(this.m_mainMc[this.BIG_METER],this.m_featureName);
            addWidget(this.m_progressSlotContainerFrame);
         }
         this.m_skillState = DragonBreedingManager.getInstance(this.m_featureName).getBreedingSkillState();
         this.initializePrizeMarkers();
         this.populatePrizeMarkers();
      }
      
      public function update() : void
      {
         var prizeMarker:ZwFrame = null;
         this.m_macroProgressBar.setupBar();
         this.m_progressSlotContainerFrame.update();
         var prizeInterval:int = DragonBreedingMacroProgBar.NUM_LEVELS_PER_BAR / NUM_PRIZE_MARKERS;
         for(var prizeMarkerIndex:int = 0; prizeMarkerIndex < this.m_prizeMarkerWidgets.length; prizeMarkerIndex++)
         {
            prizeMarker = this.m_prizeMarkerWidgets[prizeMarkerIndex];
            if(Math.floor(this.m_skillState.level / prizeInterval) > prizeMarkerIndex)
            {
               (prizeMarker.element as MovieClip).gotoAndStop(PRIZE_MARKER_FRAME_UNLOCKED);
            }
            else
            {
               (prizeMarker.element as MovieClip).gotoAndStop(PRIZE_MARKER_FRAME_LOCKED);
            }
         }
      }
      
      private function howDoesThisWorkClick(e:Event) : void
      {
         showTutorial();
      }
      
      override protected function release() : void
      {
         var widget:ZwFrame = null;
         for each(widget in this.m_prizeMarkerWidgets)
         {
            (widget.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onPrizeMarkerMouseOver);
            (widget.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onPrizeMarkerMouseOut);
         }
         this.m_prizeMarkerWidgets = null;
         this.m_macroProgressBar = null;
         this.m_skillState = null;
         this.m_progressSlotContainerFrame = null;
         super.release();
      }
      
      private function initializePrizeMarkers() : void
      {
         var prizeInterval:int = 0;
         var prizeMarkerIndex:int = 0;
         var prizeMarker:ZwFrame = null;
         if(this.m_macroProgressBar)
         {
            prizeInterval = DragonBreedingMacroProgBar.NUM_LEVELS_PER_BAR / NUM_PRIZE_MARKERS;
            for(prizeMarkerIndex = 0; prizeMarkerIndex < NUM_PRIZE_MARKERS; prizeMarkerIndex++)
            {
               prizeMarker = new ZwFrame(this.m_mainMc.macroMeter_mc["prize" + prizeMarkerIndex + "_mc"]);
               if(Math.floor(this.m_skillState.level / prizeInterval) > prizeMarkerIndex)
               {
                  (prizeMarker.element as MovieClip).gotoAndStop(PRIZE_MARKER_FRAME_UNLOCKED);
               }
               else
               {
                  (prizeMarker.element as MovieClip).gotoAndStop(PRIZE_MARKER_FRAME_LOCKED);
               }
               (prizeMarker.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onPrizeMarkerMouseOver);
               (prizeMarker.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onPrizeMarkerMouseOut);
               this.m_prizeMarkerWidgets.push(prizeMarker);
               addWidget(prizeMarker);
            }
         }
      }
      
      private function populatePrizeMarkers() : void
      {
         var maxDisplayedLevel:int = 0;
         var prizeLevel:int = 0;
         var rewards:Array = null;
         var reward:Object = null;
         var item:FarmItem = null;
         var prizeMarker:ZwFrame = null;
         var nestMc:MovieClip = null;
         var icon:FarmIcon = null;
         for(var prizeMarkerIndex:int = 0; prizeMarkerIndex < this.m_prizeMarkerWidgets.length; prizeMarkerIndex++)
         {
            maxDisplayedLevel = this.m_macroProgressBar.maxDisplayedLevel;
            prizeLevel = maxDisplayedLevel / NUM_PRIZE_MARKERS * (prizeMarkerIndex + 1);
            rewards = DragonBreedingConfigManager.getInstance(this.m_featureName).getRewardsForLevel(prizeLevel);
            for each(reward in rewards)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
               prizeMarker = this.m_prizeMarkerWidgets[prizeMarkerIndex];
               nestMc = null;
               if(prizeMarker.element.hasOwnProperty("addnest_mc"))
               {
                  nestMc = prizeMarker.element.addnest_mc as MovieClip;
                  nestMc.visible = false;
               }
               if(reward.hasOwnProperty("bigReward") && reward.bigReward == "true")
               {
                  if(item != null)
                  {
                     icon = new FarmIcon(prizeMarker.element.prize_mc,item.iconUrl);
                     icon.setIconSize(PRIZE_MARKER_SIZE,PRIZE_MARKER_SIZE);
                     prizeMarker.addWidget(icon);
                  }
               }
               if(reward.hasOwnProperty("type") && reward["type"] == "breedingslot_unlock")
               {
                  if(nestMc != null)
                  {
                     nestMc.visible = true;
                     this.m_hasNests.push(prizeMarker.element);
                  }
               }
            }
         }
      }
      
      private function onPrizeMarkerMouseOver(event:MouseEvent) : void
      {
         var rollOverMc:MovieClip = event.currentTarget as MovieClip;
         switch(rollOverMc.currentFrame)
         {
            case PRIZE_MARKER_FRAME_LOCKED:
               rollOverMc.gotoAndStop(PRIZE_MARKER_ROLLOVER_FRAME_LOCKED);
               break;
            case PRIZE_MARKER_FRAME_UNLOCKED:
               rollOverMc.gotoAndStop(PRIZE_MARKER_ROLLOVER_FRAME_UNLOCKED);
               break;
            case PRIZE_MARKER_ROLLOVER_FRAME_LOCKED:
               rollOverMc.gotoAndStop(PRIZE_MARKER_ROLLOVER_FRAME_LOCKED);
               break;
            case PRIZE_MARKER_ROLLOVER_FRAME_UNLOCKED:
               rollOverMc.gotoAndStop(PRIZE_MARKER_ROLLOVER_FRAME_UNLOCKED);
         }
         this.showNestMc(rollOverMc);
      }
      
      private function onPrizeMarkerMouseOut(event:MouseEvent) : void
      {
         var rollOverMc:MovieClip = event.currentTarget as MovieClip;
         switch(rollOverMc.currentFrame)
         {
            case PRIZE_MARKER_FRAME_LOCKED:
               rollOverMc.gotoAndStop(PRIZE_MARKER_FRAME_LOCKED);
               break;
            case PRIZE_MARKER_FRAME_UNLOCKED:
               rollOverMc.gotoAndStop(PRIZE_MARKER_FRAME_UNLOCKED);
               break;
            case PRIZE_MARKER_ROLLOVER_FRAME_LOCKED:
               rollOverMc.gotoAndStop(PRIZE_MARKER_FRAME_LOCKED);
               break;
            case PRIZE_MARKER_ROLLOVER_FRAME_UNLOCKED:
               rollOverMc.gotoAndStop(PRIZE_MARKER_FRAME_UNLOCKED);
         }
         this.showNestMc(rollOverMc);
      }
      
      private function showNestMc(rollOverMc:MovieClip) : void
      {
         var prizeMaker:MovieClip = null;
         if(rollOverMc.hasOwnProperty("addnest_mc"))
         {
            rollOverMc.addnest_mc.visible = false;
            for each(prizeMaker in this.m_hasNests)
            {
               if(rollOverMc == prizeMaker)
               {
                  rollOverMc.addnest_mc.visible = true;
                  break;
               }
            }
         }
      }
      
      override public function close() : void
      {
         if(this.m_owner)
         {
            this.m_owner.updateProgressBtnText();
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
            UI.stopPopups(false);
         }
         super.close();
      }
   }
}

