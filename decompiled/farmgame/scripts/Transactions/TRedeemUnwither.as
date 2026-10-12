package Transactions
{
   import Classes.Plot;
   
   public class TRedeemUnwither extends TWorldState
   {
      
      protected var m_neighborId:String = "";
      
      public function TRedeemUnwither(plot:Plot, neighborId:String = "0")
      {
         this.m_neighborId = neighborId;
         super(plot);
      }
      
      override public function perform() : void
      {
         signedWorldAction("redeemNeighborUnwither",{"neighborId":this.m_neighborId});
      }
   }
}

