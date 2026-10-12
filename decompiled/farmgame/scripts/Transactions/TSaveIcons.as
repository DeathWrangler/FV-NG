package Transactions
{
   public class TSaveIcons extends TFarmTransaction
   {
      
      public var m_iconsData:Array;
      
      public function TSaveIcons(iconsData:Array)
      {
         super();
         this.m_iconsData = iconsData;
      }
      
      override public function perform() : void
      {
         signedCall("FarmService.saveIcons",this.m_iconsData);
      }
      
      override protected function onComplete(result:Object) : void
      {
      }
   }
}

