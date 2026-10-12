package Transactions
{
   import Classes.PigpenBuilding;
   
   public class TPigHunt extends TWorldState
   {
      
      private var m_pigpen:PigpenBuilding;
      
      private var m_pigCode:String;
      
      public function TPigHunt(worldObj:PigpenBuilding, pigCode:String)
      {
         super(worldObj);
         this.m_pigpen = worldObj;
         this.m_pigCode = pigCode;
      }
      
      override public function perform() : void
      {
         signedWorldAction("huntTruffle",this.m_pigCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         result.pigCode = this.m_pigCode;
         this.m_pigpen.onHuntComplete(result);
      }
   }
}

