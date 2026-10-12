package Transactions
{
   import Classes.FlowerShackFeatureBuilding;
   
   public class TFlowerShackNuture extends TWorldState
   {
      
      private var m_building:FlowerShackFeatureBuilding = null;
      
      private var m_callback:Function = null;
      
      private var m_params:Object = {};
      
      public function TFlowerShackNuture(building:FlowerShackFeatureBuilding, subtype:String, callback:Function = null)
      {
         this.m_params.subtype = subtype;
         this.m_building = building;
         this.m_callback = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("nutureFlowerShack",this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result)
         {
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

