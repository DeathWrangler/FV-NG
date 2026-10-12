package Engine.Classes
{
   import Engine.Interfaces.IEngineComponent;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.ZaspManager;
   
   public class ZEngineOptions
   {
      
      public var viewportClass:Class = Viewport;
      
      public var zaspManagerClass:Class = ZaspManager;
      
      public var tileMapClass:Class = null;
      
      public var socialNetworkUserClass:Class = SocialNetworkUser;
      
      public var loadingManagerClass:Class = LoadingManager;
      
      public var sendLoadingManagerStats:Boolean = false;
      
      public var tileWidth:uint = 24;
      
      public var tileHeight:uint = 12;
      
      public var tileScale:Number = 1;
      
      public var baseService:String = "BaseService.dispatchBatch";
      
      public var numShards:int = 16;
      
      public var engineComponents:Vector.<IEngineComponent> = new Vector.<IEngineComponent>();
      
      public function ZEngineOptions()
      {
         super();
      }
      
      public function addComponent(param1:IEngineComponent) : void
      {
         this.engineComponents.push(param1);
      }
   }
}

