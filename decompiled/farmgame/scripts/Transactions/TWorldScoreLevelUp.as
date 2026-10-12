package Transactions
{
   public class TWorldScoreLevelUp extends TFarmTransaction
   {
      
      public static const METHOD_UPDATE_WORLD_SCORE_LEVEL_UP:String = "updateWorldScoreLevelUp";
      
      private var m_worldLevel:int;
      
      private var m_worldScoreUnit:String;
      
      public function TWorldScoreLevelUp(worldScoreUnit:String, worldLevel:int)
      {
         super();
         this.m_worldLevel = worldLevel;
         this.m_worldScoreUnit = worldScoreUnit;
      }
      
      override public function perform() : void
      {
         signedCall("UserService." + METHOD_UPDATE_WORLD_SCORE_LEVEL_UP,this.m_worldScoreUnit);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.worldScoreLevel = this.m_worldLevel;
         result.worldScoreUnit = this.m_worldScoreUnit;
         result.method = METHOD_UPDATE_WORLD_SCORE_LEVEL_UP;
         return result;
      }
   }
}

