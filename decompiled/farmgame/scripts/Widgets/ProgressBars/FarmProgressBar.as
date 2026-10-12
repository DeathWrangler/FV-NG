package Widgets.ProgressBars
{
   import Widgets.Core.ProgressBars.ZwAbstractProgressBar;
   import flash.display.DisplayObject;
   
   public class FarmProgressBar extends ZwAbstractProgressBar
   {
      
      protected static const BAR_INSTANCE_NAME:String = "bar_mc";
      
      public function FarmProgressBar(element:DisplayObject)
      {
         super(element);
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

