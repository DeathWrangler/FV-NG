package Classes.FeatureComponents
{
   import Classes.BushelBaby.BushelBabySystem;
   import Classes.FeatureBuilding;
   import Events.DynamicObjectEvent;
   import Managers.BushelBabyManager;
   
   public class BushelBabyImageProgessionFObject extends DeferredImageProgressionFObject
   {
      
      public function BushelBabyImageProgessionFObject(owner:FeatureBuilding)
      {
         super(owner);
         BushelBabyManager.instance.addEventListener(BushelBabyManager.LEVELUP_EVENT,this.levelUpHandler);
      }
      
      public function levelUpHandler(event:DynamicObjectEvent) : void
      {
         var system:BushelBabySystem = null;
         if(Boolean(event.data) && Boolean(event.data.hasOwnProperty("system")) && Boolean(event.data.system))
         {
            system = event.data.system as BushelBabySystem;
            if(system)
            {
               if(m_owner.assetKey == system.name)
               {
                  this.doSetProgression(true);
               }
            }
         }
      }
      
      override public function onDetatch() : void
      {
         BushelBabyManager.instance.removeEventListener(BushelBabyManager.LEVELUP_EVENT,this.levelUpHandler);
         super.onDetatch();
      }
      
      override public function doSetProgression(redraw:Boolean = false) : void
      {
         var level:int = BushelBabyManager.instance.getCurrentBuildLevel(m_owner.assetKey);
         m_owner.setOverlayOverride(level,redraw);
      }
   }
}

