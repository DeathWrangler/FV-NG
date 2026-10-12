package Transactions
{
   public class TCustomizeUnwitherRing extends TFarmTransaction
   {
      
      protected var m_ring:Object;
      
      protected var m_ringID:Number;
      
      public function TCustomizeUnwitherRing(ringExtraData:Object, ringID:Number)
      {
         this.m_ring = ringExtraData;
         this.m_ringID = ringID;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.customizeUnwitherRingData",this.m_ring,this.m_ringID);
      }
   }
}

