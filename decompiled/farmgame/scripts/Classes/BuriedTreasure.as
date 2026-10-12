package Classes
{
   import Engine.Classes.Observer.IObserver;
   import Engine.Classes.World;
   import Engine.Helpers.Vector3;
   import Managers.BuriedTreasureManager;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BuriedTreasure extends NonCollidableMapResource implements IObserver
   {
      
      protected static const ANIMATION_TIME:int = 4000;
      
      private var m_plot:Plot;
      
      private var m_animationTimer:Timer;
      
      public function BuriedTreasure(itemName:String, plot:Plot = null)
      {
         var observedEvents:Vector.<String> = null;
         super(itemName);
         this.m_plot = plot;
         this.m_animationTimer = new Timer(ANIMATION_TIME);
         if(this.m_plot)
         {
            this.setPositionFromPlot();
            observedEvents = new Vector.<String>();
            observedEvents.push(MapResource.OBSERVABLE_EVENT_STATE,MapResource.OBSERVABLE_EVENT_ALPHA,FarmGameObject.OBSERVABLE_EVENT_MOVE,FarmGameObject.OBSERVABLE_EVENT_PLACE);
            this.m_plot.addObserver(this,observedEvents);
            observedEvents = new Vector.<String>();
            observedEvents.push(World.OBSERVABLE_EVENT_DETACH);
            Global.world.addObserver(this,observedEvents);
         }
      }
      
      override public function getCurrentImageName() : String
      {
         return "static";
      }
      
      public function notify(event:String, data:Object) : void
      {
         switch(event)
         {
            case FarmGameObject.OBSERVABLE_EVENT_PLACE:
               if(Boolean(data.obj) && data.obj == this.m_plot)
               {
                  this.setPositionFromPlot();
                  conditionallyReattach(true);
               }
         }
      }
      
      private function setPositionFromPlot() : void
      {
         var plotPosition:Vector3 = this.m_plot.getPositionNoClone();
         setPosition(plotPosition.x,plotPosition.y,plotPosition.z);
      }
      
      override public function isUsingPerPixelPick() : Boolean
      {
         return true;
      }
      
      override public function detach() : void
      {
         this.helpCleanup();
         super.detach();
      }
      
      override public function attach() : void
      {
         this.startAnimationTimer();
         super.attach();
      }
      
      override public function cleanUp() : void
      {
         this.helpCleanup();
         super.cleanUp();
      }
      
      private function helpCleanup() : void
      {
         if(this.m_plot)
         {
            this.m_plot.removeObserver(this);
            Global.world.removeObserver(this);
            this.m_animationTimer.removeEventListener(TimerEvent.TIMER,this.onAnimationStop);
         }
      }
      
      protected function stopAnimationTimer() : void
      {
         this.m_animationTimer.stop();
      }
      
      protected function startAnimationTimer() : void
      {
         this.m_animationTimer.addEventListener(TimerEvent.TIMER,this.onAnimationStop);
         this.m_animationTimer.start();
      }
      
      private function onAnimationStop(event:TimerEvent) : void
      {
         BuriedTreasureManager.instance.onBuriedTreasureSeen(this);
         this.stopAnimationTimer();
      }
   }
}

