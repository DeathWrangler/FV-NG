package Classes
{
   public class NurseryConstructionBuilding extends ConstructionBuilding
   {
      
      public function NurseryConstructionBuilding(buildingType:String = null)
      {
         super(buildingType);
         m_displayStorageDialog = false;
      }
   }
}

