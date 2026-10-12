package Transactions
{
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.SuperCropFriendSet;
   import Classes.ZItem.ClothingItem;
   import Classes.ZItem.FarmItem;
   
   public class TCompleteFriendSet extends TFarmTransaction
   {
      
      protected static const STATUS_BUY_FRIENDS_SUCCESS:Number = 1;
      
      protected static const STATUS_BUY_ALREADY_COMPLETE:Number = 2;
      
      protected var m_friendSet:FriendSet;
      
      protected var m_callback:Function = null;
      
      public function TCompleteFriendSet(dataObj:FriendSet, callback:Function = null)
      {
         this.m_friendSet = dataObj;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         var serviceClass:String = "ItemFriendSetService";
         switch(this.m_friendSet.className)
         {
            case FriendSet.ITEM_FEATURE_FRIEND_SET:
               serviceClass = "ItemFriendSetService";
               break;
            case FriendSet.SUPER_CROP_FRIEND_SET:
               signedCall("SuperCropsService.completeFriendSet",(this.m_friendSet as SuperCropFriendSet).cropCode);
               return;
            case FriendSet.LONELYANIMAL_FEATURE_FRIEND_SET:
               serviceClass = "LonelyAnimalFriendSetService";
               break;
            default:
               serviceClass = "FriendSetService";
         }
         signedCall(serviceClass + ".completeFriendSet",this.m_friendSet.code,this.m_friendSet.index);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result.status) && Boolean(result.data))
         {
            if(result.cost)
            {
               Global.player.cash -= Number(result.cost);
            }
            switch(result.status)
            {
               case STATUS_BUY_FRIENDS_SUCCESS:
                  this.grantGifts(result);
                  this.m_friendSet.onInitialize(result.data);
                  if(this.m_callback != null)
                  {
                     this.m_callback();
                  }
                  break;
               case STATUS_BUY_ALREADY_COMPLETE:
                  if(this.m_callback != null)
                  {
                     this.m_callback();
                  }
            }
         }
      }
      
      protected function grantGifts(result:Object) : void
      {
         var giftsNameArray:Array = null;
         var index:int = 0;
         var gift:FarmItem = null;
         if(result["gifts"])
         {
            giftsNameArray = result["gifts"];
            if(giftsNameArray)
            {
               for(index = 0; index < giftsNameArray.length; index++)
               {
                  gift = Global.farmGameSettingsManager.getFarmItemByName(giftsNameArray[index]);
                  if(gift)
                  {
                     if(gift is ClothingItem)
                     {
                        Global.player.avatarState.grantItem(gift.code);
                     }
                     else
                     {
                        Global.player.addGift(gift.name);
                     }
                  }
               }
            }
         }
      }
   }
}

