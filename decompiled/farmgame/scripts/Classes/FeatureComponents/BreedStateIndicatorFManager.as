package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class BreedStateIndicatorFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      public function BreedStateIndicatorFManager(owner:FeatureBuilding)
      {
         m_owner = owner;
         super(owner);
      }
      
      override public function canDisplay() : Boolean
      {
         return true;
      }
      
      override public function show(state:String = "default") : void
      {
         var animalState:AnimalBreedingState = this.owner.extraDataState as AnimalBreedingState;
         if(animalState != null && animalState.getNumCompletedSessions() > 0)
         {
            state = "breed_ready";
            super.show(state);
         }
      }
      
      override public function hide() : void
      {
         super.hide();
      }
   }
}

