package Transactions
{
   import Classes.StorageBuilding;
   
   public class TSetFeaturedItem extends TWorldState
   {
      
      private var m_building:StorageBuilding = null;
      
      private var m_callback:Function = null;
      
      private var m_params:Object = {};
      
      public function TSetFeaturedItem(building:StorageBuilding, slot:Number, itemCode:String, metaHash:String, removeOrAdd:Boolean, callback:Function = null)
      {
         this.m_params.itemSlot = slot;
         this.m_params.itemCode = itemCode;
         this.m_params.metaHash = metaHash;
         this.m_params.removeOrAdd = removeOrAdd;
         this.m_building = building;
         this.m_callback = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("setFeaturedItem",this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.hasOwnProperty("featuredItems"))
         {
            if(this.m_callback != null)
            {
               this.m_callback(result.featuredItems);
            }
         }
      }
   }
}

