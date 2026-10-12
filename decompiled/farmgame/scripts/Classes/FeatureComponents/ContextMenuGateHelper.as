package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class ContextMenuGateHelper
   {
      
      protected var m_building:FeatureBuilding;
      
      public function ContextMenuGateHelper(building:FeatureBuilding)
      {
         super();
         this.m_building = building;
      }
      
      public function shouldDisplay() : Boolean
      {
         GlobalEngine.error("ContextMenuGateHelper.shouldDisplay()","function needs to be overriden");
         return false;
      }
   }
}

