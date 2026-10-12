package Transactions
{
   import Classes.FeatureBuilding;
   
   public class TSetOverlayOverride extends TWorldState
   {
      
      private var m_building:FeatureBuilding = null;
      
      private var m_callback:Function = null;
      
      private var m_params:Object = {};
      
      private const EXTRAITEMDATA_KEY_OVERLAYOVERRIDE:String = "overlayOverride";
      
      public function TSetOverlayOverride(building:FeatureBuilding, overlayOverride:Number, callback:Function = null)
      {
         this.m_params.overlayOverride = overlayOverride;
         this.m_building = building;
         this.m_callback = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("setOverlayOverride",this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.hasOwnProperty(this.EXTRAITEMDATA_KEY_OVERLAYOVERRIDE))
         {
            if(this.m_callback != null)
            {
               this.m_callback(result.overlayOverride);
            }
         }
      }
   }
}

