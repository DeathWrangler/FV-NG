package Managers
{
   public class InfiniteTurboManager
   {
      
      public function InfiniteTurboManager()
      {
         super();
      }
      
      private static function getActiveWorlds() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.TURBO_RINGS,FeatureOptionsManager.TURBO_RINGS_ACTIVE_WORLDS);
      }
      
      public static function isEnabledInCurrentWorld() : Boolean
      {
         return isEnabledInWorld(Global.worldManager.currentWorldType);
      }
      
      private static function isEnabledInWorld(world:String) : Boolean
      {
         var result:Boolean = false;
         var turboRingActiveWorlds:Object = getActiveWorlds();
         if(Boolean(turboRingActiveWorlds) && Boolean(turboRingActiveWorlds[world]))
         {
            result = true;
         }
         return result;
      }
   }
}

