package Classes
{
   import Classes.Terrain.TerrainUtil;
   import Engine.Classes.World;
   import Managers.CaptureFeatureManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   
   public class GopherCaptureFeatureComponent extends CaptureFeatureComponent
   {
      
      public function GopherCaptureFeatureComponent(featureName:String)
      {
         var plot:Plot = null;
         super(featureName);
         var plots:Array = Global.world.getObjectsByClass(Plot);
         for each(plot in plots)
         {
            plot.addObserver(this);
         }
         Global.world.addObserver(this);
      }
      
      override public function notify(event:String, data:Object) : void
      {
         var plot:Plot = null;
         var terrain:String = null;
         var gopher:CaptureFeatureItem = null;
         super.notify(event,data);
         plot = data.hasOwnProperty("object") ? data.object as Plot : data as Plot;
         if(plot)
         {
            switch(event)
            {
               case World.OBSERVABLE_EVENT_ATTACH:
                  plot.addObserver(this);
                  break;
               case World.OBSERVABLE_EVENT_DETACH:
                  plot.removeObserver(this);
                  break;
               case MapResource.OBSERVABLE_EVENT_STATE:
                  terrain = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(TerrainUtil.getTerrainCodesForItemInstance(plot));
                  if(terrain == FarmGameSettingsManager.TERRAIN_DEFAULT)
                  {
                     if(Boolean(data["state"] && data.state == Plot.STATE_PLOWED) || Boolean(data.state == Plot.STATE_PLANTED) || data.state == Plot.STATE_FALLOW)
                     {
                        if(Boolean(plot) && shouldShowFeature())
                        {
                           gopher = new CaptureFeatureItem(CaptureFeatureManager.GOPHER_FEATURE_NAME,m_data[CaptureFeatureManager.FEATURE_NEXT_AVAILABLE_FEATURE_ITEM],plot,getSecondsFeatureShouldShow());
                           gopher.setOuter(Global.world);
                           gopher.attach();
                           m_data[CaptureFeatureManager.FEATURE_NEXT_AVAILABLE_TIME] = getNextTimeAfterSeen();
                           FarmStatsManager.count(statsPrefix + "s","appear",m_data[CaptureFeatureManager.FEATURE_NEXT_AVAILABLE_FEATURE_ITEM]);
                        }
                     }
                  }
            }
         }
      }
   }
}

