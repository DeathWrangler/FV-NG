package Widgets.Frames.Breeding
{
   import Classes.ZItem.FarmItem;
   import Classes.breeding.AnimalBreedingSkillState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.BreedingMacroProgressBar;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class BreedingProgressFrame extends ZwFrame
   {
      
      private static const NUM_PRIZE_MARKERS:int = 6;
      
      private static const PRIZE_MARKER_FRAME_UNLOCKED:int = 1;
      
      private static const PRIZE_MARKER_FRAME_LOCKED:int = 2;
      
      private static const PRIZE_MARKER_ROLLOVER_FRAME_UNLOCKED:int = 3;
      
      private static const PRIZE_MARKER_ROLLOVER_FRAME_LOCKED:int = 4;
      
      private static const PRIZE_MARKER_SIZE:int = 25;
      
      private var m_skillState:AnimalBreedingSkillState = null;
      
      private var m_macroProgressBar:BreedingMacroProgressBar = null;
      
      private var m_progressSlotContainerFrame:BreedingProgressSlotContainerFrame = null;
      
      private var m_prizeMarkerWidgets:Array = new Array();
      
      public function BreedingProgressFrame(element:DisplayObject, skillState:AnimalBreedingSkillState)
      {
         super(element);
         this.m_skillState = skillState;
         this.m_macroProgressBar = new BreedingMacroProgressBar(m_element.macroMeter_mc,skillState.featureName);
         addWidget(this.m_macroProgressBar);
         this.m_progressSlotContainerFrame = new BreedingProgressSlotContainerFrame(m_element.bigMeter_mc,skillState.featureName);
         addWidget(this.m_progressSlotContainerFrame);
         this.initializePrizeMarkers();
         this.populatePrizeMarkers();
      }
      
      public function update() : void
      {
         var prizeMarker:ZwFrame = null;
         this.m_macroProgressBar.setupBar();
         this.m_progressSlotContainerFrame.update();
         var prizeInterval:int = BreedingMacroProgressBar.NUM_LEVELS_PER_BAR / NUM_PRIZE_MARKERS;
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
      
      override public function release() : void
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
         var prizeMarker:ZwFrame = null;
         var prizeInterval:int = BreedingMacroProgressBar.NUM_LEVELS_PER_BAR / NUM_PRIZE_MARKERS;
         for(var prizeMarkerIndex:int = 0; prizeMarkerIndex < NUM_PRIZE_MARKERS; prizeMarkerIndex++)
         {
            prizeMarker = new ZwFrame(m_element.macroMeter_mc["prize" + prizeMarkerIndex + "_mc"]);
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
      
      private function populatePrizeMarkers() : void
      {
         var maxDisplayedLevel:int = 0;
         var prizeLevel:int = 0;
         var rewards:Array = null;
         var reward:Object = null;
         var item:FarmItem = null;
         var prizeMarker:ZwFrame = null;
         var icon:FarmIcon = null;
         for(var prizeMarkerIndex:int = 0; prizeMarkerIndex < this.m_prizeMarkerWidgets.length; prizeMarkerIndex++)
         {
            maxDisplayedLevel = this.m_macroProgressBar.maxDisplayedLevel;
            prizeLevel = maxDisplayedLevel / NUM_PRIZE_MARKERS * (prizeMarkerIndex + 1);
            rewards = Global.animalBreedingSettings.getRewardsForLevel(prizeLevel,this.m_skillState.featureName);
            for each(reward in rewards)
            {
               if(reward.hasOwnProperty("bigReward") && reward.bigReward == "true")
               {
                  item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                  if(item != null)
                  {
                     prizeMarker = this.m_prizeMarkerWidgets[prizeMarkerIndex];
                     icon = new FarmIcon(prizeMarker.element.prize_mc,item.iconUrl);
                     icon.setIconSize(PRIZE_MARKER_SIZE,PRIZE_MARKER_SIZE);
                     prizeMarker.addWidget(icon);
                  }
                  break;
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
      }
   }
}

