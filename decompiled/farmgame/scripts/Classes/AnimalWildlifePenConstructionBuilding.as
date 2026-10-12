package Classes
{
   public class AnimalWildlifePenConstructionBuilding extends ConstructionBuilding
   {
      
      public function AnimalWildlifePenConstructionBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
      }
      
      override public function onFullyFinished(result:Object, transformedObj:MapResource = null) : void
      {
         var constructionBuildingFinishedRewardManager:ConstructionBuildingFinishedRewardHandler = null;
         super.onFullyFinished(result,transformedObj);
         if(null != result.gift && m_transformObj != null)
         {
            constructionBuildingFinishedRewardManager = new ConstructionBuildingFinishedRewardHandler(this.buildingName);
            constructionBuildingFinishedRewardManager.addRewardToBuilding(result.gift,m_transformObj);
         }
      }
      
      override public function transformBuilding(resultData:Object = null) : MapResource
      {
         m_transformObj = super.transformBuilding(resultData);
         return m_transformObj;
      }
   }
}

