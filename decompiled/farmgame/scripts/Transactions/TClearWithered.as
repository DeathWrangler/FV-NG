package Transactions
{
   import Classes.Plot;
   
   public class TClearWithered extends TWorldState
   {
      
      public function TClearWithered(plot:Plot)
      {
         super(plot);
      }
      
      override public function perform() : void
      {
         signedWorldAction("clearWithered");
      }
   }
}

