package mx.core
{
   import flash.display.Sprite;
   
   public class SpriteAsset extends Sprite
   {
      
      private var _measuredHeight:Number;
      
      private var _measuredWidth:Number;
      
      public function SpriteAsset()
      {
         super();
         this._measuredWidth = width;
         this._measuredHeight = height;
      }
      
      public function get measuredHeight() : Number
      {
         return this._measuredHeight;
      }
      
      public function get measuredWidth() : Number
      {
         return this._measuredWidth;
      }
   }
}

