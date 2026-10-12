package Transactions
{
   import Engine.Classes.WorldObject;
   
   public class TClear extends TWorldState
   {
      
      public function TClear(object:WorldObject)
      {
         super(object);
      }
      
      override public function perform() : void
      {
         signedWorldAction("clear");
      }
   }
}

