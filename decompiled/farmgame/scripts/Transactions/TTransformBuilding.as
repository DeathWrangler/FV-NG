package Transactions
{
   import Classes.ConstructionBuilding;
   import Classes.MapResource;
   
   public class TTransformBuilding extends TWorldState
   {
      
      public static const ACTION_TRANSFORM_BUILDING:String = "TransformBuilding";
      
      protected var m_building:ConstructionBuilding;
      
      protected var m_transformOnComplete:Boolean;
      
      protected var m_successCallback:Function;
      
      public function TTransformBuilding(building:ConstructionBuilding, transformOnComplete:Boolean = false, callback:Function = null)
      {
         this.m_building = building;
         this.m_transformOnComplete = transformOnComplete;
         this.m_successCallback = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_TRANSFORM_BUILDING);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var transformedObject:MapResource = null;
         super.onComplete(result);
         if(Boolean(result) && Boolean(this.m_building))
         {
            if(this.m_transformOnComplete)
            {
               transformedObject = this.m_building.transformBuilding(result);
               result.transformedBuilding = transformedObject;
               this.m_building.onFullyFinished(result,transformedObject);
            }
            else
            {
               this.m_building.onFullyFinished(result);
            }
            if(this.m_successCallback !== null)
            {
               this.m_successCallback.call(null,result);
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_TRANSFORM_BUILDING;
         result.item = this.m_building.getItem();
         result.building = this.m_building;
         return result;
      }
   }
}

