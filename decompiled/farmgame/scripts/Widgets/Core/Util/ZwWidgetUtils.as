package Widgets.Core.Util
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ZwWidgetUtils
   {
      
      public static const INSTANCE:String = "instance";
      
      public function ZwWidgetUtils()
      {
         super();
      }
      
      public static function isValidElement(element:DisplayObject) : Boolean
      {
         return element.name.indexOf(INSTANCE) < 0;
      }
      
      public static function getWidgetName(widget:Object) : String
      {
         var widgetName:String = "";
         if(widget is String)
         {
            widgetName = widget as String;
         }
         else
         {
            widgetName = widget.name;
         }
         return widgetName;
      }
      
      public static function removeAllChildren(mc:MovieClip) : void
      {
         var childIdx:* = 0;
         if(mc)
         {
            for(childIdx = mc.numChildren; childIdx > 0; childIdx--)
            {
               mc.removeChildAt(childIdx - 1);
            }
         }
      }
   }
}

