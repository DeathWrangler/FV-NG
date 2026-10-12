package Transactions
{
   import Managers.FishingDerbyManager;
   import Managers.WorldManager;
   
   public class TLoadStaticWorld extends TBaseWorldLoad
   {
      
      public static const METHOD_LOAD_WORLD:String = "loadStaticWorld";
      
      private var m_worldType:String;
      
      public function TLoadStaticWorld(worldType:String, manager:WorldManager)
      {
         super(manager);
         this.m_worldType = worldType;
      }
      
      override public function perform() : void
      {
         signedCall("StaticWorldService." + METHOD_LOAD_WORLD,this.m_worldType);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_worldType == "angler")
         {
            FishingDerbyManager.instance.init(null,result.m_gameMode);
         }
      }
   }
}

