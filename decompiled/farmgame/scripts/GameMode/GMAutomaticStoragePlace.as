package GameMode
{
   import Classes.CreditsBuilding;
   import Classes.FeatureCreditItem;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.VirtualStorageDecoration;
   import Classes.ZItem.FarmItem;
   
   public class GMAutomaticStoragePlace extends GMModifyBuilding
   {
      
      protected var m_itemToAdd:MapResource;
      
      public function GMAutomaticStoragePlace(itemName:String, storageBuildingName:String, isGift:Boolean, shouldReOpenGift:Boolean = true, centerOnBuilding:Boolean = true, itemCount:int = 1)
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_itemToAdd = new FeatureCreditItem(itemName);
         super(itemName,storageBuildingName,isGift,shouldReOpenGift,centerOnBuilding,itemCount);
      }
      
      override protected function canModifyBuilding(building:Object) : Boolean
      {
         var canModify:Boolean = false;
         if(Boolean(building) && building is StorageBuilding)
         {
            canModify = !(building as StorageBuilding).isFull();
         }
         return canModify;
      }
      
      override protected function modifyBuilding() : void
      {
         if(m_itemCount > 1)
         {
            if(!(this.m_itemToAdd is VirtualStorageDecoration && m_building is CreditsBuilding))
            {
               throw new Error("AddMultipleCredits only supports VirtualStorageDecorations and CreditsBuildings.");
            }
            (m_building as CreditsBuilding).addMultipleCredits(this.m_itemToAdd as VirtualStorageDecoration,m_itemCount,m_isGift);
         }
         else
         {
            m_building.addItem(this.m_itemToAdd,0,m_isGift,true,true);
         }
      }
   }
}

