package Widgets.Frames.TicketParty
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.ProgressBars.ZwAbstractProgressBar;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.ProgressBars.FarmProgressBarFrameAnimation;
   import flash.display.DisplayObject;
   
   public class TicketPartyStagedMeterFrame extends ZwFrame
   {
      
      protected static const PROPERTIES_FILE_NAME:String = "Dialogs";
      
      protected var m_progressBar:FarmProgressBar = null;
      
      protected var m_minTickTextField:ZwTextField = null;
      
      protected var m_maxTickTextField:ZwTextField = null;
      
      public function TicketPartyStagedMeterFrame(element:DisplayObject, min:uint, max:uint, current:uint)
      {
         super(element);
         this.buildMeterBarTickMarks(min,max);
         this.createProgressBar(min,max,current);
      }
      
      override public function release() : void
      {
         this.m_progressBar = null;
         super.release();
      }
      
      protected function createProgressBar(min:uint, max:uint, current:uint, meterHeight:Number = -1) : void
      {
         this.m_progressBar = new FarmProgressBarFrameAnimation(m_element.bar_mc);
         this.m_progressBar.animated = false;
         if(meterHeight < 0)
         {
            meterHeight = this.calcMeterHeight(min,max,current);
         }
         this.m_progressBar.direction = ZwAbstractProgressBar.DIRECTION_UP;
         this.m_progressBar.progress = meterHeight;
         this.m_progressBar.animated = true;
         this.m_progressBar.progress = meterHeight;
         addWidget(this.m_progressBar);
      }
      
      protected function buildMeterBarTickMarks(min:uint, max:uint) : void
      {
         if(m_element.hasOwnProperty("increment0_tf") && m_element.increment0_tf != null)
         {
            this.m_minTickTextField = new ZwTextField(m_element.increment0_tf,min.toString());
            addWidget(this.m_minTickTextField);
         }
         if(m_element.hasOwnProperty("increment1_tf") && m_element.increment1_tf != null)
         {
            this.m_maxTickTextField = new ZwTextField(m_element.increment1_tf,max.toString());
            addWidget(this.m_maxTickTextField);
         }
      }
      
      protected function calcMeterHeight(min:uint, max:uint, current:uint) : Number
      {
         var levelIntervalHeight:Number = this.m_progressBar.maximum;
         var meterHeight:Number = (current - min) / (max - min) * levelIntervalHeight;
         if(meterHeight < 0)
         {
            meterHeight = 0;
         }
         else if(meterHeight > levelIntervalHeight)
         {
            meterHeight = levelIntervalHeight;
         }
         return meterHeight;
      }
      
      public function refreshMeter(min:uint, max:uint, current:uint) : void
      {
         var newProgress:Number = this.calcMeterHeight(min,max,current);
         if(newProgress < this.m_progressBar.progress)
         {
            removeWidget(this.m_progressBar);
            this.m_progressBar = null;
            this.createProgressBar(min,max,current,newProgress);
         }
         this.m_progressBar.progress = newProgress;
         if(this.m_minTickTextField != null)
         {
            this.m_minTickTextField.text = min.toString();
         }
         if(this.m_maxTickTextField != null)
         {
            this.m_maxTickTextField.text = max.toString();
         }
      }
      
      protected function getIncrementPrefixTextFieldContainer() : String
      {
         return "increment";
      }
   }
}

