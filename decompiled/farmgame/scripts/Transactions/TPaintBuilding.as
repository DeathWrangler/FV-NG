package Transactions
{
   import Classes.StorageBuilding;
   
   public class TPaintBuilding extends TWorldState
   {
      
      private var m_building:StorageBuilding = null;
      
      private var m_params:Object = new Object();
      
      public function TPaintBuilding(building:StorageBuilding, paintItemName:String)
      {
         this.m_building = building;
         this.m_params.paintItemName = paintItemName;
         super(this.m_building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("paint",this.m_params);
      }
   }
}

