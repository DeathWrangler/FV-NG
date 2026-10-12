package Transactions
{
   import Classes.TurkeyRoostBuilding;
   
   public class TGetAskForTurkeyRequestFeed extends TWorldState
   {
      
      private var m_callback:Function = null;
      
      public function TGetAskForTurkeyRequestFeed(building:TurkeyRoostBuilding, callback:Function = null)
      {
         this.m_callback = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("getTurkeyRequestFeed");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

