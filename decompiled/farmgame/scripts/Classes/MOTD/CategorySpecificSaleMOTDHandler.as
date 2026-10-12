package Classes.MOTD
{
   import Display.UI;
   
   public class CategorySpecificSaleMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function CategorySpecificSaleMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         if(m_currentMOTD["autoAccept"] == "true")
         {
            this.acceptMOTD();
            m_isFinished = true;
         }
         else
         {
            super.execute();
         }
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         var type:String = Global.categorySpecificSalesManager.category;
         var subType:String = Global.categorySpecificSalesManager.subcategory;
         UI.displayMarketDialog("category_sale_motd",type,null,subType);
      }
   }
}

