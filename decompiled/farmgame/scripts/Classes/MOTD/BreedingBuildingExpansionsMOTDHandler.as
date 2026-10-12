package Classes.MOTD
{
   import Display.UI;
   import Widgets.Windows.Breeding.BreedingBuildingExpansionMOTD;
   
   public class BreedingBuildingExpansionsMOTDHandler extends MOTDHandler
   {
      
      private var m_bought:Boolean = false;
      
      public function BreedingBuildingExpansionsMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         var motdDialog:BreedingBuildingExpansionMOTD = new BreedingBuildingExpansionMOTD(this.onBought,this.closeMOTD);
         UI.displayPopup(motdDialog,false);
         super.execute();
      }
      
      private function onBought() : void
      {
         if(!this.m_bought)
         {
            acceptMOTD();
            this.m_bought = true;
         }
      }
      
      override protected function closeMOTD() : void
      {
         if(!this.m_bought)
         {
            super.closeMOTD();
         }
      }
   }
}

