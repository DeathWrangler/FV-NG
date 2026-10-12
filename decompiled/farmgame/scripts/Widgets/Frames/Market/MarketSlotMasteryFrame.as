package Widgets.Frames.Market
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.Market.MarketTooltip;
   import flash.display.MovieClip;
   
   public class MarketSlotMasteryFrame extends ZwFrame
   {
      
      public static const MAX_LEVEL:int = 3;
      
      private static const PROGRESS_BAR_MAX_WIDTH:int = 54;
      
      private var m_stars:ZwFrame;
      
      private var m_progressBar:ZwWidget;
      
      private var m_progressTrack:ZwWidget;
      
      public function MarketSlotMasteryFrame(element:MovieClip)
      {
         super(element);
         this.m_stars = addWidget(new ZwFrame(m_element.stars_mc)) as ZwFrame;
         (this.m_stars.element as MovieClip).stop();
         this.m_progressBar = addWidget(new ZwWidget(m_element.progressBar_mc)) as ZwWidget;
         this.m_progressTrack = addWidget(new ZwWidget(m_element.progressTrack_mc)) as ZwWidget;
         attachTooltip(new MarketTooltip(" "));
      }
      
      public function update(level:int = 0, progress:int = 0, goal:int = 0, useElementWidth:Boolean = false) : void
      {
         var width:int = 0;
         (this.m_stars.element as MovieClip).gotoAndStop(level + 1);
         if(useElementWidth && Boolean(this.m_progressBar.element.width))
         {
            width = int(this.m_progressBar.element.width);
         }
         else
         {
            width = PROGRESS_BAR_MAX_WIDTH;
         }
         var percentage:Number = goal <= 0 ? 0 : progress / goal;
         percentage = Math.max(Math.min(percentage,1),0);
         this.m_progressBar.width = Math.round(percentage * width);
         if(level >= MAX_LEVEL)
         {
            (m_tooltip as MarketTooltip).setText(ZLocUtils.t("Dialogs","Mastered"));
            this.m_progressBar.width = width;
         }
         else
         {
            (m_tooltip as MarketTooltip).setText(ZLocUtils.t("Dialogs","MasteryProgress",{
               "quantity":progress,
               "quantityTotal":goal
            }));
         }
      }
      
      override public function release() : void
      {
         this.m_stars = null;
         this.m_progressBar = null;
         this.m_progressTrack = null;
         super.release();
      }
   }
}

