package mx.core
{
   import flash.display.MovieClip;
   
   public class MovieClipAsset extends MovieClip
   {
      
      private var _measuredHeight:Number;
      
      private var _measuredWidth:Number;
      
      public function MovieClipAsset()
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

