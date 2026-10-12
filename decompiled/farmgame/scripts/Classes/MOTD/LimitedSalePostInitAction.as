package Classes.MOTD
{
   import Managers.LimitedSaleUtility;
   
   public class LimitedSalePostInitAction extends MOTDHandler
   {
      
      public function LimitedSalePostInitAction(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         LimitedSaleUtility.instance().conditionallyOpenSaleDialog();
         super.execute();
      }
   }
}

