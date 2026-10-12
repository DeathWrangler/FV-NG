package Transactions
{
   import Engine.Classes.WorldObject;
   
   public class TInstantGrowFeatureBuilding extends TWorldState
   {
      
      public function TInstantGrowFeatureBuilding(worldObj:WorldObject)
      {
         super(worldObj);
      }
      
      override public function perform() : void
      {
         signedWorldAction("instantGrow");
      }
   }
}

