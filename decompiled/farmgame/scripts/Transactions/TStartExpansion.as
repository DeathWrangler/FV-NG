package Transactions
{
   import Classes.StorageBuilding;
   
   public class TStartExpansion extends TWorldState
   {
      
      private var m_callBack:Function;
      
      public function TStartExpansion(building:StorageBuilding, callback:Function = null)
      {
         this.m_callBack = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("startExpansion");
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_callBack !== null)
         {
            this.m_callBack.call(null,result);
         }
      }
   }
}

