package Transactions
{
   public class TBuySeedPackage extends TFarmTransaction
   {
      
      private var m_seedName:String;
      
      private var m_amount:Number;
      
      public function TBuySeedPackage(seedName:String, amount:Number)
      {
         super();
         this.m_seedName = seedName;
         this.m_amount = amount;
      }
      
      override public function perform() : void
      {
         signedCall("SeedPackageService.onBuySeedPackage",this.m_seedName,this.m_amount);
      }
   }
}

