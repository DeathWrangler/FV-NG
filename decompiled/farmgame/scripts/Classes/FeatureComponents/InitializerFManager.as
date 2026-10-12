package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class InitializerFManager extends FeatureManager implements IInitializeComponent
   {
      
      public function InitializerFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function initializeOnPlace() : void
      {
         this.owner.setFullGrown();
      }
   }
}

