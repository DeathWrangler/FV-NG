package Widgets.Frames.Market
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.Market.MarketTooltip;
   import flash.display.MovieClip;
   
   public class Market3SlotOrganicFrame extends ZwFrame
   {
      
      private var m_badge:ZwFrame;
      
      private var m_progressBar:FarmProgressBar;
      
      public function Market3SlotOrganicFrame(element:MovieClip)
      {
         super(element);
         if(m_element)
         {
            this.m_badge = new ZwFrame(m_element as MovieClip);
            if(this.m_badge != null)
            {
               this.m_badge.attachTooltip(new MarketTooltip(" "));
               if(this.m_badge.element.hasOwnProperty("fill_mc"))
               {
                  this.m_progressBar = new FarmProgressBar(this.m_badge.element.fill_mc);
                  if(this.m_progressBar != null)
                  {
                     this.m_badge.addWidget(this.m_progressBar);
                  }
               }
               addWidget(this.m_badge);
            }
         }
      }
      
      public function update(progress:int, total:int) : void
      {
         if(this.m_progressBar)
         {
            this.m_progressBar.maximum = total;
            this.m_progressBar.progress = progress;
            (this.m_badge.tooltip as MarketTooltip).setText(ZLocUtils.t("Dialogs","OrganicProgress",{
               "quantity":progress,
               "quantityTotal":total
            }));
         }
      }
      
      override public function release() : void
      {
         this.m_badge = null;
         this.m_progressBar = null;
         super.release();
      }
   }
}

