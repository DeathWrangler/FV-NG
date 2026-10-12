package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Events.FarmGameWorldEvent;
   
   public class DeferredImageProgressionFObject extends BaseImageProgressionObject
   {
      
      private var m_deferredCall:Boolean = false;
      
      public function DeferredImageProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function setProgression() : void
      {
         if(Global.player.postInitFinished)
         {
            this.doSetProgression();
         }
         else if(!this.m_deferredCall)
         {
            this.m_deferredCall = true;
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredSetProgression,false,0,true);
         }
      }
      
      private function deferredSetProgression(event:FarmGameWorldEvent) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredSetProgression);
         this.m_deferredCall = false;
         this.doSetProgression(true);
      }
      
      public function doSetProgression(redraw:Boolean = false) : void
      {
      }
   }
}

