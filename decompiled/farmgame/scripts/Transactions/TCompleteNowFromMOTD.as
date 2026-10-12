package Transactions
{
   import Classes.StorageBuilding;
   
   public class TCompleteNowFromMOTD extends TCompleteNow
   {
      
      public static const ACTION_COMPLETE_BUILDING:String = "CompleteNowFromMOTD";
      
      public function TCompleteNowFromMOTD(building:StorageBuilding, callback:Function = null)
      {
         super(building,null,callback);
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_COMPLETE_BUILDING);
      }
   }
}

