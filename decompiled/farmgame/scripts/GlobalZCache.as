package
{
   import Cache.Interfaces.IZCache;
   
   public class GlobalZCache
   {
      
      public static var instance:IZCache = null;
      
      public function GlobalZCache()
      {
         super();
      }
   }
}

