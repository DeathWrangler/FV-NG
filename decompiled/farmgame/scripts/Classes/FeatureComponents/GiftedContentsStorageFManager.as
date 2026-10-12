package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Managers.FeatureBuildingGiftContentDataManager;
   
   public class GiftedContentsStorageFManager extends StorageFManager
   {
      
      private var m_giftsContentDataManager:FeatureBuildingGiftContentDataManager;
      
      public function GiftedContentsStorageFManager(owner:FeatureBuilding)
      {
         super(owner);
         this.m_giftsContentDataManager = FeatureBuildingGiftContentDataManager.getInstance(owner.getItem().name);
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false, number:int = 1) : Boolean
      {
         var result:Boolean = super.addItem(resource,fromStorage,isGift,sendStoreItem,force,number);
         if(!resource.fromMarket)
         {
            this.m_giftsContentDataManager.addGiftItemToBuilding(resource.getItem().code,m_owner.getId());
         }
         return result;
      }
      
      override public function removeContents(itemCode:String, itemCount:int = 1, itemParts:int = 0) : void
      {
         super.removeContents(itemCode,itemCount,itemParts);
         this.m_giftsContentDataManager.removeGiftItemFromBuilding(itemCode,itemCount,m_owner.getId());
      }
      
      public function getFriendListForItemCode(itemCode:String) : Array
      {
         return this.m_giftsContentDataManager.getFriendListForItemCode(itemCode,m_owner.getId());
      }
   }
}

