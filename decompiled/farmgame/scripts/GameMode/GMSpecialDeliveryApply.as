package GameMode
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.FeatureBuilding;
   import Classes.LootableDecoration;
   import Classes.RewardCreditsBuilding;
   import Classes.SocialPlumbingMysteryGift;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Classes.WorldObject;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.ToasterManager;
   import Transactions.TGenericTransaction;
   import Transactions.TRefreshGifts;
   import Widgets.Windows.IconToasterWindow;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class GMSpecialDeliveryApply extends GMBuildingPart
   {
      
      private static const FIRST_TIME_SEEN_FLAG:String = "sdb_cursor";
      
      private static var m_whitelistedPartNames:Object = {};
      
      private var m_buildingToPartHash:Dictionary = new Dictionary(true);
      
      private var m_sdbItem:SocialPlumbingMysteryGift = null;
      
      private var m_buildingExpanding:Boolean = false;
      
      public function GMSpecialDeliveryApply(sdb:SocialPlumbingMysteryGift)
      {
         this.m_sdbItem = sdb;
         var acceptableBuildings:Array = this.getSDBAcceptableBuildings();
         super(sdb,acceptableBuildings,true,true);
      }
      
      private static function getWhitelistedPartNames(sdbItemName:String) : Array
      {
         var parts:Array = null;
         var partListString:String = null;
         var whitelistedParts:Array = null;
         var partName:String = null;
         var item:FarmItem = null;
         if(!m_whitelistedPartNames.hasOwnProperty(sdbItemName))
         {
            parts = [];
            partListString = Global.flashHotParams["BUILDING_PARTS_WHITELIST_" + sdbItemName.toUpperCase()];
            if(partListString == null)
            {
               partListString = Global.flashHotParams["BUILDING_PARTS_WHITELIST"];
            }
            if(partListString != null)
            {
               whitelistedParts = partListString.split(",");
               for each(partName in whitelistedParts)
               {
                  item = Global.farmGameSettingsManager.getFarmItemByName(partName);
                  if(item != null)
                  {
                     parts.push(partName);
                  }
                  else
                  {
                     StatsManager.count("sdbCursor","error","item_invalid",partName);
                  }
               }
            }
            m_whitelistedPartNames[sdbItemName] = parts;
         }
         return m_whitelistedPartNames[sdbItemName];
      }
      
      private function getSDBAcceptableBuildings() : Array
      {
         var part:BuildingPart = null;
         var partName:String = null;
         var buildingType:String = null;
         var buildingClass:Class = null;
         var buildings:Array = null;
         var building:StorageBuilding = null;
         var buildingIndex:int = 0;
         var result:Array = new Array();
         var whitelistedParts:Array = getWhitelistedPartNames(this.m_sdbItem.itemName);
         for each(partName in whitelistedParts)
         {
            part = new BuildingPart(partName);
            for each(buildingType in part.buildingTypes)
            {
               buildingClass = getDefinitionByName("Classes." + buildingType) as Class;
               buildings = Global.world.getObjectsByClass(buildingClass);
               for each(building in buildings)
               {
                  if(BuildingItemUseMediator.canAddToBuilding(building,part))
                  {
                     buildingIndex = result.indexOf(building);
                     if(buildingIndex == -1)
                     {
                        result.push(building);
                     }
                     if(!(building in this.m_buildingToPartHash))
                     {
                        this.m_buildingToPartHash[building] = new Array();
                     }
                     if(this.m_buildingToPartHash[building].indexOf(partName) == -1)
                     {
                        this.m_buildingToPartHash[building].push(partName);
                     }
                  }
               }
            }
         }
         return result;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var acceptableParts:Array = null;
         var acceptedPart:String = null;
         var acceptedCode:String = null;
         var partsOnHand:int = 0;
         var partsNeeded:int = 0;
         if(this.checkAndHandleNoSdbs() == true)
         {
            if(!m_dragging && Boolean(m_highlightedObject))
            {
               if(GlobalEngine.currentTime > m_lastClickTime + clickThrottleTime)
               {
                  if(m_highlightedObject is StorageBuilding)
                  {
                     if(m_highlightedObject in this.m_buildingToPartHash)
                     {
                        acceptableParts = this.m_buildingToPartHash[m_highlightedObject];
                        if(acceptableParts.length > 0)
                        {
                           if(m_highlightedObject is RewardCreditsBuilding)
                           {
                              this.prepareAndAddPart(0,1,acceptableParts[0],event);
                           }
                           else
                           {
                              for each(acceptedPart in acceptableParts)
                              {
                                 acceptedCode = Global.farmGameSettingsManager.getFarmItemCodeByName(acceptedPart);
                                 if(m_highlightedObject is FeatureBuilding)
                                 {
                                    partsOnHand = (m_highlightedObject as FeatureBuilding).getExpansionPartCount(acceptedCode);
                                    partsNeeded = (m_highlightedObject as FeatureBuilding).getExpansionPartLimit(acceptedCode);
                                 }
                                 else
                                 {
                                    partsOnHand = (m_highlightedObject as StorageBuilding).getCurrentLevelConstructionItemCount(acceptedCode);
                                    partsNeeded = (m_highlightedObject as StorageBuilding).getTotalPartsNeededForItem(acceptedCode);
                                 }
                                 if(this.prepareAndAddPart(partsOnHand,partsNeeded,acceptedPart,event))
                                 {
                                    break;
                                 }
                              }
                           }
                        }
                        else
                        {
                           delete this.m_buildingToPartHash[m_highlightedObject];
                           m_acceptableBuildings.splice(m_acceptableBuildings.indexOf(m_highlightedObject),1);
                        }
                     }
                     else
                     {
                        m_acceptableBuildings.splice(m_acceptableBuildings.indexOf(m_highlightedObject),1);
                     }
                  }
                  if(m_acceptableBuildings.length == 0)
                  {
                     ToasterManager.getInstance().add(new IconToasterWindow(this.m_sdbItem.getItem().getImageByName("icon"),ZLocUtils.t("Dialogs","sdbCursorNoMoreBuildings")));
                     exit();
                  }
                  else
                  {
                     this.checkAndHandleNoSdbs();
                  }
               }
            }
         }
      }
      
      private function checkAndHandleNoSdbs() : Boolean
      {
         var result:Boolean = true;
         var sdbFarmItem:FarmItem = this.m_sdbItem.getItem();
         if(!Global.player.hasGiftItem(sdbFarmItem.code))
         {
            ToasterManager.getInstance().add(new IconToasterWindow(sdbFarmItem.getImageByName("icon"),ZLocUtils.t("Dialogs","sdbCursorNoMoreSdbs")));
            exit();
            result = false;
         }
         return result;
      }
      
      private function prepareAndAddPart(partsOnHand:int, totalPartsNeeded:int, partToAddName:String, event:MouseEvent) : Boolean
      {
         var numSdbs:int = 0;
         var firstApply:Boolean = false;
         var spliceBuilding:Boolean = false;
         var acceptableParts:Array = null;
         var whitelistedParts:Array = null;
         var partsArray:Array = null;
         var partName:String = null;
         var result:Boolean = false;
         var part:BuildingPart = new BuildingPart(partToAddName);
         var storage:StorageBuilding = m_highlightedObject as StorageBuilding;
         var canAddToContainees:Boolean = false;
         if(storage != null)
         {
            canAddToContainees = storage.isValidContaineePart(part) && storage.count > 0;
         }
         if(partsOnHand < totalPartsNeeded || canAddToContainees)
         {
            Global.player.addGift(partToAddName);
            numSdbs = Global.player.getGiftCountForItem(this.m_sdbItem.itemName);
            firstApply = false;
            if(!Global.player.getSeenSessionFlag("firstSdbApply"))
            {
               firstApply = true;
               Global.player.setSeenSessionFlag("firstSdbApply",true);
            }
            Global.player.removeGift(null,this.m_sdbItem.itemName);
            m_buildingPart = new LootableDecoration(partToAddName);
            spliceBuilding = false;
            TransactionManager.addTransaction(new TGenericTransaction("SpecialDeliveryService","getPartForBuilding",null,[this.m_sdbItem.itemName,partToAddName,numSdbs,firstApply]));
            super.handleClick(event);
            if(partsOnHand + 1 >= totalPartsNeeded)
            {
               acceptableParts = this.m_buildingToPartHash[m_highlightedObject];
               if(acceptableParts)
               {
                  if(!canAddToContainees)
                  {
                     acceptableParts.splice(acceptableParts.indexOf(partToAddName),1);
                  }
                  if(acceptableParts.length == 0 && !canAddToContainees || canAddToContainees && storage != null && storage.count == 0)
                  {
                     delete this.m_buildingToPartHash[m_highlightedObject];
                     spliceBuilding = true;
                  }
               }
            }
            if(spliceBuilding && !this.m_buildingExpanding)
            {
               m_acceptableBuildings.splice(m_acceptableBuildings.indexOf(m_highlightedObject),1);
            }
            else if(this.m_buildingExpanding)
            {
               this.m_buildingExpanding = false;
               whitelistedParts = getWhitelistedPartNames(this.m_sdbItem.itemName);
               partsArray = new Array();
               for each(partName in whitelistedParts)
               {
                  part = new BuildingPart(partName);
                  if(BuildingItemUseMediator.canAddToBuilding(m_highlightedObject as StorageBuilding,part))
                  {
                     partsArray.push(partName);
                  }
               }
               this.m_buildingToPartHash[m_highlightedObject] = partsArray;
            }
            result = true;
         }
         return result;
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         return m_acceptableBuildings.indexOf(object) != -1;
      }
      
      override protected function refresh() : void
      {
         if(TRefreshGifts.isRefreshing())
         {
            this.exit();
         }
         else
         {
            m_buildingPart = this.m_sdbItem;
            super.refresh();
         }
      }
      
      override public function get buildingPart() : LootableDecoration
      {
         var acceptableParts:Array = null;
         var result:LootableDecoration = super.buildingPart;
         if(m_highlightedObject is StorageBuilding)
         {
            if(m_highlightedObject in this.m_buildingToPartHash)
            {
               acceptableParts = this.m_buildingToPartHash[m_highlightedObject];
               if(acceptableParts.length > 0)
               {
                  result = new LootableDecoration(acceptableParts[0]);
               }
            }
         }
         return result;
      }
      
      public function suppressBuildingSpliceThenRefresh() : void
      {
         this.m_buildingExpanding = true;
      }
      
      override protected function showFirstTimePopup() : void
      {
         var item:FarmItem = null;
         if(!Global.player.getSeenFlag(FIRST_TIME_SEEN_FLAG))
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(m_buildingPart.itemName);
            if(item != null)
            {
               ToasterManager.getInstance().add(new IconToasterWindow(item.getImageByName("icon"),ZLocUtils.t("Dialogs","sdbCursorFirstUseMessage")));
            }
            Global.player.setSeenFlag(FIRST_TIME_SEEN_FLAG);
         }
      }
      
      override protected function getAllFullToasterText() : String
      {
         return ZLocUtils.t("Dialogs","sdbCursorNoBuildings");
      }
   }
}

