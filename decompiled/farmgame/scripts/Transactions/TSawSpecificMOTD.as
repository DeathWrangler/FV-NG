package Transactions
{
   public class TSawSpecificMOTD extends TSawMOTD
   {
      
      protected var m_grant:Boolean = true;
      
      public function TSawSpecificMOTD(currentMOTD:Object = null, grant:Boolean = true)
      {
         super(currentMOTD);
         this.m_grant = grant;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.sawSpecificMOTD",m_currentMOTD.motdSeenFlag,this.m_grant);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_grant)
         {
            super.onComplete(result);
         }
      }
   }
}

