package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.ImageLoader;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.GenericExpandSlotFrame;
   import Widgets.Windows.Breeding.BaseContentsWindow;
   import com.adobe.utils.ArrayUtil;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Dictionary;
   
   public class StorageContentsWindow extends BaseContentsWindow
   {
      
      private static const DISPLAY_SETTINGS_DIALOG_NAME:String = "content";
      
      public static const VIEW_FEATURE:int = 0;
      
      public static const VIEW_EXPAND:int = 1;
      
      protected static var m_state:int = 0;
      
      private var m_title:ZwTextField = null;
      
      protected var m_capacity_tf:ZwTextField = null;
      
      protected var m_current_tf:ZwTextField = null;
      
      private var m_howDoesThisWork:FarmAnimatedTextButton = null;
      
      protected var m_featuredFrame:ZwFrame = null;
      
      protected var m_content_mc:FarmSlotContainerFrame = null;
      
      protected var m_expand_mc:GenericExpandSlotFrame;
      
      protected var m_contentTab_bt:FarmAnimatedTextButton = null;
      
      protected var m_expandTab_bt:FarmAnimatedTextButton = null;
      
      protected var m_items:Dictionary = new Dictionary();
      
      protected var m_storageItems:Array = new Array();
      
      protected var m_contents:Array = new Array();
      
      protected var m_toggleManager:ZwToggleManager;
      
      protected var m_contentToggle:ZwVisibilityToggle;
      
      protected var m_expandToggle:ZwVisibilityToggle;
      
      protected var m_slotBGIcon:DisplayObject;
      
      public function StorageContentsWindow(building:FeatureBuilding)
      {
         m_building = building;
         FarmStatsManager.count("dialog",m_building.getItemName(),"view");
         var dialogConfig:Object = m_building.getItem().getDialogConfig("storage");
         if(dialogConfig == null)
         {
            dialogConfig = Global.farmGameSettingsManager.getBuildingDialogConfig(m_building.getItemName());
         }
         if(dialogConfig != null && dialogConfig.path != "")
         {
            super(dialogConfig.path);
         }
         this.m_items = m_building.contents;
         this.m_contents = this.loadContents();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.initFeatureWidgets();
      }
      
      override protected function release() : void
      {
         super.release();
         m_building = null;
         this.m_title = null;
         this.m_capacity_tf = null;
         this.m_current_tf = null;
         this.m_howDoesThisWork = null;
         this.m_content_mc = null;
         this.m_expand_mc = null;
         this.m_contentTab_bt = null;
         this.m_expandTab_bt = null;
         this.m_toggleManager = null;
         this.m_contentToggle = null;
         this.m_expandToggle = null;
         m_state = StorageContentsWindow.VIEW_FEATURE;
      }
      
      protected function getFarmSlotContainerFrame() : FarmSlotContainerFrame
      {
         return null;
      }
      
      protected function updateCurrent() : void
      {
         if(this.m_current_tf != null)
         {
            this.m_current_tf.text = ZLocUtils.t("Dialogs","Current",{"quantity":m_building.count});
         }
      }
      
      protected function initFeatureWidgets() : void
      {
         var buttonBGPath:String = null;
         if(m_window.title_tf)
         {
            this.m_title = addWidget(new ZwTextField(m_window.title_tf,getLocalizedString("_Title"))) as ZwTextField;
         }
         if(m_window.capacity_tf)
         {
            this.m_capacity_tf = addWidget(new ZwTextField(m_window.capacity_tf,ZLocUtils.t("Dialogs","Capacity",{"quantity":m_building.capacity}))) as ZwTextField;
            m_window.capacity_tf.wordWrap = false;
            m_window.capacity_tf.autoSize = TextFieldAutoSize.LEFT;
         }
         if(m_window.current_tf)
         {
            this.m_current_tf = addWidget(new ZwTextField(m_window.current_tf,ZLocUtils.t("Dialogs","Current",{"quantity":m_building.count}))) as ZwTextField;
            m_window.current_tf.wordWrap = false;
            m_window.current_tf.autoSize = TextFieldAutoSize.LEFT;
         }
         this.m_howDoesThisWork = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkClick)) as FarmAnimatedTextButton;
         this.m_content_mc = this.getFarmSlotContainerFrame();
         addWidget(this.m_content_mc);
         var expansionItems:Array = m_building.expand.getExpandSlotData();
         if(m_window.hasOwnProperty("expand_mc") && Boolean(expansionItems))
         {
            this.m_expand_mc = new GenericExpandSlotFrame(m_window.expand_mc,expansionItems,this,m_building,m_building.expand);
            addWidget(this.m_expand_mc,false);
            if(this.m_contentTab_bt == null)
            {
               this.m_contentTab_bt = new FarmAnimatedTextButton(m_window.contentsTab_mc,ZLocUtils.t("Dialogs","Contents"),this.onShowContents);
            }
            addWidget(this.m_contentTab_bt);
            if(m_window.strings_mc)
            {
               addWidget(new ZwBaseWidget(m_window.strings_mc));
            }
            this.m_expandTab_bt = new FarmAnimatedTextButton(m_window.expandTab_mc,ZLocUtils.t("Dialogs","expand_farm_submenu"));
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.expandTab_mc.generic_tf);
            }
            addWidget(this.m_expandTab_bt);
            if(m_window.expandTab_mc.hasOwnProperty("mc_Button"))
            {
               buttonBGPath = Global.worldSettingsManager.getSlotBGImagePath("Button100");
               if(buttonBGPath)
               {
                  ImageLoader.getInstance(Global.getAssetURL(buttonBGPath)).getContent(this.onSlotUrlLoaded);
                  if(this.m_slotBGIcon)
                  {
                     m_window.expandTab_mc["mc_Button"].addChild(this.m_slotBGIcon);
                     m_window.expandTab_mc["mc_Button"].visible = true;
                  }
               }
            }
         }
         if(this.m_expand_mc)
         {
            this.m_toggleManager = new ZwToggleManager();
            this.m_contentToggle = new ZwVisibilityToggle(this.m_contentTab_bt,this.m_content_mc);
            this.m_expandToggle = new ZwVisibilityToggle(this.m_expandTab_bt,this.m_expand_mc);
            if(StorageContentsWindow.m_state == StorageContentsWindow.VIEW_EXPAND)
            {
               this.m_toggleManager.addToggle(this.m_expandToggle,true);
               this.m_toggleManager.addToggle(this.m_contentToggle);
               this.showFirstExpandDialog();
            }
            else
            {
               this.m_toggleManager.addToggle(this.m_expandToggle);
               this.m_toggleManager.addToggle(this.m_contentToggle,true);
            }
         }
         else
         {
            this.m_content_mc.visible = true;
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      protected function showFirstExpandDialog() : void
      {
         var message:String = null;
         var dialog:GenericIconPopup = null;
         var seenFlag:String = "expand" + m_building.bldgName + m_building.storageLevel;
         if(!Global.player.getSeenFlag(seenFlag) && m_building.expand.hasNextExpansion())
         {
            message = ZLocUtils.t("Dialogs","AnimalBreedingGenericExpand_message",{"building":ZLocUtils.tk_pk(m_building.getItemFriendlyName())});
            dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onShareExpansion,m_building.getItem().icon);
            UI.displayPopup(dialog,false);
            Global.player.setSeenFlag(seenFlag);
            FarmStatsManager.count(m_building.bldgName,m_building.bldgName + "_expansion","expansion_started","time_" + m_building.storageLevel);
         }
      }
      
      protected function onShowContents(event:Event) : void
      {
         StorageContentsWindow.m_state = StorageContentsWindow.VIEW_FEATURE;
      }
      
      protected function onClickMarket(event:MouseEvent) : void
      {
         var createWindow:Function;
         var runtimeVariableName:String;
         var building:FeatureBuilding = null;
         FarmStatsManager.count("dialog",m_building.getItemName(),"featured_buy");
         m_skipCloseStat = true;
         building = m_building;
         createWindow = function(purchased:Boolean = false):void
         {
            if(!purchased)
            {
               building.displayStorageDialog();
            }
         };
         runtimeVariableName = m_building.bldgName.toUpperCase();
         this.openMiniMarket(runtimeVariableName,createWindow);
         this.close();
      }
      
      protected function openMiniMarket(runtimeVariableName:String, createWindow:Function) : void
      {
         UI.displayMiniMarketDialog([Global.flashHotParams[runtimeVariableName]],UI.MARKET_CONTEXT_UNKNOWN,"seed",createWindow,true);
      }
      
      protected function onShareExpansion(event:GenericPopupEvent) : void
      {
         var giftItemNames:Array = null;
         var selectedGifts:String = null;
         var numParts:int = 0;
         var hrefUrl:String = null;
         var bundleData:Object = null;
         var idx:int = 0;
         var itemName:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            giftItemNames = m_building.getPartNames();
            selectedGifts = "&selectedGift=";
            numParts = int(giftItemNames.length);
            if(Boolean(giftItemNames) && numParts > 0)
            {
               for(idx = 0; idx < numParts; idx++)
               {
                  itemName = giftItemNames[idx];
                  selectedGifts += itemName;
                  if(idx + 1 < numParts)
                  {
                     selectedGifts += ",";
                  }
               }
            }
            hrefUrl = "gifts.php?giftRecipient=" + Global.player.snUser.uid + selectedGifts;
            bundleData = {
               "images":[{
                  "href":"{SN_APP_URL}" + hrefUrl,
                  "src":m_building.getItem().icon
               }],
               "reward_link":hrefUrl,
               "building":m_building.getItemFriendlyName()
            };
            GlobalEngine.socialNetwork.publishFeedStory(m_building.bldgName + "_ExpandAsk",bundleData,[],false);
         }
      }
      
      protected function sortItems(result:Array) : void
      {
      }
      
      protected function loadContents() : Array
      {
         var itemCode:String = null;
         var metadataList:Array = null;
         var resultItem:Object = null;
         var extraDataKey:String = null;
         this.m_storageItems = Global.storageSettings.getStorageItems(m_building.getItem().storageClass);
         var tmpItemDisplaySettings:Object = Global.farmGameSettingsManager.getDialogDisplaySettings(m_building.getItem().name,DISPLAY_SETTINGS_DIALOG_NAME);
         var farmItem:FarmItem = null;
         var result:Array = new Array();
         var ugc:Array = new Array();
         var nonStoredItems:Array = new Array();
         for(itemCode in m_building.contents)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(this.m_items[itemCode] != 0)
            {
               metadataList = m_building.getStorageMetaDataForCode(itemCode);
               if(metadataList.length)
               {
                  ugc = this.generateMetadataArrContents(metadataList,ugc,itemCode);
               }
               else
               {
                  result.push({
                     "code":itemCode,
                     "quantity":this.m_items[itemCode],
                     "itemName":farmItem.name,
                     "name":farmItem.friendlyTitle,
                     "world":farmItem.marketCardName,
                     "farmItem":farmItem
                  });
               }
            }
         }
         ugc.sortOn(["name"],[Array.CASEINSENSITIVE]);
         if(Global.flashHotParams["SORT_STORAGE_BY_WORLD"])
         {
            result.sort(this.sortByWorld);
         }
         else
         {
            result.sortOn(["name"],[Array.CASEINSENSITIVE]);
         }
         result = ArrayUtil.createUniqueCopy(ugc.concat(result));
         for(var key:int = 0; key < this.m_storageItems.length; key++)
         {
            farmItem = this.m_storageItems[key];
            if(farmItem != null && (!(farmItem is BuildingItem) || (farmItem as BuildingItem).className != "BuildingPart"))
            {
               if((this.m_items.hasOwnProperty(farmItem.code) == false || this.m_items[farmItem.code] == 0) && farmItem.canShow())
               {
                  nonStoredItems.push({
                     "code":farmItem.code,
                     "quantity":0,
                     "itemName":farmItem.name,
                     "name":farmItem.friendlyTitle,
                     "market":farmItem.canPurchase,
                     "world":farmItem.marketCardName,
                     "farmItem":farmItem
                  });
               }
            }
         }
         if(Global.flashHotParams["SORT_STORAGE_BY_WORLD"])
         {
            nonStoredItems.sort(this.sortByWorld);
         }
         else
         {
            nonStoredItems.sortOn(["market","name"],[Array.NUMERIC | Array.DESCENDING,Array.CASEINSENSITIVE]);
         }
         result = ArrayUtil.createUniqueCopy(result.concat(nonStoredItems));
         this.sortItems(result);
         if(tmpItemDisplaySettings != null)
         {
            for each(resultItem in result)
            {
               if(Boolean(tmpItemDisplaySettings[resultItem.itemName]) && Boolean(tmpItemDisplaySettings[resultItem.itemName].hasOwnProperty("image")))
               {
                  for(extraDataKey in tmpItemDisplaySettings[resultItem.itemName].image)
                  {
                     resultItem[extraDataKey] = tmpItemDisplaySettings[resultItem.itemName].image[extraDataKey];
                  }
               }
            }
         }
         return result;
      }
      
      protected function sortByWorld(object1:Object, object2:Object) : int
      {
         var result:int = 0;
         var currentWorld:String = Global.worldManager.currentWorldUniqueMarketCard;
         if(object1.world == currentWorld && object2.world == currentWorld || object1.world != currentWorld && object2.world != currentWorld)
         {
            if(Boolean(object1.market) && Boolean(object2.market) || !object1.market && !object2.market)
            {
               if(object1.name > object2.name)
               {
                  result = 1;
               }
               else
               {
                  result = -1;
               }
            }
            else if(object1.market)
            {
               result = -1;
            }
            else
            {
               result = 1;
            }
         }
         else if(object1.world == currentWorld)
         {
            result = -1;
         }
         else
         {
            result = 1;
         }
         return result;
      }
      
      protected function generateMetadataArrContents(metadataList:Array, contents:Array, itemCode:String) : Array
      {
         var meta:Object = null;
         var dataArray:Array = null;
         var quantity:int = 0;
         var friendlyName:String = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         for each(meta in metadataList)
         {
            dataArray = meta.data as Array;
            quantity = 1;
            friendlyName = null;
            if(dataArray)
            {
               quantity = int(dataArray.length);
               friendlyName = farmItem.getInstanceName(dataArray[0]);
            }
            else
            {
               friendlyName = farmItem.getInstanceName(meta.data);
            }
            contents.push({
               "code":itemCode,
               "quantity":quantity,
               "itemName":farmItem.name,
               "name":farmItem.friendlyTitle,
               "metadataHash":meta.key,
               "displayName":friendlyName,
               "unique":true
            });
         }
         return contents;
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         FarmStatsManager.count("dialog",m_building.getItemName(),"what_is_this");
         var prefixUrl:String = m_building.getItem().prefixUrl;
         TutorialUI.displayBuildingTutorialWindow(m_building,prefixUrl,false,null);
      }
      
      public function setExpansionViewActive() : void
      {
         StorageContentsWindow.m_state = StorageContentsWindow.VIEW_EXPAND;
      }
      
      override public function refreshWindow() : void
      {
         if(this.m_expand_mc)
         {
            this.m_expand_mc.refresh();
         }
         super.refreshWindow();
      }
      
      public function showContentsView() : void
      {
         StorageContentsWindow.m_state = StorageContentsWindow.VIEW_FEATURE;
         this.m_toggleManager.performToggle(this.m_contentToggle);
      }
      
      public function showExpandView() : void
      {
         StorageContentsWindow.m_state = StorageContentsWindow.VIEW_EXPAND;
         this.m_toggleManager.performToggle(this.m_expandToggle);
      }
   }
}

