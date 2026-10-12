package Classes
{
   import flash.utils.ByteArray;
   import mx.core.MovieClipLoaderAsset;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol484")]
   public class EmbeddedArt_FV_Mystery_Box extends MovieClipLoaderAsset
   {
      
      private static var bytes:ByteArray = null;
      
      public var dataClass:Class = EmbeddedArt_FV_Mystery_Box_dataClass;
      
      public function EmbeddedArt_FV_Mystery_Box()
      {
         super();
         initialWidth = 1000 / 20;
         initialHeight = 1000 / 20;
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

