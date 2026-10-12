package Transactions
{
   import Classes.MapResource;
   import Classes.Player;
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCDragonBreeding;
   import Classes.UGC.UGCFeedImage;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.UserContentManager;
   
   public class TUGCItemPlace extends TCustomPlace
   {
      
      private var m_ugcRewardUrl:String;
      
      public function TUGCItemPlace(ugcResource:IUGCMapResource, ugcUuid:String = null, isGift:Boolean = false, containerId:int = 0)
      {
         var giftMetadataIndex:int = 0;
         var itemCode:String = null;
         var storageItem:StorageItem = null;
         var extraData:Array = null;
         var metadata:String = null;
         var dataIdx:uint = 0;
         var dataLen:uint = 0;
         var mapResource:MapResource = ugcResource as MapResource;
         super(mapResource,isGift,containerId);
         m_params.metadata = ugcUuid;
         if(isGift)
         {
            giftMetadataIndex = Player.INVALID_META_DATA_INDEX;
            itemCode = mapResource.getItem().code;
            if(ugcUuid == null)
            {
               giftMetadataIndex = Global.player.getLastGiftMetadataIndex(itemCode);
               if(itemCode == "91yv")
               {
                  giftMetadataIndex = 0;
               }
            }
            else
            {
               storageItem = Global.player.getGiftStorageItem(itemCode);
               extraData = storageItem.getAllExtraData();
               dataIdx = 0;
               dataLen = extraData.length;
               while(dataIdx < dataLen)
               {
                  metadata = extraData[dataIdx] as String;
                  if(metadata == ugcUuid)
                  {
                     giftMetadataIndex = int(dataIdx);
                     break;
                  }
                  dataIdx++;
               }
            }
            if(giftMetadataIndex <= Player.INVALID_META_DATA_INDEX)
            {
               ErrorManager.addError("TUGCItemPlace: Invalid giftMetadataIndex=" + giftMetadataIndex);
            }
            else
            {
               Global.player.removeGiftWithKey(itemCode,1,giftMetadataIndex);
               m_params.giftMetadataIndex = giftMetadataIndex;
            }
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         this.onUGCRewardUrl(result);
      }
      
      protected function onUGCRewardUrl(result:Object) : void
      {
         var mapResource:MapResource = null;
         var itemCode:String = null;
         var statsKingdom:String = null;
         var rewardLink:String = null;
         var ugcImage:UGCFeedImage = null;
         if(Boolean(result) && Boolean(result.ugcRewardUrl))
         {
            StatsManager.count(UGCConstants.STATS_COUNTER,"place",m_item.name);
            mapResource = m_object as MapResource;
            itemCode = mapResource.getItem().code;
            statsKingdom = m_item.name + "_place";
            rewardLink = result.rewardLink;
            this.m_ugcRewardUrl = result.ugcRewardUrl;
            ugcImage = this.getFeedImage();
            if(!(m_object as UGCDragonBreeding))
            {
               UserContentManager.getInstance().createFeedImage(ugcImage,function(result:Object):void
               {
                  if(result.hasOwnProperty("imagePath"))
                  {
                     createRewardFeed("ShareMessage_" + m_item.name,statsKingdom,m_ugcRewardUrl,result.imagePath);
                  }
               });
            }
         }
      }
      
      private function getFeedImage() : UGCFeedImage
      {
         var mapResource:MapResource = m_object as MapResource;
         var ugcImage:UGCFeedImage = new UGCFeedImage(mapResource,UserContentManager.FEATURE_UGC_EDITOR);
         ugcImage.applyConfigTransforms(m_item.ugcTransforms);
         return ugcImage;
      }
      
      private function createRewardFeed(feedActionName:String, statsKingdom:String, rewardLink:String, iconURL:String, postFeedCallback:Function = null, dialogIconURL:String = null, postFeedCallbackAccept:Function = null, friendlyItemName:String = null, locParams:Object = null, statsClass:String = "", dialogName:String = null, finishedRewardItemName:String = "") : void
      {
         var bundleData:Object = null;
         var localizedText:String = null;
         var hasLocalization:Boolean = ZLocUtils.hasString("Dialogs",feedActionName);
         if(Boolean(rewardLink) && hasLocalization)
         {
            bundleData = {
               "actor":Global.player.snUser.firstName,
               "reward_link":rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":iconURL
               }]
            };
            if(friendlyItemName != null)
            {
               bundleData["item"] = friendlyItemName;
            }
            if(!dialogIconURL)
            {
               dialogIconURL = iconURL;
            }
            if(locParams)
            {
               localizedText = ZLocUtils.t("Dialogs",feedActionName,locParams);
            }
            else
            {
               localizedText = ZLocUtils.t("Dialogs",feedActionName);
            }
            UI.displayPopup(new GenericIconPopup(localizedText,GenericPopup.TYPE_SHARECANCEL,this.generateOnConfirmShareFeed(feedActionName,bundleData,statsKingdom,statsClass,m_item.name,postFeedCallback,postFeedCallbackAccept),dialogIconURL));
         }
      }
      
      protected function generateOnConfirmShareFeed(feedAction:String, bundleData:Object, statsKingdon:String, statsClass:String, itemName:String, callbackFunction:Function = null, callbackFunctionOnAccept:Function = null) : Function
      {
         return function(event:GenericPopupEvent):void
         {
            if(event.button == GenericPopup.ACCEPT)
            {
               GlobalEngine.socialNetwork.publishFeedStory(feedAction,bundleData,[],false);
               if(callbackFunctionOnAccept != null)
               {
                  callbackFunctionOnAccept();
               }
            }
            else
            {
               TransactionManager.addTransaction(new TCancelFriendReward([bundleData["reward_link"]]));
            }
         };
      }
   }
}

