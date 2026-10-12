package Transactions
{
   import Classes.ZItem.FarmItem;
   import Managers.ZapPromoManager;
   
   public class TGetZapPlaceReward extends TFarmTransaction
   {
      
      protected var m_brandedObject:FarmItem;
      
      public function TGetZapPlaceReward(brandedObject:FarmItem)
      {
         super();
         this.m_brandedObject = brandedObject;
      }
      
      override public function perform() : void
      {
         signedCall("ZyngaAdService.onCreateBrandedItemReward",this.m_brandedObject.brandPromoData.brandPromoName,this.m_brandedObject.name);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("rewardLink"))
         {
            ZapPromoManager.shareFirstPlacementPublish(this.m_brandedObject,result.rewardLink);
         }
      }
   }
}

