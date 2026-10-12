package Classes
{
   import GameMode.GMDefault;
   
   public class StationaryMapTrigger extends MapTrigger
   {
      
      public function StationaryMapTrigger(itemName:String, stateToSet:String)
      {
         super(itemName,stateToSet);
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         return false;
      }
      
      override public function handleDecoMoveUnsupported() : void
      {
         onClick();
         Global.world.addGameMode(new GMDefault(),true);
      }
   }
}

