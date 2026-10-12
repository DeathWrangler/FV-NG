package Transactions
{
   import Classes.Constants.WorldsConstants;
   import Engine.Events.LoaderEvent;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import Managers.WorldManager;
   import flash.events.Event;
   
   public class TBaseWorldLoad extends TFarmTransaction
   {
      
      protected var m_manager:WorldManager;
      
      private var m_travelStartTime:Number;
      
      public function TBaseWorldLoad(manager:WorldManager)
      {
         super();
         this.m_manager = manager;
         this.m_travelStartTime = GlobalEngine.currentTime;
      }
      
      override public function perform() : void
      {
         throw new Error("TBaseWorldLoad::perform must be overridden by subclass");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var worldLoadTime:int;
         var transactionTime:int = (GlobalEngine.currentTime - this.m_travelStartTime) / 1000;
         this.m_manager.worldRecieved();
         Global.world.cleanup();
         if(Boolean(result) && Boolean(result.user) && Boolean(result.user.currentWorldType))
         {
            this.m_manager.setCurrentWorldType(result.user.currentWorldType);
         }
         else
         {
            this.m_manager.setCurrentWorldType(WorldsConstants.WORLD_ID_HOME);
         }
         LoadingManager.getInstance().addEventListener(LoaderEvent.ALL_HIGH_PRIORITY_LOADED,this.onAssetLoadComplete);
         try
         {
            Global.world.loadObject(result.world);
         }
         catch(error:Error)
         {
            WorldManager.trackFastTravelStat("clientException","TBaseWorldLoad-onComplete-loadObject",result.user.currentWorldType,error.message);
         }
         this.m_manager.worldLoaded(result);
         worldLoadTime = (GlobalEngine.currentTime - this.m_travelStartTime) / 1000;
         FarmStatsManager.count("world_travel",Global.worldManager.previousWorldType,Global.worldManager.currentWorldType,transactionTime.toString(),worldLoadTime.toString());
         this.m_manager.onTWorldLoadFinalCompleted();
      }
      
      protected function onAssetLoadComplete(event:Event) : void
      {
         LoadingManager.getInstance().removeEventListener(LoaderEvent.ALL_HIGH_PRIORITY_LOADED,this.onAssetLoadComplete);
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         this.m_manager.onFault(errorType,errorData);
      }
   }
}

