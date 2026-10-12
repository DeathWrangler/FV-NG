package Classes
{
   import flash.utils.ByteArray;
   import mx.core.MovieClipLoaderAsset;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol484")]
   public class EmbeddedArt_guitarPick extends MovieClipLoaderAsset
   {
      
      private static var bytes:ByteArray = null;
      
      public var dataClass:Class = EmbeddedArt_guitarPick_dataClass;
      
      public function EmbeddedArt_guitarPick()
      {
         super();
         initialWidth = 1100 / 20;
         initialHeight = 1520 / 20;
      }
      
      override public function get movieClipData() : ByteArray
      {
         if(bytes == null)
         {
            bytes = ByteArray(new this.dataClass());
         }
         return bytes;
      }
   }
}

