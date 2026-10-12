package Transactions
{
   import Managers.WorldManager;
   
   public class TWorldPeek extends TFarmTransaction
   {
      
      private var m_startTime:Number = 0;
      
      private var m_worldType:String;
      
      protected var m_manager:WorldManager;
      
      public function TWorldPeek(worldType:String, manager:WorldManager)
      {
         super();
         this.m_worldType = worldType;
         this.m_manager = manager;
      }
      
      override public function perform() : void
      {
         GlobalEngine.info("Worlds","TWorldPeek.perform [worldType=" + this.m_worldType + "]");
         this.m_startTime = GlobalEngine.currentTime;
         signedCall("WorldService.peekWorldResult",this.m_worldType);
      }
      
      override protected function onComplete(result:Object) : void
      {
         GlobalEngine.info("Worlds","TWorldPeek.onComplete [worldType=" + this.m_worldType + "]");
         this.m_manager.onWorldPreloadResult(this.m_worldType,result);
      }
   }
}

