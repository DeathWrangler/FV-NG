package Classes.Farmstamatic
{
   import flash.display.BitmapData;
   
   public class FarmstamaticPhoto
   {
      
      private var m_bitmapData:BitmapData;
      
      public function FarmstamaticPhoto()
      {
         super();
      }
      
      public function setBitmapData(bitmapData:BitmapData) : void
      {
         this.m_bitmapData = bitmapData;
      }
      
      public function getBitmapData() : BitmapData
      {
         return this.m_bitmapData;
      }
   }
}

