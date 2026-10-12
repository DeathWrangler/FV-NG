package Widgets.Frames.FeatureCrafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   
   public class FeatureCraftingRecipeMasteryFrame extends ZwFrame
   {
      
      public static const MAX_LEVEL:int = 3;
      
      private var m_stars:ZwFrame;
      
      private var m_progressBar:ZwWidget;
      
      private var m_progressTrack:ZwWidget;
      
      public function FeatureCraftingRecipeMasteryFrame(element:MovieClip)
      {
         super(element);
         this.m_stars = addWidget(new ZwFrame(m_element.stars_mc)) as ZwFrame;
         (this.m_stars.element as MovieClip).stop();
         this.m_progressBar = addWidget(new ZwWidget(m_element.progressBar_mc)) as ZwWidget;
         this.m_progressTrack = addWidget(new ZwWidget(m_element.progressTrack_mc)) as ZwWidget;
         attachTooltip(new FarmTextTooltip(" "));
      }
      
      public function populate(level:int = 0, progress:int = 0, goal:int = 0, useElementWidth:Boolean = false) : void
      {
         var percentage:Number = NaN;
         (this.m_stars.element as MovieClip).gotoAndStop(level + 1);
         if(level >= MAX_LEVEL)
         {
            (m_tooltip as FarmTextTooltip).setText(ZLocUtils.t("Dialogs","Mastered"));
            (this.m_progressBar.element as MovieClip).scaleX = 1;
         }
         else
         {
            percentage = goal <= 0 ? 0 : progress / goal;
            percentage = Math.max(Math.min(percentage,1),0);
            (this.m_progressBar.element as MovieClip).scaleX = percentage;
            (m_tooltip as FarmTextTooltip).setText(ZLocUtils.t("Dialogs","MasteryProgress",{
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

