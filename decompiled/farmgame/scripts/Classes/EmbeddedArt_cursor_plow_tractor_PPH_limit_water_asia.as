package Classes
{
   import flash.utils.ByteArray;
   import mx.core.MovieClipLoaderAsset;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol484")]
   public class EmbeddedArt_cursor_plow_tractor_PPH_limit_water_asia extends MovieClipLoaderAsset
   {
      
      private static var bytes:ByteArray = null;
      
      public var dataClass:Class = EmbeddedArt_cursor_plow_tractor_PPH_limit_water_asia_dataClass;
      
      public function EmbeddedArt_cursor_plow_tractor_PPH_limit_water_asia()
      {
         super();
         initialWidth = 1400 / 20;
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

