package Classes
{
   public class NurseryBuildingFinished extends NurseryBuilding
   {
      
      public function NurseryBuildingFinished(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override protected function shouldShowOverlayOnAdd() : Boolean
      {
         return false;
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         ++m_storageLevel;
         completeBuildable();
         m_isFullyBuilt = true;
         super.onFinishPlace(transactionResult);
      }
   }
}

