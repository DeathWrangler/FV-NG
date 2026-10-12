package Classes
{
   public class SheepPenConstructionBuilding extends ConstructionBuilding
   {
      
      public function SheepPenConstructionBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function onFullyFinished(result:Object, transformedObj:MapResource = null) : void
      {
         var constructionBuildingFinishedRewardManager:ConstructionBuildingFinishedRewardHandler = null;
         super.onFullyFinished(result,transformedObj);
         if(null != result.gift)
         {
            constructionBuildingFinishedRewardManager = new ConstructionBuildingFinishedRewardHandler(this.buildingName);
            constructionBuildingFinishedRewardManager.giveFinishedReward(result.gift,false);
         }
      }
   }
}

