package Transactions
{
   import Classes.MessageSign;
   
   public class TDeleteMessageSign extends TWorldState
   {
      
      public function TDeleteMessageSign(messageSign:MessageSign)
      {
         super(messageSign);
      }
      
      override public function perform() : void
      {
         signedWorldAction("deleteMessageSign");
      }
   }
}

