package Managers
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Display.RetentionGiftItemPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import flash.utils.Dictionary;
   
   public class RetentionGiftItemUtil
   {
      
      private static var s_freeItemList:Dictionary = null;
      
      public function RetentionGiftItemUtil()
      {
         super();
      }
      
      public static function awardRetentionGifts() : void
      {
         var validItemObj:Object = null;
         var itemObj:Object = null;
         var itemList:Dictionary = getRetentionGiftItems();
         for each(itemObj in itemList)
         {
            if(Boolean(itemObj.prereqs) && PrerequisiteUtility.evalPrereqsXML(itemObj.prereqs))
            {
               validItemObj = itemObj;
               break;
            }
         }
         if(validItemObj != null && validItemObj.name != null)
         {
            TransactionManager.addTransaction(new TGenericTransaction("UserService","onGiveRetentionItemWithPrereqs",onComplete,[itemObj.name]),true);
         }
      }
      
      private static function getRetentionGiftItems() : Dictionary
      {
         var rawXml:XML = null;
         var freeItemObj:Object = null;
         var xmlItem:XML = null;
         if(s_freeItemList == null)
         {
            s_freeItemList = new Dictionary();
            rawXml = Global.farmGameSettingsManager.getXML();
            if(rawXml.retentionGiftItems)
            {
               for each(xmlItem in rawXml.retentionGiftItems.giftItem)
               {
                  freeItemObj = new Object();
                  freeItemObj.name = xmlItem.@name.toString();
                  freeItemObj.prereqs = xmlItem.prereqs.prereq;
                  freeItemObj.rewards = xmlItem.rewards[0];
                  s_freeItemList[freeItemObj.name] = freeItemObj;
               }
            }
         }
         return s_freeItemList;
      }
      
      protected static function onComplete(result:Object) : void
      {
         var itemList:Dictionary = null;
         var rewards:Vector.<Object> = null;
         var placeableItem:FarmItem = null;
         var reward:Object = null;
         var i:int = 0;
         var itemName:String = null;
         if(result)
         {
            if(Boolean(result.hasOwnProperty("giftItemName") && result.giftItemName && result.hasOwnProperty("dialogKey") && result.dialogKey && result.hasOwnProperty("counter") && result.counter && result.hasOwnProperty("dialogURL") && result.dialogURL && result.hasOwnProperty("dialogTitle") && result.dialogTitle) && Boolean(result.hasOwnProperty("dialogAccept")) && Boolean(result.dialogAccept))
            {
               itemList = getRetentionGiftItems();
               if(itemList[result.giftItemName])
               {
                  rewards = UserRewardUtil.getRewardsVectorFromXml(itemList[result.giftItemName].rewards);
                  UserRewardUtil.grantUserRewards(rewards);
                  for(i = 0; i < rewards.length; i++)
                  {
                     reward = rewards[i];
                     if(reward.type == QuestConstants.REWARD_GRANT_ITEM)
                     {
                        placeableItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                        break;
                     }
                  }
                  itemName = placeableItem != null ? placeableItem.name : null;
                  UI.displayPopup(new RetentionGiftItemPopup(result.dialogURL,[itemName],result.counter,result.dialogAccept,result.dialogTitle));
               }
            }
         }
      }
   }
}

