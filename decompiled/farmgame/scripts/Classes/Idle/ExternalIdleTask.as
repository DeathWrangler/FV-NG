package Classes.Idle
{
   import flash.external.ExternalInterface;
   
   public class ExternalIdleTask extends BaseIdleTask
   {
      
      private var m_callback:String = "";
      
      public function ExternalIdleTask(callback:String = "")
      {
         super();
         this.m_callback = callback;
      }
      
      override public function fire() : void
      {
         try
         {
            if(Boolean(this.m_callback) && ExternalInterface.available)
            {
               ExternalInterface.call(this.m_callback);
            }
         }
         catch(err:Error)
         {
         }
      }
   }
}

