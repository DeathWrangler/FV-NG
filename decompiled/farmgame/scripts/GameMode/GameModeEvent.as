package GameMode
{
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   
   public class GameModeEvent extends Event
   {
      
      public static const TYPE_PREFIX_GAME_MODE_DISABLED:String = "gameModeDisabled";
      
      public static const TYPE_PREFIX_GAME_MODE_ENABLED:String = "gameModeEnabled";
      
      public function GameModeEvent(typePrefix:String, gameMode:GameMode)
      {
         super(getEventType(typePrefix,gameMode));
      }
      
      public static function getEventType(typePrefix:String, gameMode:GameMode) : String
      {
         return typePrefix + getQualifiedClassName(gameMode);
      }
   }
}

