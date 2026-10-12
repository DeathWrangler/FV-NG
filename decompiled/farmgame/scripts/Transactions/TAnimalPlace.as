package Transactions
{
   import Classes.Animal;
   import Classes.AnimalStorageBuilding;
   import Classes.CashGrowableBaby;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class TAnimalPlace extends TCustomPlace
   {
      
      protected var m_isStorageWithdrawal:Boolean;
      
      protected var m_isFromMarket:Boolean;
      
      public var m_foalRewardUrl:String;
      
      public function TAnimalPlace(animal:Animal, isGift:Boolean = false, containerId:Number = 0, currency:String = "", isFromMarket:Boolean = false)
      {
         super(animal,isGift,containerId);
         m_params.currency = currency;
         this.m_isStorageWithdrawal = containerId > 0;
         this.m_isFromMarket = isFromMarket;
         if(isGift)
         {
            Global.player.removeGift(animal);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var animal:Animal = null;
         var building:AnimalStorageBuilding = null;
         var animalItem:FarmItem = null;
         super.onComplete(result);
         if(!this.m_isStorageWithdrawal && Boolean(result.foalRewardUrl))
         {
            animal = m_object as Animal;
            if(animal.getItem().hasFoal)
            {
               if(animal.getItem().canShareFoal)
               {
                  this.onFoalRewardUrl(result);
               }
            }
         }
         else
         {
            building = Global.world.getObjectById(m_params.isStorageWithdrawal) as AnimalStorageBuilding;
            if(building != null)
            {
               building.isBusy = false;
            }
         }
         if(m_object is CashGrowableBaby)
         {
            FarmStatsManager.count("Constructable","place_structure",(m_object as CashGrowableBaby).breedingBuildingType + "_baby",Global.worldManager.currentWorldType);
         }
         if(this.m_isFromMarket)
         {
            animalItem = (m_object as Animal).getItem();
            if(animalItem.isVipItem())
            {
               FarmStatsManager.count("MondaySinkPurchase","VIPTab_Market",animalItem.name,animalItem.realCashCost.toString());
            }
         }
      }
      
      protected function onFoalRewardUrl(result:Object) : void
      {
         var animal:Animal = null;
         var parentItem:FarmItem = null;
         var item:FarmItem = null;
         var iconUrl:String = null;
         var shareMessage:String = null;
         var dialog:GenericIconPopup = null;
         if(Boolean(result) && Boolean(result.foalRewardUrl))
         {
            animal = m_object as Animal;
            parentItem = Global.farmGameSettingsManager.getFarmItemByName(animal.getItem().name);
            this.m_foalRewardUrl = result.foalRewardUrl;
            item = Global.farmGameSettingsManager.getFarmItemByName(parentItem.foalItemName);
            iconUrl = item.getImageByName("icon");
            shareMessage = ZLocUtils.t("Dialogs","ShareMessage_" + parentItem.foalItemName);
            dialog = new GenericIconPopup(shareMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onShareFoalClose,iconUrl);
            dialog.setTrackerKey(parentItem.foalItemName + "_complete");
            dialog.setAcceptTextName("Share");
            UI.displayPopup(dialog);
         }
      }
      
      protected function onShareFoalClose(event:GenericPopupEvent) : void
      {
         var animal:Animal = null;
         var parentItem:FarmItem = null;
         var feedAction:String = null;
         var item:FarmItem = null;
         var iconUrl:String = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            animal = m_object as Animal;
            parentItem = Global.farmGameSettingsManager.getFarmItemByName(animal.getItem().name);
            feedAction = parentItem.foalItemName + "_ShareFeed";
            item = Global.farmGameSettingsManager.getFarmItemByName(parentItem.foalItemName);
            iconUrl = item.getImageByName("icon");
            bundleData = {
               "reward_link":this.m_foalRewardUrl,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_foalRewardUrl,
                  "src":iconUrl,
                  "actor":Global.player.snUser.firstName
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory(feedAction,bundleData,[],false,null);
         }
      }
   }
}

