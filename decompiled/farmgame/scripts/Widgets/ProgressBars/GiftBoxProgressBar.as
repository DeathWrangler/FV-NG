package Widgets.ProgressBars
{
   import Widgets.Core.ProgressBars.ZwAbstractProgressBar;
   import flash.display.DisplayObject;
   
   public class GiftBoxProgressBar extends ZwAbstractProgressBar
   {
      
      protected static const BAR_INSTANCE_NAME:String = "loaderNumb_mc";
      
      public function GiftBoxProgressBar(element:DisplayObject, minimum:int = 0, maximum:int = 100)
      {
         super(element);
         m_maximum = maximum;
         m_minimum = minimum;
      }
      
      override public function getBarInstanceMC() : DisplayObject
      {
         var bar:DisplayObject = super.getBarInstanceMC();
         if(!this.getBarInstanceName().length)
         {
            bar = m_element as DisplayObject;
         }
         return bar;
      }
      
      override public function getBarInstanceName() : String
      {
         return BAR_INSTANCE_NAME;
      }
   }
}

