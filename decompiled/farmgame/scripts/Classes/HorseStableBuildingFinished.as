package Classes
{
   public class HorseStableBuildingFinished extends HorseStableBuilding
   {
      
      public function HorseStableBuildingFinished(buildingType:String)
      {
         super(buildingType);
         m_isFullyBuilt = true;
      }
      
      override protected function shouldShowOverlayOnAdd() : Boolean
      {
         return false;
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         if(!m_isFullyBuilt)
         {
            m_isFullyBuilt = true;
         }
         super.onFinishPlace(transactionResult);
      }
   }
}

