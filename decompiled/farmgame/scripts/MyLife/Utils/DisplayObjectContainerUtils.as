package MyLife.Utils
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Point;
   
   public class DisplayObjectContainerUtils
   {
      
      public function DisplayObjectContainerUtils()
      {
         super();
      }
      
      public static function removeChildren(param1:DisplayObjectContainer) : void
      {
         if(param1 == null)
         {
            return;
         }
         while(param1.numChildren > 0)
         {
            param1.removeChildAt(0);
         }
      }
      
      public static function getChildren(param1:DisplayObjectContainer) : Array
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:Array = [];
         var _loc4_:* = param1.numChildren;
         while(_loc4_--)
         {
            _loc3_ = param1.getChildAt(_loc4_);
            _loc2_.unshift(_loc3_);
         }
         return _loc2_;
      }
      
      public static function getCoordinatesInSpace(param1:DisplayObjectContainer, param2:DisplayObjectContainer, param3:Point) : Point
      {
         var _loc4_:Point = param1.localToGlobal(param3);
         return param2.globalToLocal(_loc4_);
      }
   }
}

