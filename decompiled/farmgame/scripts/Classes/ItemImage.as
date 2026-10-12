package Classes
{
   import Engine.Helpers.Vector2;
   
   public class ItemImage
   {
      
      public var image:Object;
      
      public var lowResImage:Object = null;
      
      public var lowResImageDisplacement:Vector2 = null;
      
      public var boxWidth:int = 0;
      
      public var forceScale:Number = 0;
      
      public var trackAnimation:Boolean = true;
      
      public var pixelPerfectPick:Boolean = true;
      
      public function ItemImage(newImage:Object = null)
      {
         super();
         this.image = newImage;
      }
   }
}

