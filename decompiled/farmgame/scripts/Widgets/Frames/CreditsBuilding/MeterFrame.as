package Widgets.Frames.CreditsBuilding
{
   import Classes.CreditsBuilding;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.ProgressBars.ZwAbstractProgressBar;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.ProgressBars.FarmProgressBarFrameAnimation;
   import flash.display.DisplayObject;
   
   public class MeterFrame extends ZwFrame
   {
      
      protected static const PROPERTIES_FILE_NAME:String = "Dialogs";
      
      protected var m_building:CreditsBuilding = null;
      
      protected var m_featureName:String;
      
      protected var m_progressBar:FarmProgressBar = null;
      
      public function MeterFrame(element:DisplayObject, building:CreditsBuilding, featureName:String, frameAnimation:Boolean = false, countToStartMeterAt:Number = 0)
      {
         super(element);
         this.m_building = building;
         this.m_featureName = featureName;
         if(!frameAnimation)
         {
            this.m_progressBar = new FarmProgressBar(this.getProgressBarContainer());
         }
         else
         {
            this.m_progressBar = new FarmProgressBarFrameAnimation(this.getProgressBarContainer());
            this.m_progressBar.animated = false;
         }
         this.initMaximum();
         this.m_progressBar.direction = ZwAbstractProgressBar.DIRECTION_UP;
         if(frameAnimation)
         {
            this.m_progressBar.progress = this.calcMeterHeight(countToStartMeterAt);
            this.m_progressBar.animated = true;
            this.m_progressBar.progress = this.calcMeterHeight();
         }
         else
         {
            this.m_progressBar.progress = this.calcMeterHeight();
         }
         addWidget(this.m_progressBar);
         this.buildMeterBarTickMarks();
         this.addCounterText();
      }
      
      protected function initMaximum() : void
      {
      }
      
      override public function release() : void
      {
         this.m_progressBar = null;
         this.m_building = null;
         this.m_featureName = "";
         super.release();
      }
      
      protected function buildMeterBarTickMarks() : void
      {
         var levels:Array = this.m_building.getLevelCredits();
         addWidget(new ZwTextField(m_element[this.getIncrementPrefixTextFieldContainer() + "0_tf"],"0"));
         for(var index:int = 0; index < levels.length; index++)
         {
            addWidget(new ZwTextField(m_element[this.getIncrementPrefixTextFieldContainer() + (index + 1) + "_tf"],levels[index]));
         }
      }
      
      protected function calcMeterHeight(paramNumCredits:Number = -1) : Number
      {
         var levelIndex:uint = 0;
         var requiredAmount:Number = NaN;
         var meterHeight:Number = 0;
         var levels:Array = this.m_building.getLevelCredits();
         var stateChangeLevels:Array = this.m_building.meterStates;
         var credits:uint = 0;
         if(paramNumCredits >= 0)
         {
            credits = paramNumCredits;
         }
         else
         {
            credits = this.m_building.getTotalCreditsReceived();
         }
         var numLevels:int = int(stateChangeLevels.length);
         var levelIntervalHeight:Number = this.m_progressBar.maximum / numLevels;
         var prevRequiredAmount:Number = 0;
         for(var stateChangeIndex:uint = 0; stateChangeIndex < numLevels; stateChangeIndex++)
         {
            levelIndex = uint(stateChangeLevels[stateChangeIndex]);
            requiredAmount = Number(levels[levelIndex]);
            if(credits <= requiredAmount)
            {
               meterHeight += (credits - prevRequiredAmount) / (requiredAmount - prevRequiredAmount) * levelIntervalHeight;
               break;
            }
            meterHeight += levelIntervalHeight;
            prevRequiredAmount = requiredAmount;
         }
         return meterHeight;
      }
      
      public function refreshMeter() : void
      {
         this.m_progressBar.progress = this.calcMeterHeight();
      }
      
      protected function getProgressBarContainer() : DisplayObject
      {
         throw new Error("Error: Abstract Function: Need to override MeterFrame:getProgressBarContainer.");
      }
      
      protected function getIncrementPrefixTextFieldContainer() : String
      {
         throw new Error("Error: Abstract Function: Need to override MeterFrame:getIncrementTextFieldContainer.");
      }
      
      protected function addCounterText() : void
      {
         throw new Error("Error: Abstract Function: Need to override MeterFrame:addCounterText.");
      }
   }
}

