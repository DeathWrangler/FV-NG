package Transactions
{
   public class TSaveFeatureOptions extends TFarmTransaction
   {
      
      private var m_options:Object;
      
      public function TSaveFeatureOptions(options:Object)
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
         signedCall("UserService.saveFeatureOptions",this.m_options);
      }
   }
}

