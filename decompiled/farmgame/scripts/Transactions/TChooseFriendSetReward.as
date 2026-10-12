package Transactions
{
   import Classes.FeatureDataObjects.ItemFeatureFriendSet;
   import Engine.Classes.WorldObject;
   
   public class TChooseFriendSetReward extends TFarmTransaction
   {
      
      private static const STATUS_REWARD_TRANSFORM_SUCCESS:Number = 1;
      
      private static const STATUS_REWARD_KEEP_SUCCESS:Number = 2;
      
      protected var m_friendSet:ItemFeatureFriendSet;
      
      protected var m_worldId:Number = 0;
      
      protected var m_rewardItemCode:String = "";
      
      protected var m_callback:Function = null;
      
      public function TChooseFriendSetReward(dataObj:ItemFeatureFriendSet, worldId:Number, rewardItemCode:String, callback:Function = null)
      {
         this.m_friendSet = dataObj;
         this.m_rewardItemCode = rewardItemCode;
         this.m_worldId = worldId;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ItemFriendSetService.chooseFriendSetReward",this.m_friendSet.code,this.m_worldId,this.m_friendSet.index,this.m_rewardItemCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var worldObject:WorldObject = null;
         if(Boolean(result.status) && Boolean(result.data))
         {
            worldObject = Global.world.getObjectById(this.m_worldId);
            switch(result.status)
            {
               case STATUS_REWARD_TRANSFORM_SUCCESS:
                  if(worldObject != null)
                  {
                     worldObject.detach();
                     Global.player.addGift(Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_rewardItemCode));
                  }
                  if(this.m_callback != null)
                  {
                     this.m_callback(result);
                  }
                  break;
               case STATUS_REWARD_KEEP_SUCCESS:
                  if(this.m_callback != null)
                  {
                     this.m_callback(result);
                  }
            }
         }
      }
   }
}

