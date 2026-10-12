package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class InstantGrowContextGate extends ContextMenuGateHelper
   {
      
      public function InstantGrowContextGate(building:FeatureBuilding)
      {
         super(building);
      }
      
      override public function shouldDisplay() : Boolean
      {
         return Boolean(m_building.instantGrow) && m_building.instantGrow.canInstantGrow();
      }
   }
}

