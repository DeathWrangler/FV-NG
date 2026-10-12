package GameMode
{
   import Classes.Combine;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.Plot;
   import Classes.ZItem.FarmItem;
   import Managers.ClickTrackingManager;
   
   public class GMMultiPlotCombine extends GMMultiPlotPlant
   {
      
      public function GMMultiPlotCombine(seed:FarmItem, seeder:Combine)
      {
         var seederTerrains:Array = null;
         var seedTerrains:Array = null;
         var i:int = 0;
         var j:int = 0;
         super(seed,seeder);
         if(seeder)
         {
            seederTerrains = seeder.getSupportedTerrainCodes();
            seedTerrains = seed.getTerrainCodes();
            m_arrAcceptableTerrain = [];
            for(i = 0; i < seederTerrains.length; i++)
            {
               for(j = 0; j < seedTerrains.length; j++)
               {
                  if(seederTerrains[i] == seedTerrains[j])
                  {
                     m_arrAcceptableTerrain.push(seedTerrains[j]);
                  }
               }
            }
         }
      }
      
      override protected function performClickTracking() : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_VEHICLE,ClickTrackingConstants.CLICK_TYPE_COMBINE);
      }
      
      override protected function isSelectable(plot:Plot) : Boolean
      {
         return plot != null && !plot.isPlanted() && plot.isClearable() && isPlotOnAcceptableTerrain(plot);
      }
   }
}

