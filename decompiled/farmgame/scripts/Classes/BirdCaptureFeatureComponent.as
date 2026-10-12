package Classes
{
   import Engine.Classes.World;
   import Managers.CaptureFeatureManager;
   import Managers.FarmStatsManager;
   
   public class BirdCaptureFeatureComponent extends CaptureFeatureComponent
   {
      
      public function BirdCaptureFeatureComponent(featureName:String)
      {
         var tree:Tree = null;
         var building:HarvestableStorageBuilding = null;
         super(featureName);
         for each(tree in Global.world.getObjectsByClass(Tree))
         {
            tree.addObserver(this);
         }
         for each(building in Global.world.getObjectsByClass(HarvestableStorageBuilding))
         {
            building.addObserver(this);
         }
         Global.world.addObserver(this);
      }
      
      override public function notify(event:String, data:Object) : void
      {
         var bird:CaptureFeatureItem = null;
         super.notify(event,data);
         var resource:SimpleHarvestableResource = data as SimpleHarvestableResource;
         if(resource is Tree || resource is HarvestableStorageBuilding)
         {
            switch(event)
            {
               case World.OBSERVABLE_EVENT_ATTACH:
                  resource.addObserver(this);
                  break;
               case World.OBSERVABLE_EVENT_DETACH:
                  resource.removeObserver(this);
                  break;
               case SimpleHarvestableResource.OBSERVABLE_EVENT_HARVEST:
                  if(shouldShowFeature())
                  {
                     bird = new CaptureFeatureItem(m_featureName,m_data[CaptureFeatureManager.FEATURE_NEXT_AVAILABLE_FEATURE_ITEM],resource,getSecondsFeatureShouldShow());
                     bird.setOuter(Global.world);
                     bird.attach();
                     m_data[CaptureFeatureManager.FEATURE_NEXT_AVAILABLE_TIME] = getNextTimeAfterSeen();
                     FarmStatsManager.count(statsPrefix + "s","appear",m_data[CaptureFeatureManager.FEATURE_NEXT_AVAILABLE_FEATURE_ITEM]);
                  }
            }
         }
      }
   }
}

