package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Events.FarmGameWorldEvent;
   
   public class DeferredFStateObject extends BaseImageProgressionObject
   {
      
      private var m_deferredCall:Boolean = false;
      
      public function DeferredFStateObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function setProgression() : void
      {
         if(this.checkDeferredCondition())
         {
            this.doSetProgression();
         }
         else if(!this.m_deferredCall)
         {
            this.m_deferredCall = true;
            Global.world.addEventListener(this.getDeferredEventName(),this.deferredSetProgression,false,0,true);
         }
      }
      
      protected function deferredSetProgression(event:FarmGameWorldEvent) : void
      {
         if(this.checkDeferredCondition())
         {
            Global.world.removeEventListener(this.getDeferredEventName(),this.deferredSetProgression);
            this.m_deferredCall = false;
            m_owner.reloadImage();
            this.doSetProgression(true);
         }
      }
      
      protected function getDeferredEventName() : String
      {
         return FarmGameWorldEvent.USER_POST_INIT_COMPLETE;
      }
      
      protected function checkDeferredCondition() : Boolean
      {
         return Global.player.postInitFinished;
      }
      
      protected function doSetProgression(redraw:Boolean = false) : void
      {
      }
   }
}

