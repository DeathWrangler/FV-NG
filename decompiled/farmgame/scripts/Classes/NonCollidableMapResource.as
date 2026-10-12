package Classes
{
   import GameMode.GMDefault;
   
   public class NonCollidableMapResource extends MapResource
   {
      
      public function NonCollidableMapResource(itemName:String)
      {
         super(itemName);
      }
      
      override public function isCollidable() : Boolean
      {
         return false;
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

