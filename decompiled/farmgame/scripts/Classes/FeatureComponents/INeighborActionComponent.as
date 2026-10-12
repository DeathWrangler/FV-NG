package Classes.FeatureComponents
{
   import Classes.NeighborActions.BaseNeighborAction;
   
   public interface INeighborActionComponent
   {
      
      function getAction() : BaseNeighborAction;
      
      function get key() : String;
   }
}

