package by.blooddy.crypto.image.palette
{
   import flash.display.BitmapData;
   
   public class MedianCutPalette implements IPalette
   {
      
      private var _list:Vector.<uint>;
      
      private var _hash:Array;
      
      public function MedianCutPalette(image:BitmapData, maxColors:uint = 256)
      {
         super();
         var arr:Array = MedianCutPaletteHelper.createTable(image,maxColors);
         this._list = arr[0];
         this._hash = arr[1];
      }
      
      public function getColors() : Vector.<uint>
      {
         return this._list.slice();
      }
      
      public function getIndexByColor(color:uint) : uint
      {
         return this._hash[color];
      }
   }
}

