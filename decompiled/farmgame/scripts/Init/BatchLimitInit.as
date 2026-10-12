package Init
{
   import Engine.Init.InitializationAction;
   import Engine.Managers.TransactionManager;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
   public class BatchLimitInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "BatchLimitInit";
      
      private var m_batchManager:Class = BatchLimitInit_m_batchManager;
      
      public function BatchLimitInit()
      {
         super(INIT_ID);
      }
      
      override public function execute() : void
      {
         var loader:Loader = new Loader();
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete);
         loader.loadBytes(new this.m_batchManager(),new LoaderContext(false,new ApplicationDomain()));
      }
      
      private function onLoadComplete(event:Event) : void
      {
         var loaderContent:Object = null;
         var exceptionsSetter:Function = null;
         var loader:Loader = event.currentTarget.loader as Loader;
         if(loader)
         {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadComplete);
            loaderContent = loader.content as Object;
            if(loaderContent)
            {
               TransactionManager.batchLimiter = loaderContent.getBatchLimit;
               exceptionsSetter = loaderContent.setBatchLimitFunctionExceptions as Function;
               if(exceptionsSetter != null)
               {
                  exceptionsSetter.call(null,TransactionManager.batchLimiterFunctionExceptions);
               }
            }
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

