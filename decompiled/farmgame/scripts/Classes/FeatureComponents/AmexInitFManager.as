package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class AmexInitFManager extends InitializerFManager implements IInitializeComponent
   {
      
      public function AmexInitFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function initializeOnPlace() : void
      {
         var previouslyPlaced:Boolean = Global.player.getSeenFlag(m_owner.getItemName() + "_initialzed");
         var previouslyPlacedSession:Boolean = Global.player.getSeenSessionFlag(m_owner.getItemName() + "_initialzed");
         var firstInit:Boolean = !previouslyPlaced && !previouslyPlacedSession;
         if(firstInit)
         {
            this.owner.setFullGrown();
            Global.player.setSeenSessionFlag(m_owner.getItemName() + "_initialzed");
         }
      }
   }
}

