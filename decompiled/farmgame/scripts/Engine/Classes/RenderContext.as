package Engine.Classes
{
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   
   public class RenderContext
   {
      
      public var targetBuffer:BitmapData;
      
      public var alphaBuffer:BitmapData;
      
      public var backBuffer:BitmapData;
      
      public var transformMatrix:Matrix;
      
      public function RenderContext()
      {
         super();
      }
   }
}

