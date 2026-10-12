package Widgets.Frames.Market
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.Market.MarketTooltip;
   import flash.display.MovieClip;
   
   public class Market3SlotMasteryFrame extends ZwFrame
   {
      
      public static const MAX_LEVEL:int = 3;
      
      private var m_stars:ZwFrame;
      
      public function Market3SlotMasteryFrame(element:MovieClip)
      {
         super(element);
         this.m_stars = addWidget(new ZwFrame(m_element.stars_mc)) as ZwFrame;
         (this.m_stars.element as MovieClip).stop();
         attachTooltip(new MarketTooltip(" "));
      }
      
      public function update(level:int = 0, progress:int = 0, goal:int = 0, useElementWidth:Boolean = false) : void
      {
         (this.m_stars.element as MovieClip).gotoAndStop(level + 1);
         if(level >= MAX_LEVEL)
         {
            (m_tooltip as MarketTooltip).setText(ZLocUtils.t("Dialogs","Mastered"));
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
         super.release();
      }
   }
}

