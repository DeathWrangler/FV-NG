package Managers
{
   import flash.utils.Dictionary;
   
   public class WorldCache
   {
      
      private var m_cache:Dictionary;
      
      private var m_pending:Dictionary;
      
      public function WorldCache()
      {
         super();
         this.m_cache = new Dictionary();
         this.m_pending = new Dictionary();
      }
      
      public static function validateWorldData(txData:Object) : Boolean
      {
         return Boolean(txData) && txData["user"] != null && Boolean(txData.user["currentWorldType"]) && Boolean(txData["currentTime"]);
      }
      
      public function exists(worldType:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_cache[worldType])
         {
            if(validateWorldData(this.m_cache[worldType]))
            {
               result = true;
            }
            else
            {
               delete this.m_cache[worldType];
            }
         }
         return result;
      }
      
      public function add(worldType:String, data:Object) : void
      {
         GlobalEngine.assert(worldType != null,"WorldCache.addWorldData received null worldType!");
         if(this.m_pending.hasOwnProperty(worldType))
         {
            delete this.m_pending[worldType];
         }
         if(validateWorldData(data))
         {
            this.m_cache[worldType] = data;
         }
      }
      
      public function get(worldType:String) : Object
      {
         GlobalEngine.assert(worldType != null,"WorldCache.getCachedWorldData received null worldType!");
         var result:Object = null;
         if(this.exists(worldType))
         {
            result = this.m_cache[worldType];
         }
         return result;
      }
      
      public function remove(worldType:String) : void
      {
         GlobalEngine.assert(worldType != null,"WorldCache.notifyWorldSwapped received null worldType!");
         if(this.m_cache.hasOwnProperty(worldType))
         {
            delete this.m_cache[worldType];
         }
         if(this.m_pending.hasOwnProperty(worldType))
         {
            delete this.m_pending[worldType];
         }
      }
      
      public function isPeekInFlight(worldType:String) : Boolean
      {
         return this.m_pending.hasOwnProperty(worldType);
      }
      
      public function setPeekInFlight(worldType:String) : void
      {
         GlobalEngine.assert(worldType != null,"WorldCache.setPeekInFlight received null worldType!");
         this.m_pending[worldType] = true;
      }
   }
}

