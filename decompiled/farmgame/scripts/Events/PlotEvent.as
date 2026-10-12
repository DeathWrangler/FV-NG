package Events
{
   import Classes.Plot;
   import flash.display.InteractiveObject;
   import flash.events.MouseEvent;
   
   public class PlotEvent extends MouseEvent
   {
      
      public static const PLOT_ROLL_OVER:String = "plotRollOver";
      
      public static const PLOT_ROLL_OUT:String = "plotRollOut";
      
      public static const PLOT_MOUSE_CLICK:String = "plotMouseClick";
      
      public static const PLOT_PLOWED:String = "plotPlowed";
      
      public static const PLOT_HARVESTED:String = "plotHarvested";
      
      public static const PLOT_PLANTED:String = "plotPlanted";
      
      public var plot:Plot;
      
      public function PlotEvent(type:String, data:Plot, bubbles:Boolean = true, cancelable:Boolean = false, localX:Number = undefined, localY:Number = undefined, relatedObject:InteractiveObject = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false, delta:int = 0)
      {
         this.plot = data;
         super(type,bubbles,cancelable,localX,localY,relatedObject,ctrlKey,altKey,shiftKey,buttonDown,delta);
      }
   }
}

