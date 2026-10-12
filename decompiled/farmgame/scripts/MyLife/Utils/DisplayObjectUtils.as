package MyLife.Utils
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.PixelSnapping;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class DisplayObjectUtils
   {
      
      public function DisplayObjectUtils()
      {
         super();
      }
      
      public static function getBitmap(param1:DisplayObject, param2:Number = 1, param3:Boolean = true, param4:Rectangle = null) : Bitmap
      {
         var _loc5_:Rectangle = param4 || param1.getBounds(param1);
         var _loc6_:Matrix = new Matrix(param2,0,0,param2,-_loc5_.left * param2,-_loc5_.top * param2);
         var _loc7_:BitmapData = new BitmapData(int(_loc5_.width * param2) || 1,int(_loc5_.height * param2) || 1,true,0);
         _loc7_.draw(param1,_loc6_,null,null,null,param3);
         var _loc8_:String = param3 ? PixelSnapping.NEVER : PixelSnapping.ALWAYS;
         return new Bitmap(_loc7_,_loc8_,param3);
      }
      
      public static function getOptimizedImage(param1:DisplayObject, param2:Boolean = true, param3:Rectangle = null) : Shape
      {
         var _loc4_:Rectangle = param3 || param1.getBounds(param1);
         var _loc5_:Number = param1.scaleX;
         var _loc6_:Number = param1.scaleY;
         var _loc7_:Matrix = new Matrix(_loc5_,0,0,_loc6_,-_loc4_.left * _loc5_,-_loc4_.top * _loc6_);
         var _loc8_:BitmapData = new BitmapData(int(_loc4_.width * _loc5_) || 1,int(_loc4_.height * _loc6_) || 1,true,0);
         _loc8_.draw(param1,_loc7_,null,null,null,param2);
         _loc7_ = new Matrix();
         var _loc9_:Shape = new Shape();
         _loc9_.graphics.beginBitmapFill(_loc8_,_loc7_,false,param2);
         _loc9_.graphics.drawRect(_loc4_.left * _loc6_,_loc4_.top * _loc6_,_loc8_.width,_loc8_.height);
         _loc9_.graphics.endFill();
         return _loc9_;
      }
      
      public static function getBitmapData(param1:DisplayObject, param2:Boolean = true, param3:Rectangle = null) : BitmapData
      {
         var _loc4_:Rectangle = param3 || param1.getBounds(param1);
         var _loc5_:Number = param1.scaleX;
         var _loc6_:Number = param1.scaleY;
         var _loc7_:Matrix = new Matrix(_loc5_,0,0,_loc6_,-_loc4_.left * _loc5_,-_loc4_.top * _loc6_);
         var _loc8_:BitmapData = new BitmapData(int(_loc4_.width * _loc5_) || 1,int(_loc4_.height * _loc6_) || 1,true,0);
         _loc8_.draw(param1,_loc7_,null,null,null,param2);
         return _loc8_;
      }
      
      public static function duplicate(param1:DisplayObject) : DisplayObject
      {
         var _loc4_:Rectangle = null;
         var _loc2_:Class = Object(param1).constructor;
         var _loc3_:DisplayObject = new _loc2_() as DisplayObject;
         _loc3_.transform = param1.transform;
         _loc3_.filters = param1.filters;
         _loc3_.cacheAsBitmap = param1.cacheAsBitmap;
         _loc3_.opaqueBackground = param1.opaqueBackground;
         if(param1.scale9Grid)
         {
            _loc4_ = param1.scale9Grid;
            _loc3_.scale9Grid = _loc4_;
         }
         return _loc3_;
      }
      
      public static function colorize(param1:DisplayObject, param2:Number = -1) : void
      {
         var _loc3_:ColorTransform = new ColorTransform();
         if(param2 >= 0)
         {
            _loc3_.color = param2;
         }
         param1.transform.colorTransform = _loc3_;
      }
      
      public static function resizeToDisplayObject(param1:DisplayObject, param2:DisplayObject) : void
      {
         var _loc3_:Number = param1.width / param2.width;
         var _loc4_:Number = param1.height / param2.height;
         var _loc5_:Number = _loc3_ <= _loc4_ ? _loc3_ : _loc4_;
         param1.width *= _loc5_ / param1.scaleX;
         param1.height *= _loc5_ / param1.scaleY;
      }
      
      public static function alignToDisplayObject(param1:DisplayObject, param2:DisplayObject, param3:Number = 0) : void
      {
         var _loc4_:Rectangle = param2.getBounds(param2);
         param1.x = _loc4_.left + _loc4_.width * 0.5;
         param1.y = _loc4_.top + _loc4_.height * 0.5;
      }
      
      public static function resizeToRectangle(param1:DisplayObject, param2:Rectangle) : void
      {
         var _loc3_:Number = param2.width / param1.width;
         var _loc4_:Number = param2.height / param1.height;
         var _loc5_:Number = _loc3_ <= _loc4_ ? _loc3_ : _loc4_;
         param1.width *= _loc5_ / param1.scaleX;
         param1.height *= _loc5_ / param1.scaleY;
      }
      
      public static function alignToRectangle(param1:DisplayObject, param2:Rectangle, param3:Number = 0) : void
      {
         var _loc4_:Sprite = new Sprite();
         var _loc5_:DisplayObjectContainer = param1.parent;
         _loc4_.addChild(param1);
         var _loc6_:Rectangle = param1.getBounds(_loc4_);
         param1.x = -_loc6_.left + (param2.left + param2.width * 0.5 - _loc6_.width * 0.5);
         param1.y = -_loc6_.top + (param2.top + param2.height * 0.5 - _loc6_.height * 0.5);
         if(_loc5_)
         {
            _loc5_.addChild(param1);
         }
         else
         {
            _loc4_.removeChild(param1);
         }
      }
      
      public static function applyTint(param1:DisplayObject, param2:uint, param3:Number = 1) : void
      {
         var _loc4_:uint = uint(param2 >> 16);
         var _loc5_:uint = uint((param2 & 0xFFFF) >> 8);
         var _loc6_:uint = uint(param2 & 0xFF);
         var _loc7_:ColorTransform = param1.transform.colorTransform;
         _loc7_.redOffset = _loc4_;
         _loc7_.greenOffset = _loc5_;
         _loc7_.blueOffset = _loc6_;
         param1.transform.colorTransform = _loc7_;
      }
   }
}

