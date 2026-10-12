package Transactions
{
   import Engine.Classes.WorldObject;
   
   public class TUnlockFestivalOfColorGraphic extends TWorldState
   {
      
      protected var m_callback:Function;
      
      public function TUnlockFestivalOfColorGraphic(object:WorldObject, callback:Function = null)
      {
         this.m_callback = callback;
         super(object);
      }
      
      override public function perform() : void
      {
         signedWorldAction("UnlockFestivalOfColorGraphic",{});
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

