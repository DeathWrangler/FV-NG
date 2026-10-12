package Managers
{
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetIneligibleGiftRecipients;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import Widgets.Windows.MFSAddNeighbor;
   import Widgets.Windows.MFSAskCredits;
   import Widgets.Windows.MFSAskItems;
   import Widgets.Windows.MFSAskMats;
   import Widgets.Windows.MFSFriendSet;
   import Widgets.Windows.MFSSendFlashGifts;
   import Widgets.Windows.MFSSendFreeGifts;
   import Widgets.Windows.MFSSendRequestGifts;
   import Widgets.Windows.SingleRecipientSendFreeGift;
   import com.adobe.utils.ArrayUtil;
   import flash.display.StageDisplayState;
   import flash.external.ExternalInterface;
   
   public class MFSRequestManager
   {
      
      public static const R2_ADD_NEIGHBOR_IN_FLASH_FREQUENCY_FLAG:String = "r2AddNeighborInFlashPop";
      
      private static var m_instance:MFSRequestManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      private const URL_ASK_MATERIALS:String = "askmats.php";
      
      private const URL_ASK_ITEMS:String = "askreqs.php";
      
      private const URL_FRIEND_SET:String = "friend_set_request.php";
      
      private const URL_ASK_CREDITS:String = "askcredits.php";
      
      private var m_giftItemName:String = "";
      
      private var m_source:String = "";
      
      private var m_requestMessage:String = "";
      
      private var m_recipientId:String = "";
      
      private var m_addNeighborWindow:MFSAddNeighbor = null;
      
      public function MFSRequestManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call MFSRequestManager constructor directly - use getInstance() instead.");
         }
      }
      
      public static function getInstance() : MFSRequestManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new MFSRequestManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public static function openAddNeighborTab(fromToaster:Boolean = false) : void
      {
         getInstance().displayR2AddNeighborWindow("",null);
         getInstance().m_addNeighborWindow.openAddNeighborTab();
         if(fromToaster)
         {
            Global.player.setFeatureLastShown(CommunityMatchmakingUtility.FEATURE_NAME,GlobalEngine.serverTime,true);
         }
      }
      
      public static function conditionallyDisplayR2AddNeighborWindow(source:String = "", callback:Function = null) : void
      {
         var popupCooldown:int = 0;
         var lastPopupSeen:int = 0;
         var currentTime:int = 0;
         var timeSinceLastSeen:int = 0;
         if(Global.flashHotParams["R2_NEIGHBOR_AUTOPOP_ENABLE"])
         {
            popupCooldown = Global.flashHotParams["R2_NEIGHBOR_AUTOPOP_COOLDOWN_HOURS"] * 3600;
            lastPopupSeen = Global.player.getFeatureLastShown(R2_ADD_NEIGHBOR_IN_FLASH_FREQUENCY_FLAG);
            currentTime = GlobalEngine.serverTime / 1000;
            timeSinceLastSeen = currentTime - lastPopupSeen;
            if(timeSinceLastSeen > popupCooldown)
            {
               UI.displayPopup(new MFSAddNeighbor(source,callback));
            }
         }
      }
      
      public static function executePendingTabClickForR2MFS() : void
      {
         var result:String = null;
         if(ExternalInterface.available)
         {
            try
            {
               result = ExternalInterface.call("FarmNS.GlobalStorage.get",MFSConstants.PENDING_R2_MFS_FROM_TAB_JS_GSKEY);
               if(result == MFSConstants.PENDING_R2_MFS_FROM_TAB_VALUE_FREEGIFT)
               {
                  FreeGiftSelectionWindow.popWindow();
               }
               else if(result == MFSConstants.PENDING_R2_MFS_FROM_TAB_VALUE_NEIGHBOR)
               {
                  UI.displayPopup(new MFSAddNeighbor("tab_click_pending",null));
               }
               else
               {
                  FarmStatsManager.sample(1000,"neighbor_tab","error","executePendingTabClickForR2MFS","resultDoesNotMatch",result.toString());
               }
            }
            catch(exception:*)
            {
               FarmStatsManager.sample(1000,"neighbor_tab","error","executePendingTabClickForR2MFS","tryFailed");
            }
         }
         else
         {
            FarmStatsManager.sample(1000,"neighbor_tab","error","executePendingTabClickForR2MFS","externalInterfaceIsNotAvailable");
         }
      }
      
      public static function isInR2Migration_b() : Boolean
      {
         return true;
      }
      
      public function makeSendFlashGiftsRequest(giftItemName:String, source:String) : void
      {
         var friendSpec:Object = {
            "tabNameSuggested":[MFSConstants.TYPE_SUGGESTED],
            "tabNameFarmVille":[MFSConstants.TYPE_FARMVILLE],
            "tabNameFacebook":[MFSConstants.TYPE_FACEBOOK]
         };
         var friendTabOrder:Array = ["tabNameSuggested","tabNameFarmVille","tabNameFacebook"];
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(giftItemName);
         UI.displayPopup(new MFSSendFlashGifts(friendSpec,friendTabOrder,giftItem,"flashgift",source,null),false);
      }
      
      public function makeSendFreeGiftsRequest(giftItemName:String, source:String, requestMessage:String = "", recipientId:String = "", addToQueue:Boolean = true) : void
      {
         var farmItem:FarmItem = null;
         this.m_source = source;
         this.m_giftItemName = giftItemName;
         if(recipientId != "" && requestMessage != "")
         {
            this.m_recipientId = recipientId;
            this.m_requestMessage = requestMessage;
            TransactionManager.addTransaction(new TGetIneligibleGiftRecipients(this.sendRequest),true);
         }
         else
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_giftItemName);
            UI.displayPopup(new MFSSendFreeGifts(farmItem,this.m_source,null,MFSConstants.MFS_TYPE_SEND_FREE_GIFT),addToQueue);
         }
      }
      
      public function sendRequest(result:Object) : void
      {
         var farmItem:FarmItem = null;
         var giftRequestObject:SingleRecipientSendFreeGift = null;
         if(result != null && this.m_recipientId != "" && this.m_giftItemName != "")
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_giftItemName);
            if(!this.isEligibleGiftRecipient(result))
            {
               UI.displayPopup(new MFSSendFreeGifts(farmItem,this.m_source,null,MFSConstants.MFS_TYPE_SEND_FREE_GIFT));
            }
            else
            {
               giftRequestObject = new SingleRecipientSendFreeGift(this.m_recipientId,farmItem,this.m_source,this.m_requestMessage);
               giftRequestObject.sendRequest();
            }
         }
      }
      
      public function isEligibleGiftRecipient(result:Object) : Boolean
      {
         var inEligibleIds:Number = NaN;
         var isEligible:Boolean = true;
         for each(inEligibleIds in result)
         {
            if(Number(this.m_recipientId) == inEligibleIds)
            {
               isEligible = false;
               break;
            }
         }
         return isEligible;
      }
      
      public function makeAskCreditsRequest(featureName:String, source:String, stats1:String = "", stats2:String = "", stats3:String = "", specifyItem:String = "") : void
      {
         var friendSpec:Object = {
            "tabNameSingleParts":[MFSConstants.TYPE_SINGLE_PARTS],
            "tabNameTripleParts":[MFSConstants.TYPE_TRIPLE_PARTS]
         };
         var friendTabOrder:Array = ["tabNameSingleParts","tabNameTripleParts"];
         var creditItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(specifyItem);
         if(creditItem == null)
         {
            creditItem = this.getCreditItemByFeatureName(featureName);
         }
         UI.displayPopup(new MFSAskCredits(friendSpec,friendTabOrder,creditItem,featureName,source,null),false);
      }
      
      public function makeFriendSetRequest(itemName:String, featureName:String, friendSetCode:String, currentFriendSet:Number, source:String = "", stats1:String = "", stats2:String = "", stats3:String = "", stats4:String = "") : void
      {
         var friendSpec:Object = {
            "tabNameSuggested":[MFSConstants.TYPE_SUGGESTED],
            "tabNameFarmVille":[MFSConstants.TYPE_FARMVILLE],
            "tabNameFacebook":[MFSConstants.TYPE_FACEBOOK]
         };
         var friendTabOrder:Array = ["tabNameSuggested","tabNameFarmVille","tabNameFacebook"];
         var reqItemCrew:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         UI.displayPopup(new MFSFriendSet(friendSpec,friendTabOrder,reqItemCrew,featureName,friendSetCode,String(currentFriendSet),source,null),false);
      }
      
      public function makeAskMatsRequest(featureName:String, itemName:String, ref:String = "", computeview:String = "", source:String = "", stats1:String = "", stats2:String = "", stats3:String = "", stats4:String = "") : void
      {
         var friendSpec:Object = {
            "tabNameSingleParts":[MFSConstants.TYPE_SINGLE_PARTS],
            "tabNameTripleParts":[MFSConstants.TYPE_TRIPLE_PARTS]
         };
         var friendTabOrder:Array = ["tabNameSingleParts","tabNameTripleParts"];
         var reqItemParts:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         UI.displayPopup(new MFSAskMats(friendSpec,friendTabOrder,reqItemParts,featureName,source,null),false);
      }
      
      public function makeAskItemsRequest(featureName:String, itemName:String, ref:String = "", computeview:String = "", source:String = "", friendSpec:Object = null, friendTabOrder:Array = null, stats1:String = "", stats2:String = "", stats3:String = "", stats4:String = "", callback:Function = null) : void
      {
         if(friendSpec == null || friendTabOrder == null)
         {
            friendSpec = {
               "tabNameSingleParts":[MFSConstants.TYPE_SINGLE_PARTS],
               "tabNameTripleParts":[MFSConstants.TYPE_TRIPLE_PARTS]
            };
            friendTabOrder = ["tabNameSingleParts","tabNameTripleParts"];
         }
         var reqItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         UI.displayPopup(new MFSAskItems(friendSpec,friendTabOrder,reqItem,featureName,source,callback),false);
      }
      
      public function makeSendRequestFreeGifts(itemName:String, featureName:String) : void
      {
         var reqItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         UI.displayPopup(new MFSSendRequestGifts(reqItem,featureName,"",null),false);
      }
      
      public function displayR2AddNeighborWindow(source:String = "", callback:Function = null) : void
      {
         if(getInstance().m_addNeighborWindow == null)
         {
            getInstance().m_addNeighborWindow = new MFSAddNeighbor(source,callback);
            UI.displayPopup(getInstance().m_addNeighborWindow);
         }
      }
      
      public function releaseAddNeighborWindow() : void
      {
         if(getInstance().m_addNeighborWindow != null)
         {
            getInstance().m_addNeighborWindow = null;
         }
      }
      
      private function exitFullScreen() : void
      {
         if(Global.stage.displayState == StageDisplayState.FULL_SCREEN)
         {
            Global.stage.displayState = StageDisplayState.NORMAL;
         }
      }
      
      private function getCreditItemByFeatureName(featureName:String) : FarmItem
      {
         var resultItem:FarmItem = null;
         var item:FarmItem = null;
         var basket:FarmItem = null;
         var baskets:Array = null;
         var creditItems:Array = Global.farmGameSettingsManager.getItemsByClassArray("FeatureCreditItem");
         var buildingParts:Array = Global.farmGameSettingsManager.getItemsByClassArray("BuildingPart");
         var allCreditItems:Array = ArrayUtil.createUniqueCopy(creditItems.concat(buildingParts));
         for each(item in allCreditItems)
         {
            basket = null;
            if(item.basket)
            {
               basket = Global.farmGameSettingsManager.getFarmItemByName(item.basket);
            }
            else if(item.basketClass)
            {
               baskets = Global.farmGameSettingsManager.getItemsByClassArray(item.basketClass);
               basket = baskets[0];
            }
            if(Boolean(basket && basket.name && basket.name == featureName) && (Boolean(!item.market || !item.buyableWithCash())) || Boolean(basket && basket.className) && Boolean(basket.className == featureName))
            {
               resultItem = item;
               break;
            }
         }
         return resultItem;
      }
   }
}

