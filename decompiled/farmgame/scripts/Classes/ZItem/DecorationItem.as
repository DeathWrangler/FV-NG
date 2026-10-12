package Classes.ZItem
{
   import Classes.LootableDecoration;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.CustomizeRing;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import GameMode.GMCreditsBuildingItemPlace;
   import GameMode.GMDecorationPlace;
   import GameMode.GMEquipmentPlace;
   import GameMode.GMHolidayPresentPlace;
   import GameMode.GMSetAltGraphic;
   import GameMode.GMStencilDecorationPlace;
   import Managers.AltGraphicUtility;
   import Managers.FarmGameSettingsManager;
   import Transactions.TBuyAltGraphicLicense;
   import Transactions.TBuyConsumables;
   import Transactions.TGiftCollections;
   import Transactions.TUseLootableConsumable;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   
   public class DecorationItem extends FarmItem
   {
      
      public function DecorationItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var canBuy:Boolean = false;
         var ring:FarmItem = null;
         var customizeRingPopup:CustomizeRing = null;
         var currency:String = null;
         if(subsubtype == "lightItems")
         {
            Global.world.addGameMode(new GMSetAltGraphic(AltGraphicUtility.getAltGraphicCreditKey(name)));
         }
         else if(subsubtype == "lightItemsUnlimited")
         {
            if(!Global.player.hasUnlimitedCredits(AltGraphicUtility.getAltGraphicCreditKey(name)))
            {
               canBuy = Global.player.tryBuy(null,false,this,0,name);
               if(canBuy)
               {
                  TransactionManager.addTransaction(new TBuyAltGraphicLicense(name));
                  Global.world.addGameMode(new GMSetAltGraphic(AltGraphicUtility.getAltGraphicCreditKey(name)));
               }
            }
            else
            {
               Global.world.addGameMode(new GMSetAltGraphic(AltGraphicUtility.getAltGraphicCreditKey(name)));
            }
         }
         else if(subType == "consumable")
         {
            TransactionManager.addTransaction(new TBuyConsumables(name,false));
         }
         else
         {
            switch(className)
            {
               case "HolidayPresent":
                  Global.world.addGameMode(new GMHolidayPresentPlace(name,false),false);
                  break;
               case "ValentinesPresent":
                  ring = Global.farmGameSettingsManager.getFarmItemByName(name);
                  customizeRingPopup = new CustomizeRing(ring,null);
                  customizeRingPopup.addEventListener(Event.CLOSE,UI.onCustomizeRingPopupClose);
                  UI.displayPopup(customizeRingPopup);
                  break;
               case "FeatureCreditItem":
                  Global.world.addGameMode(new GMCreditsBuildingItemPlace(name,false),false);
                  break;
               default:
                  currency = "";
                  if(extraData != null)
                  {
                     currency = extraData.hasOwnProperty("currency") ? extraData["currency"] : "";
                  }
                  Global.world.addGameMode(new GMDecorationPlace(name,false,0,true,currency));
            }
         }
         return true;
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         var itemName:String = null;
         var message:String = null;
         var lootableDecoClass:Class = null;
         var lootableDecoration:LootableDecoration = null;
         var isGift:Boolean = true;
         if(Boolean(extraData) && Boolean(extraData.isGift != null) && extraData.isGift == false)
         {
            isGift = false;
         }
         var shouldReOpenGift:Boolean = Boolean(extraData) && extraData.shouldReOpenGift != null && Boolean(extraData.shouldReOpenGift) && !isToolGenerated;
         itemName = name;
         if(Boolean(extraData) && extraData.realItemName != null)
         {
            itemName = extraData.realItemName;
         }
         var itemCount:int = 1;
         if(Boolean(extraData) && extraData["itemCount"] > 0)
         {
            itemCount = int(extraData["itemCount"]);
         }
         switch(className)
         {
            case "HolidayPresent":
               Global.world.addGameMode(new GMHolidayPresentPlace(itemName,isGift),false);
               break;
            case "Collection":
               if(Global.player.level < 10)
               {
                  message = ZLocUtils.t("Dialogs","CollectionsNotHighLevel",{"quantity":10});
                  UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
               }
               else
               {
                  TransactionManager.addTransaction(new TGiftCollections(this.code));
               }
               break;
            case "LootableConsumable":
               TransactionManager.addTransaction(new TUseLootableConsumable(itemName,true),true);
               break;
            case "MysteryGift":
            case "LootableDecoration":
            case "LootableDecorationMysteryItem":
            case "SocialPlumbingMysteryGift":
               if(className != "")
               {
                  lootableDecoClass = getDefinitionByName("Classes." + className) as Class;
               }
               else
               {
                  lootableDecoClass = getDefinitionByName("Classes.LootableDecoration") as Class;
               }
               lootableDecoration = new lootableDecoClass(itemName);
               lootableDecoration.giftBoxOpen();
               break;
            case "FeatureCreditItem":
               Global.world.addGameMode(new GMCreditsBuildingItemPlace(itemName,isGift,true,true,itemCount),false);
               break;
            case "AlternateGraphicPainter":
               Global.world.addGameMode(new GMSetAltGraphic(itemName));
               break;
            case "StencilDecoration":
               Global.world.addGameMode(new GMStencilDecorationPlace(itemName,isGift,buildingId,shouldReOpenGift));
               break;
            default:
               Global.world.addGameMode(new GMDecorationPlace(itemName,isGift,buildingId,shouldReOpenGift));
         }
      }
      
      public function onRemove(buildingId:int = 0, extraData:Object = null, itemName:String = "") : void
      {
         if(itemName == "")
         {
            itemName = name;
         }
         switch(type)
         {
            case "vehicle":
               Global.world.addGameMode(new GMEquipmentPlace(itemName,false,buildingId,extraData.numParts));
               break;
            default:
               Global.world.addGameMode(new GMDecorationPlace(itemName,false,buildingId));
         }
      }
      
      override protected function defaultPreview() : Boolean
      {
         return "ValentinesPresent" != className && "Collection" != className && "FeatureCreditItem" != className && subType != "lightItems" && !isGameToken;
      }
      
      public function get buffName() : String
      {
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource.hasProperty("buff"))
            {
               result = m_dataSource.getString("buff");
            }
         }
         else if(m_itemXML.buff)
         {
            result = m_itemXML.buff;
         }
         return result;
      }
      
      override public function get friendlyTitle() : String
      {
         var friendlyTitle:String = super.friendlyTitle;
         if((this.className == "DynamicMasterySign" || this.className == "RecipeMasterySign") && friendlyTitle == "")
         {
            friendlyTitle = ZLocUtils.tk_pk_asTitle("Items:" + this.className + "_friendlyName");
         }
         return friendlyTitle;
      }
   }
}

