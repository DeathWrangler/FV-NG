package Transactions
{
   import Engine.Classes.WorldObject;
   
   public class TTransformPartyBuilding extends TWorldState
   {
      
      public static const ACTION_TRANSFORM_BUILDING:String = "TransformPartyBuilding";
      
      public function TTransformPartyBuilding(worldObj:WorldObject)
      {
         super(worldObj);
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_TRANSFORM_BUILDING);
      }
   }
}

