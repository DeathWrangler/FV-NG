package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.MathUtil;
   import Managers.FarmStatsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericExpandSlotFrame;
   import Widgets.Frames.ItemCollectionSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class ItemCollectionWindow extends FarmWindow
   {
      
      public static const VIEW_FEATURE:int = 0;
      
      public static const VIEW_EXPAND:int = 1;
      
      private var m_building:FeatureBuilding = null;
      
      private var m_title:ZwTextField = null;
      
      private var m_capacity_tf:ZwTextField = null;
      
      private var m_current_tf:ZwTextField = null;
      
      private var m_howDoesThisWork:FarmAnimatedTextButton = null;
      
      private var m_itemCollection_mc:ItemCollectionSlotFrame = null;
      
      private var m_expand_mc:GenericExpandSlotFrame;
      
      private var m_expandMenu_tf:ZwTextField;
      
      private var m_state:int = 0;
      
      private const SLOT_H_60:String = "mc_Slot_H_0";
      
      private var m_itemCollectionTab_bt:FarmAnimatedTextButton = null;
      
      private var m_expandTab_bt:FarmAnimatedTextButton = null;
      
      protected var m_contents:Dictionary = new Dictionary();
      
      private var m_skipCloseStat:Boolean = false;
      
      private var m_dialogConfig:Object = this.m_building.getItem().getDialogConfig("storage");
      
      private var m_featuredItem:FarmItem = null;
      
      private var m_featuredItemFrame:ZwFrame = null;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_slotBGIcon:DisplayObject;
      
      private var m_slotH60Icon:DisplayObject = null;
      
      public function ItemCollectionWindow(building:FeatureBuilding)
      {
         this.m_building = building;
         if(this.m_dialogConfig == null)
         {
            this.m_dialogConfig = Global.farmGameSettingsManager.getBuildingDialogConfig(this.m_building.getItemName());
         }
         if(this.m_dialogConfig != null && this.m_dialogConfig.path != "")
         {
            super(this.m_dialogConfig.path);
         }
         this.m_contents = this.m_building.contents;
         if(this.m_dialogConfig != null && this.m_dialogConfig.bgPath != "")
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogConfig.bgPath));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         FarmStatsManager.count("dialog",this.m_building.getItemName(),"view");
         if(Global.worldManager.isVisiting())
         {
            FarmStatsManager.count("neighbor_visit",this.m_building.getItemName(),"look_inside","view");
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.initMainWindow();
         this.initSlotFrame();
         if(!Global.worldManager.isVisiting())
         {
            this.initExpansionFrame();
            this.initFeaturedItemFrame();
         }
         if(this.m_expand_mc)
         {
            if(this.m_state == VIEW_EXPAND)
            {
               this.m_itemCollection_mc.visible = false;
               this.m_expand_mc.visible = true;
            }
            else if(this.m_state == VIEW_FEATURE)
            {
               this.m_itemCollection_mc.visible = true;
               this.m_expand_mc.visible = false;
            }
         }
         if(m_window.hasOwnProperty("mc_AnimalFrame_big_noBG") && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_AnimalFrame_big_noBG) + 1);
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
         }
      }
      
      private function initMainWindow() : void
      {
         var buttonBGPath:String = null;
         this.m_title = addWidget(new ZwTextField(m_window.title_tf,this.getLocalizedString("_Title"))) as ZwTextField;
         this.m_howDoesThisWork = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkClick)) as FarmAnimatedTextButton;
         if(!Global.worldManager.isVisiting())
         {
            this.m_capacity_tf = addWidget(new ZwTextField(m_window.capacity_tf,ZLocUtils.t("Dialogs","Capacity",{"quantity":this.m_building.capacity}))) as ZwTextField;
            this.m_current_tf = addWidget(new ZwTextField(m_window.current_tf,ZLocUtils.t("Dialogs","Current",{"quantity":this.m_building.count}))) as ZwTextField;
            buttonBGPath = Global.worldSettingsManager.getSlotBGImagePath("Button100");
            this.m_itemCollectionTab_bt = new FarmAnimatedTextButton(m_window.itemcollectionTab_mc,this.getLocalizedString("_ItemCollectionTab"),this.showItemCollection);
            if(m_window.itemcollectionTab_mc.hasOwnProperty("mc_Button"))
            {
               if(buttonBGPath)
               {
                  ImageLoader.getInstance(Global.getAssetURL(buttonBGPath)).getContent(this.onSlotUrlLoaded);
                  if(this.m_slotBGIcon)
                  {
                     m_window.itemcollectionTab_mc["mc_Button"].addChild(this.m_slotBGIcon);
                     m_window.itemcollectionTab_mc["mc_Button"].visible = true;
                  }
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.itemcollectionTab_mc.generic_tf);
               }
            }
            addWidget(this.m_itemCollectionTab_bt);
            if(m_window.expandTab_mc)
            {
               this.m_expandTab_bt = new FarmAnimatedTextButton(m_window.expandTab_mc,ZLocUtils.t("Dialogs","expand_farm_submenu"),this.showExpansion);
               if(m_window.expandTab_mc.hasOwnProperty("mc_Button"))
               {
                  if(buttonBGPath)
                  {
                     this.m_slotBGIcon = null;
                     ImageLoader.getInstance(Global.getAssetURL(buttonBGPath)).getContent(this.onSlotUrlLoaded);
                     if(this.m_slotBGIcon)
                     {
                        m_window.expandTab_mc["mc_Button"].addChild(this.m_slotBGIcon);
                        m_window.expandTab_mc["mc_Button"].visible = true;
                     }
                  }
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.expandTab_mc.generic_tf);
               }
               addWidget(this.m_expandTab_bt,false);
               if(m_window.strings_mc)
               {
                  addWidget(new ZwBaseWidget(m_window.strings_mc));
               }
            }
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      private function initSlotFrame() : void
      {
         var contents:Array = this.buildContents();
         this.m_itemCollection_mc = new ItemCollectionSlotFrame(m_window.itemcollection_mc,contents,this.m_building.bldgName);
         addWidget(this.m_itemCollection_mc);
      }
      
      private function initExpansionFrame() : void
      {
         var expansionItems:Array = this.m_building.expand.getExpandSlotData();
         if(m_window.hasOwnProperty("expand_mc") && Boolean(expansionItems))
         {
            this.m_expand_mc = new GenericExpandSlotFrame(m_window.expand_mc,expansionItems,this,this.m_building,this.m_building.expand);
            addWidget(this.m_expand_mc,false);
            if(m_window.generic_tf)
            {
               this.m_expandMenu_tf = new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs",this.m_building.bldgName + "_ExpandText"));
               addWidget(this.m_expandMenu_tf);
               this.m_expandMenu_tf.visible = false;
            }
            this.m_expandTab_bt.visible = true;
         }
      }
      
      private function initFeaturedItemFrame() : void
      {
         var slotH60Path:String = null;
         var farmIcon:FarmIcon = null;
         if(Boolean(m_window.featured_mc) && Boolean(this.m_featuredItem))
         {
            this.m_featuredItemFrame = addWidget(new ZwFrame(m_window.featured_mc)) as ZwFrame;
            slotH60Path = Global.worldSettingsManager.getSlotBGImagePath("H60");
            if(Boolean(slotH60Path) && Boolean(m_window.featured_mc.hasOwnProperty(this.SLOT_H_60)))
            {
               ImageLoader.getInstance(Global.getAssetURL(slotH60Path)).getContent(this.onHorizontalSlotURLLoaded);
               if(this.m_slotH60Icon)
               {
                  m_window.featured_mc[this.SLOT_H_60].addChildAt(this.m_slotH60Icon,1);
                  m_window.featured_mc[this.SLOT_H_60].visible = true;
               }
            }
            this.m_featuredItemFrame.addWidget(new ZwTextField(m_window.featured_mc.featuredTitle_tf,ZLocUtils.t("Dialogs",this.m_building.bldgName + "_Dialog_FeaturedItemTitle")));
            this.m_featuredItemFrame.addWidget(new ZwTextField(m_window.featured_mc.cost_tf,this.m_featuredItem.cash.toString()));
            this.m_featuredItemFrame.addWidget(new ZwTextField(m_window.featured_mc.featuredItem_tf,this.m_featuredItem.friendlyTitle));
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.featured_mc.cost_tf);
               TemplateUIUtility.applyExpansionGlowFilter(m_window.featured_mc.featuredItem_tf);
            }
            farmIcon = new FarmIcon(m_window.featured_mc.icon_mc,this.m_featuredItem.iconUrl);
            farmIcon.setIconSize(100,100);
            this.m_featuredItemFrame.addWidget(farmIcon,true);
            this.m_featuredItemFrame.addWidget(new FarmAnimatedTextButton(m_window.featured_mc.buy_bt,ZLocUtils.t("Dialogs","BuyParts"),this.generateMarketCallback(this.m_featuredItem.code)));
         }
      }
      
      private function onHorizontalSlotURLLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotH60Icon = dispObj;
      }
      
      protected function buildContents() : Array
      {
         var storableItems:Array = null;
         var itemCode:String = null;
         var key:int = 0;
         var content:Object = null;
         var result:Array = new Array();
         var farmItem:FarmItem = null;
         var nonStoredItemsMarket:Array = new Array();
         var nonStoredItemsNoMarket:Array = new Array();
         storableItems = Global.storageSettings.getStorageItems(this.m_building.getItem().storageClass,true);
         storableItems = storableItems.concat(Global.storageSettings.getStorageItemsByClass(this.m_building.getItem().storageClass));
         if(this.m_dialogConfig != null)
         {
            if(this.m_dialogConfig.showOwned)
            {
               for(itemCode in this.m_building.contents)
               {
                  if(this.m_contents[itemCode] != 0)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                     result.push({
                        "code":itemCode,
                        "quantity":this.m_contents[itemCode],
                        "name":farmItem.friendlyTitle,
                        "previewItemName":farmItem.name,
                        "callbacks":this.generateCallbacks(farmItem)
                     });
                  }
               }
               result.sortOn(["name"],[Array.CASEINSENSITIVE]);
            }
            if(Boolean(this.m_dialogConfig.showUnownedMarket) || Boolean(this.m_dialogConfig.showUnownedNoMarket))
            {
               for(key = 0; key < storableItems.length; key++)
               {
                  farmItem = storableItems[key] as FarmItem;
                  if(Boolean(farmItem) && (Boolean(this.m_contents.hasOwnProperty(farmItem.code) == false || this.m_contents[farmItem.code] == 0)) && farmItem.canShow())
                  {
                     content = {
                        "code":farmItem.code,
                        "quantity":0,
                        "name":farmItem.friendlyTitle,
                        "previewItemName":farmItem.name,
                        "callbacks":this.generateCallbacks(farmItem)
                     };
                     if(farmItem.canPurchase && Boolean(this.m_dialogConfig.showUnownedMarket))
                     {
                        nonStoredItemsMarket.push(content);
                     }
                     else if(!farmItem.canPurchase && Boolean(this.m_dialogConfig.showUnownedNoMarket))
                     {
                        nonStoredItemsNoMarket.push(content);
                     }
                  }
               }
               nonStoredItemsMarket.sortOn(["name"],[Array.CASEINSENSITIVE]);
               nonStoredItemsNoMarket.sortOn(["name"],[Array.CASEINSENSITIVE]);
               this.setFeaturedItem(nonStoredItemsMarket);
            }
            result = result.concat(nonStoredItemsMarket);
            result = result.concat(nonStoredItemsNoMarket);
         }
         return result;
      }
      
      private function setFeaturedItem(marketItems:Array) : void
      {
         var obj:Object = null;
         var cashMarketItems:Array = [];
         var farmItem:FarmItem = null;
         for each(obj in marketItems)
         {
            if(obj.hasOwnProperty("code"))
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(obj["code"]);
               if(farmItem.buyableWithCash())
               {
                  cashMarketItems.push(farmItem);
               }
            }
         }
         if(cashMarketItems.length > 0)
         {
            this.m_featuredItem = MathUtil.randomElement(cashMarketItems);
         }
      }
      
      private function showItemCollection(event:Event) : void
      {
         if(this.m_expand_mc)
         {
            this.m_itemCollection_mc.visible = true;
            this.m_expand_mc.visible = false;
            this.m_state = VIEW_FEATURE;
            if(this.m_expandMenu_tf)
            {
               this.m_expandMenu_tf.visible = false;
            }
         }
      }
      
      private function showExpansion(event:Event) : void
      {
         if(this.m_expand_mc)
         {
            this.m_itemCollection_mc.visible = false;
            this.m_expand_mc.visible = true;
            this.m_state = VIEW_EXPAND;
            if(this.m_expandMenu_tf)
            {
               this.m_expandMenu_tf.visible = true;
            }
         }
      }
      
      public function setExpansionViewActive() : void
      {
         this.m_state = VIEW_EXPAND;
      }
      
      private function getLocalizedString(keySuffix:String, params:Object = null) : String
      {
         var localizationKey:String = this.m_building.bldgName + keySuffix;
         if(!ZLocUtils.hasString("Dialogs",localizationKey))
         {
            localizationKey = "ItemCollection" + keySuffix;
            if(!params)
            {
               params = {};
            }
            params.itemName = this.m_building.getFarmItem().friendlyTitle;
         }
         return ZLocUtils.t("Dialogs",localizationKey,params);
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         FarmStatsManager.count("dialog",this.m_building.getItemName(),"what_is_this","open");
         var prefixUrl:String = this.m_building.getItem().prefixUrl;
         TutorialUI.displayBuildingTutorialWindow(this.m_building,prefixUrl,false,this.howDoesThisWorkCloseCallback);
      }
      
      private function howDoesThisWorkCloseCallback() : void
      {
         FarmStatsManager.count("dialog",this.m_building.getItemName(),"what_is_this","close");
      }
      
      private function generateCallbacks(farmItem:FarmItem) : Object
      {
         var result:Object = null;
         var removeFunc:Function = null;
         var marketFunc:Function = null;
         if(Boolean(!Global.worldManager.isVisiting()) && Boolean(this.m_contents[farmItem.code]) && this.m_contents[farmItem.code] > 0)
         {
            removeFunc = this.generateRemoveItemCallback(farmItem.code);
         }
         if(!Global.worldManager.isVisiting() && farmItem.buyable || Global.worldManager.isVisiting() && farmItem.buyableFromNeighbor)
         {
            marketFunc = this.generateMarketCallback(farmItem.code);
         }
         return {
            "remove":removeFunc,
            "market":marketFunc
         };
      }
      
      protected function generateRemoveItemCallback(itemCode:String) : Function
      {
         return function(event:Event):void
         {
            var extraData:* = {
               "isGift":false,
               "repopGift":false
            };
            var farmItem:* = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            farmItem.onUse(m_building.getId(),extraData);
            FarmStatsManager.count("dialog",m_building.getItemName(),"remove",farmItem.name);
            m_skipCloseStat = true;
            close();
         };
      }
      
      protected function generateMarketCallback(itemCode:String) : Function
      {
         return function(event:Event):void
         {
            var building:* = undefined;
            var farmItem:* = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            building = m_building;
            var createWindow:* = function(purchased:Boolean = false):void
            {
               if(!purchased)
               {
                  building.displayStorageDialog();
               }
            };
            if(Global.worldManager.isVisiting())
            {
               UI.displayMarketPreviewWindow(farmItem);
            }
            else
            {
               UI.displayMiniMarketDialog([farmItem.name],"","",createWindow,true);
            }
            FarmStatsManager.count("dialog",m_building.getItemName(),"market",farmItem.name);
            m_skipCloseStat = true;
            close();
         };
      }
      
      override public function close() : void
      {
         if(!this.m_skipCloseStat)
         {
            FarmStatsManager.count("dialog",this.m_building.getItemName(),"X");
            if(Global.worldManager.isVisiting())
            {
               FarmStatsManager.count("neighbor_visit",this.m_building.getItemName(),"look_inside","close");
            }
         }
         super.close();
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_building = null;
         this.m_title = null;
         this.m_capacity_tf = null;
         this.m_current_tf = null;
         this.m_howDoesThisWork = null;
         this.m_itemCollection_mc = null;
         this.m_expand_mc = null;
         this.m_itemCollectionTab_bt = null;
         this.m_expandTab_bt = null;
         this.m_state = VIEW_FEATURE;
         this.m_featuredItemFrame = null;
      }
   }
}

