package Transactions
{
   public class TSaveOptions extends TFarmTransaction
   {
      
      private var m_options:Object;
      
      public function TSaveOptions(options:Object)
      {
         super();
         this.m_options = options;
         if(this.m_options == null)
         {
            canPerform = false;
         }
      }
      
      override public function perform() : void
      {
         signedCall("UserService.saveOptions",this.m_options);
      }
   }
}

