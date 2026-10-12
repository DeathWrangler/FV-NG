package Transactions
{
   import Classes.ConstructionBuilding;
   
   public class TTransformBuildingFromMOTD extends TTransformBuilding
   {
      
      public static const ACTION_TRANSFORM_BUILDING:String = "TransformBuildingFromMOTD";
      
      public function TTransformBuildingFromMOTD(building:ConstructionBuilding, transformOnComplete:Boolean = false, callback:Function = null)
      {
         super(building,transformOnComplete,callback);
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_TRANSFORM_BUILDING);
      }
   }
}

