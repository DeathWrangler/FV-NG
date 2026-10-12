package Classes.ZItem
{
   import Classes.UGC.UGCFarmItemDelegate;
   import DataSources.BaseDataSource;
   
   public class UGCAnimalItem extends AnimalItem implements IUGCItem
   {
      
      public function UGCAnimalItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      public function get ugcItemName() : String
      {
         return super.name;
      }
      
      public function get farmItem() : FarmItem
      {
         return this as FarmItem;
      }
      
      override public function get isRescue() : Boolean
      {
         return false;
      }
      
      override public function get isCustomizable() : Boolean
      {
         return false;
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         return UGCFarmItemDelegate.onBuy(this,name,extraData);
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         UGCFarmItemDelegate.onUse(this,buildingId,extraData);
      }
      
      override public function get hasPreview() : Boolean
      {
         return false;
      }
      
      override protected function defaultPreview() : Boolean
      {
         return false;
      }
      
      override public function get buyableFromNeighbor() : Boolean
      {
         return false;
      }
      
      override public function getInstanceName(metadata:Object = null) : String
      {
         var result:String = UGCFarmItemDelegate.getInstanceName(metadata as String);
         if(result)
         {
            return result;
         }
         return super.getInstanceName(metadata);
      }
   }
}

