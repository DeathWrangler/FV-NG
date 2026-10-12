package Transactions
{
   import Classes.Plot;
   
   public class TRedeemFertilize extends TWorldState
   {
      
      protected var m_neighborId:String = "";
      
      public function TRedeemFertilize(plot:Plot, neighborId:String = "0")
      {
         this.m_neighborId = neighborId.toString();
         super(plot);
      }
      
      override public function perform() : void
      {
         signedWorldAction("redeemNeighborFertilize",{"neighborId":this.m_neighborId});
      }
   }
}

