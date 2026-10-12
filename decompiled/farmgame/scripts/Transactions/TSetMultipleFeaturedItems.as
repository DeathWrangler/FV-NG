package Transactions
{
   import Classes.StorageBuilding;
   
   public class TSetMultipleFeaturedItems extends TWorldState
   {
      
      private var m_building:StorageBuilding = null;
      
      private var m_callback:Function = null;
      
      private var m_params:Object = {};
      
      public function TSetMultipleFeaturedItems(building:StorageBuilding, featuredItems:Object, callback:Function = null)
      {
         this.m_params.featuredItems = featuredItems;
         this.m_building = building;
         this.m_callback = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("setMultipleFeaturedItems",this.m_params);
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

