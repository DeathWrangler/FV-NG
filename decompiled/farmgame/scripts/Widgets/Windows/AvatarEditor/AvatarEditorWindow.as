package Widgets.Windows.AvatarEditor
{
   import Classes.Avatar.AvatarClothingIndicator;
   import Classes.Avatar.AvatarItem;
   import Classes.Avatar.AvatarManager;
   import Classes.Avatar.FarmAvatar;
   import Classes.FarmvilleClothingLoader;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.AvatarOffboardDialog;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Events.LoaderEvent;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Managers.FarmStatsManager;
   import Managers.FreezeManager;
   import MyLife.Assets.Avatar.Avatar;
   import MyLife.MyLifeUtils;
   import MyLife.NPC.SimpleNPC;
   import MyLife.Utils.DisplayObjectUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AvatarEditor.AvatarInventorySlotFrame;
   import Widgets.Frames.AvatarEditor.AvatarMarketSlotFrame;
   import Widgets.Frames.AvatarEditor.AvatarPreviewFrame;
   import Widgets.Menu.DropDownMenu;
   import Widgets.Menu.MenuItem;
   import Widgets.Windows.FarmWindow;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   
   public class AvatarEditorWindow extends FarmWindow
   {
      
      public static const CATEGORY_GENDER:String = "Gender";
      
      public static const CATEGORY_FEATURES:String = "Features";
      
      public static const CATEGORY_CLOTHING:String = "Clothing";
      
      public static const CLOTHING_CATEGORIES:Array = ["shirt","bottom","outfit","shoe","accessory","costume"];
      
      private const ALL_CLOTHING_CATEGORY:String = "all";
      
      private const AVATAR_PREVIEW_SCALE:Number = 0.4;
      
      private const AVATAR_PREVIEW_X:Number = 115;
      
      private const AVATAR_PREVIEW_Y:Number = 285;
      
      private var m_isModified:Boolean = false;
      
      private var m_hasPurchased:Boolean = false;
      
      private var m_originalGender:int;
      
      private var m_originalAvatarData:Object;
      
      private var m_previewGender:int;
      
      private var m_previewAvatarData:Object;
      
      private var m_genderPreviewAvatarData:Object;
      
      private var m_category:String = "";
      
      private var m_subCategory:String = "";
      
      private var m_selectedItems:Array;
      
      private var m_previewItemId:String = "";
      
      private var m_clothingLoader:FarmvilleClothingLoader;
      
      private var m_avatar:FarmAvatar;
      
      private var m_previewAvatar:Avatar;
      
      private var m_avatarItemLoading:AvatarItem;
      
      private var m_breadcrumbTextField:ZwTextField;
      
      private var m_genderTab:FarmTabButton;
      
      private var m_featuresTab:FarmTabButton;
      
      private var m_clothingTab:FarmTabButton;
      
      private var m_featuresSubMenu:DropDownMenu;
      
      private var m_clothingSubMenu:DropDownMenu;
      
      private var m_genderFrame:ZwFrame;
      
      private var m_genderFemaleFrame:ZwFrame;
      
      private var m_genderMaleFrame:ZwFrame;
      
      private var m_featuresSlotFrame:AvatarInventorySlotFrame;
      
      private var m_clothingAllSlotFrame:AvatarMarketSlotFrame;
      
      private var m_clothingInventorySlotFrame:AvatarInventorySlotFrame;
      
      private var m_clothingMarketSlotFrame:AvatarMarketSlotFrame;
      
      private var m_previewFrame:AvatarPreviewFrame;
      
      private var m_whatIsThisPopup:GenericPopup;
      
      private var m_impulseBuyDialog:ImpulseBuy;
      
      private var m_flagCloseWindow:Boolean = false;
      
      private var m_buyPerformImmediately:Boolean = false;
      
      public function AvatarEditorWindow(avatar:FarmAvatar, category:String = "Clothing", subCategory:String = "all", previewItemId:String = "")
      {
         super("assets/dialogs/FV_AvatarEditor.swf");
         this.m_avatar = avatar;
         this.m_category = category;
         this.m_subCategory = subCategory;
         this.m_previewItemId = previewItemId;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         dispatchEvent(new LoaderEvent(LoaderEvent.LOADED));
         if(Boolean(m_loader) && Boolean(m_loader.content))
         {
            m_loader.content.filters = [new DropShadowFilter()];
         }
         if(m_window.close_bt)
         {
            m_window.close_bt.visible = false;
         }
         if(m_showOnLoad)
         {
            m_showOnLoad = false;
            show();
         }
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","AvatarEditorWindow_Title")));
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.onWhatIsThisButtonClick));
         this.m_breadcrumbTextField = addWidget(new ZwTextField(m_window.breadCrumb_tf,"")) as ZwTextField;
         var navFrame:ZwFrame = addWidget(new ZwFrame(m_window.frame_nav_mc)) as ZwFrame;
         this.m_genderTab = navFrame.addWidget(new FarmTabButton(m_window.frame_nav_mc.slot_0_mc,ZLocUtils.t("Dialogs","AvatarEditorWindow_Category_Gender"),this.onGenderTabClick)) as FarmTabButton;
         this.m_featuresTab = navFrame.addWidget(new FarmTabButton(m_window.frame_nav_mc.slot_1_mc,ZLocUtils.t("Dialogs","AvatarEditorWindow_Category_Features"))) as FarmTabButton;
         (this.m_featuresTab.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onFeaturesTabMouseOver,false,0,true);
         (this.m_featuresTab.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onFeaturesTabMouseOut,false,0,true);
         this.m_featuresSubMenu = navFrame.addWidget(new DropDownMenu(m_window.frame_nav_mc.frame_subNav1_mc,this.onFeaturesSubMenuItemSelected),false) as DropDownMenu;
         (this.m_featuresSubMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onFeaturesTabMouseOut,false,0,true);
         this.m_clothingTab = navFrame.addWidget(new FarmTabButton(m_window.frame_nav_mc.slot_2_mc,ZLocUtils.t("Dialogs","AvatarEditorWindow_Category_Clothing"))) as FarmTabButton;
         (this.m_clothingTab.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onClothingTabMouseOver,false,0,true);
         (this.m_clothingTab.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onClothingTabMouseOut,false,0,true);
         this.m_clothingSubMenu = navFrame.addWidget(new DropDownMenu(m_window.frame_nav_mc.frame_subNav2_mc,this.onClothingSubMenuItemSelected),false) as DropDownMenu;
         (this.m_clothingSubMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onClothingTabMouseOut,false,0,true);
         this.m_genderFrame = addWidget(new ZwFrame(m_window.frame_gender_mc),false) as ZwFrame;
         this.m_genderFemaleFrame = this.m_genderFrame.addWidget(new ZwFrame(m_window.frame_gender_mc.select_female)) as ZwFrame;
         (this.m_genderFemaleFrame.element as MovieClip).addEventListener(MouseEvent.CLICK,this.onGenderFemaleClick,false,0,true);
         (this.m_genderFemaleFrame.element as MovieClip).buttonMode = true;
         Utilities.toggleInputOnlyChildren(this.m_genderFemaleFrame.element as MovieClip,false);
         this.m_genderFemaleFrame.addWidget(new ZwTextField(m_window.frame_gender_mc.select_female.female_tf,ZLocUtils.t("Dialogs","AvatarEditorWindow_Gender_Female")));
         this.m_genderMaleFrame = this.m_genderFrame.addWidget(new ZwFrame(m_window.frame_gender_mc.select_male)) as ZwFrame;
         (this.m_genderMaleFrame.element as MovieClip).addEventListener(MouseEvent.CLICK,this.onGenderMaleClick,false,0,true);
         (this.m_genderMaleFrame.element as MovieClip).buttonMode = true;
         Utilities.toggleInputOnlyChildren(this.m_genderMaleFrame.element as MovieClip,false);
         this.m_genderMaleFrame.addWidget(new ZwTextField(m_window.frame_gender_mc.select_male.female_tf,ZLocUtils.t("Dialogs","AvatarEditorWindow_Gender_Male")));
         this.m_featuresSlotFrame = addWidget(new AvatarInventorySlotFrame(m_window.frame_inventory2_mc,this.onItemUse,this.onItemRemove),false) as AvatarInventorySlotFrame;
         this.m_clothingInventorySlotFrame = addWidget(new AvatarInventorySlotFrame(m_window.frame_inventory_mc,this.onItemUse,this.onItemRemove),false) as AvatarInventorySlotFrame;
         this.m_clothingMarketSlotFrame = addWidget(new AvatarMarketSlotFrame(m_window.frame_market_mc,this.onItemBuy,this.onItemTryOn,this.onItemRemove),false) as AvatarMarketSlotFrame;
         this.m_clothingAllSlotFrame = addWidget(new AvatarMarketSlotFrame(m_window.frame_market2_mc,this.onItemBuy,this.onItemTryOn,this.onItemRemove),false) as AvatarMarketSlotFrame;
         addWidget(new FarmAnimatedTextButton(m_window.save_bt,ZLocUtils.t("Dialogs","AvatarEditorWindow_SaveButton"),this.onSaveButtonClick));
         addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t("Dialogs","Cancel"),this.onCancelButtonClick));
         this.m_clothingLoader = new FarmvilleClothingLoader();
         this.m_previewFrame = addWidget(new AvatarPreviewFrame(m_window.preview_market_mc,this.onBuyNow,this.onReset)) as AvatarPreviewFrame;
         this.m_previewAvatar = new Avatar(this.m_clothingLoader);
         this.m_previewAvatar.x = this.AVATAR_PREVIEW_X;
         this.m_previewAvatar.y = this.AVATAR_PREVIEW_Y;
         (this.m_previewFrame.element as MovieClip).addChild(this.m_previewAvatar);
         this.m_previewGender = this.m_originalGender = this.m_avatar.gender;
         this.m_originalAvatarData = MyLifeUtils.cloneObject(this.m_avatar.getAvatarCustomizationData());
         this.m_previewAvatarData = MyLifeUtils.cloneObject(this.m_originalAvatarData);
         this.refreshAvatarPreview(false);
         this.refreshSubMenus();
         this.refresh();
      }
      
      private function setCategory(category:String, subCategory:String = "") : void
      {
         this.m_category = category;
         this.m_subCategory = subCategory;
         this.refresh();
      }
      
      private function setGender(gender:int) : void
      {
         var recentAvatarData:Object = null;
         var category:String = null;
         var item:AvatarItem = null;
         var tempPreviewData:Object = null;
         this.m_isModified = true;
         this.m_previewGender = gender;
         if(this.m_genderPreviewAvatarData == null)
         {
            this.m_genderPreviewAvatarData = this.m_previewAvatarData;
            this.m_previewAvatarData = Global.avatarConfigSettings.getDefaultRawCustomizationData(FarmAvatar.getGenderKeyword(this.m_previewGender));
            recentAvatarData = Global.player.avatarState.getAllRecentlyWorn(FarmAvatar.getGenderKeyword(this.m_previewGender));
            for(category in recentAvatarData)
            {
               if(category != "costume")
               {
                  item = Global.avatarConfigSettings.getItemById(String(recentAvatarData[category]));
                  if(item)
                  {
                     this.m_previewAvatarData[category] = item.toRawObject();
                  }
               }
            }
         }
         else
         {
            tempPreviewData = this.m_previewAvatarData;
            this.m_previewAvatarData = this.m_genderPreviewAvatarData;
            this.m_genderPreviewAvatarData = tempPreviewData;
         }
         this.refreshAvatarPreview(false);
         this.refreshSubMenus();
         this.refresh();
      }
      
      private function onWhatIsThisButtonClick(evt:MouseEvent) : void
      {
         this.m_whatIsThisPopup = new GenericPopup(ZLocUtils.t("Dialogs","AvatarEditorWindow_WhatIsThis"),GenericPopup.TYPE_OK,this.onWhatIsThisClose);
         UI.displayPopup(this.m_whatIsThisPopup,false,"avatareEditorWhatIsThisPopup",true);
         enableInput = false;
      }
      
      private function onWhatIsThisClose(event:GenericPopupEvent) : void
      {
         enableInput = true;
         this.m_whatIsThisPopup = null;
      }
      
      private function onGenderTabClick(evt:MouseEvent) : void
      {
         this.setCategory(CATEGORY_GENDER);
      }
      
      private function onFeaturesSubMenuItemSelected(item:MenuItem) : void
      {
         this.setCategory(CATEGORY_FEATURES,item.data as String);
         this.m_featuresSubMenu.visible = false;
      }
      
      private function onFeaturesTabMouseOver(evt:MouseEvent) : void
      {
         if(!this.m_featuresSubMenu.visible)
         {
            this.m_featuresSubMenu.visible = true;
         }
      }
      
      private function onFeaturesTabMouseOut(evt:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_featuresTab.element as MovieClip,evt.relatedObject) && !FarmGameUtil.isDescendant(this.m_featuresSubMenu.element as MovieClip,evt.relatedObject))
         {
            this.m_featuresSubMenu.visible = false;
         }
      }
      
      private function onClothingSubMenuItemSelected(item:MenuItem) : void
      {
         this.setCategory(CATEGORY_CLOTHING,item.data as String);
         this.m_clothingSubMenu.visible = false;
      }
      
      private function onClothingTabMouseOver(evt:MouseEvent) : void
      {
         if(!this.m_clothingSubMenu.visible)
         {
            this.m_clothingSubMenu.visible = true;
         }
      }
      
      private function onClothingTabMouseOut(evt:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_clothingTab.element as MovieClip,evt.relatedObject) && !FarmGameUtil.isDescendant(this.m_clothingSubMenu.element as MovieClip,evt.relatedObject))
         {
            this.m_clothingSubMenu.visible = false;
         }
      }
      
      private function onGenderFemaleClick(evt:MouseEvent) : void
      {
         if(this.m_previewGender != SimpleNPC.GENDER_FEMALE)
         {
            this.setGender(SimpleNPC.GENDER_FEMALE);
         }
      }
      
      private function onGenderMaleClick(evt:MouseEvent) : void
      {
         if(this.m_previewGender != SimpleNPC.GENDER_MALE)
         {
            this.setGender(SimpleNPC.GENDER_MALE);
         }
      }
      
      private function onReset(evt:MouseEvent = null) : void
      {
         FarmStatsManager.count("Avatar","Customize_avatar","Reset");
         this.resetAvatarPreview();
      }
      
      private function onBuyNow(evt:MouseEvent = null) : void
      {
         var items:Array = this.m_previewFrame.items;
         if(items != null)
         {
            FarmStatsManager.count("Avatar","Customize_avatar","Buy","Click_buy_now");
            this.buyItems(items);
         }
      }
      
      private function onItemUse(item:AvatarItem) : void
      {
         FarmStatsManager.count("Avatar","Customize_avatar","Use");
         this.equipItem(item);
         AvatarClothingIndicator.countUsesItem(this.m_avatar);
      }
      
      private function onItemTryOn(item:AvatarItem) : void
      {
         FarmStatsManager.count("Avatar","Customize_avatar","Try");
         this.equipItem(item);
         AvatarClothingIndicator.countTriesOnClothing(this.m_avatar);
      }
      
      private function onItemRemove(item:AvatarItem) : void
      {
         FarmStatsManager.count("Avatar","Customize_avatar","Remove");
         this.removeItem(item);
      }
      
      private function onItemBuy(item:AvatarItem, itemBoughtCallback:Function = null) : void
      {
         FarmStatsManager.count("Avatar","Customize_avatar","Buy","Click_buy");
         this.buyItem(item,itemBoughtCallback);
      }
      
      private function onImpulseBuyCancel(event:ImpulseBuyEvent) : void
      {
         enableInput = true;
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
      }
      
      private function shiftFeaturedItemToFront(items:Array) : void
      {
         var index:int = 0;
         var i:int = 0;
         var item:AvatarItem = null;
         var featured:AvatarItem = Global.avatarConfigSettings.getFeaturedAvatarItem(this.m_previewGender);
         if(featured)
         {
            index = -1;
            i = 0;
            for each(item in items)
            {
               if(item.itemId == featured.itemId)
               {
                  index = i;
                  break;
               }
               i++;
            }
            if(index > 0)
            {
               items.splice(index,1);
               items.unshift(featured);
            }
         }
      }
      
      private function shiftNewItemsToFront(items:Array) : void
      {
         var newItem:AvatarItem = null;
         var index:int = 0;
         var i:int = 0;
         var item:AvatarItem = null;
         var newItems:Array = Global.avatarConfigSettings.getNewAvatarItems();
         for each(newItem in newItems)
         {
            index = -1;
            i = 0;
            for each(item in items)
            {
               if(item.itemId == newItem.itemId)
               {
                  index = i;
                  break;
               }
               i++;
            }
            if(index > 0)
            {
               items.splice(index,1);
               items.unshift(newItem);
            }
         }
      }
      
      private function shiftSelectedItemsToFront(items:Array) : void
      {
         var item:AvatarItem = null;
         var itemsFound:Array = null;
         if(this.m_selectedItems != null && this.m_selectedItems.length > 0)
         {
            itemsFound = new Array();
            for each(item in items)
            {
               if(this.m_selectedItems.indexOf(item.itemId) >= 0)
               {
                  itemsFound.push(item);
               }
            }
            if(itemsFound.length > 0)
            {
               while(itemsFound.length > 0)
               {
                  item = itemsFound.pop();
                  items.splice(items.indexOf(item),1);
                  items.unshift(item);
               }
            }
         }
      }
      
      private function refresh() : void
      {
         var items:Array = null;
         var inventoryItems:Array = null;
         var marketItems:Array = null;
         var item:AvatarItem = null;
         var allItems:Array = null;
         var breadcrumb:String = "";
         if(this.m_subCategory)
         {
            breadcrumb = ZLocUtils.t("Dialogs","AvatarEditorWindow_Category_" + this.m_category) + " / " + ZLocUtils.t("Dialogs",this.m_subCategory + "_submenu");
         }
         else
         {
            breadcrumb = ZLocUtils.t("Dialogs","AvatarEditorWindow_Category_" + this.m_category);
         }
         this.m_breadcrumbTextField.text = breadcrumb;
         this.m_genderTab.setToggleState(ZwToggleState.DESELECTED);
         this.m_genderFrame.visible = false;
         this.m_featuresTab.setToggleState(ZwToggleState.DESELECTED);
         this.m_featuresSlotFrame.visible = false;
         this.m_clothingTab.setToggleState(ZwToggleState.DESELECTED);
         this.m_clothingInventorySlotFrame.visible = false;
         this.m_clothingMarketSlotFrame.visible = false;
         this.m_clothingAllSlotFrame.visible = false;
         switch(this.m_category)
         {
            case CATEGORY_GENDER:
               this.m_genderTab.setToggleState(ZwToggleState.SELECTED);
               this.m_genderFrame.visible = true;
               switch(this.m_previewGender)
               {
                  case SimpleNPC.GENDER_FEMALE:
                     (this.m_genderFemaleFrame.element as MovieClip).gotoAndStop(2);
                     (this.m_genderMaleFrame.element as MovieClip).gotoAndStop(3);
                     break;
                  case SimpleNPC.GENDER_MALE:
                     (this.m_genderFemaleFrame.element as MovieClip).gotoAndStop(1);
                     (this.m_genderMaleFrame.element as MovieClip).gotoAndStop(4);
               }
               break;
            case CATEGORY_FEATURES:
               this.m_featuresTab.setToggleState(ZwToggleState.SELECTED);
               items = Global.avatarConfigSettings.getItemsByKeywords([FarmAvatar.getGenderKeyword(this.m_previewGender),this.m_subCategory]);
               this.shiftSelectedItemsToFront(items);
               this.m_featuresSlotFrame.items = items;
               this.m_featuresSlotFrame.visible = true;
               break;
            case CATEGORY_CLOTHING:
               this.m_clothingTab.setToggleState(ZwToggleState.SELECTED);
               items = Global.avatarConfigSettings.getItemsByKeywords([FarmAvatar.getGenderKeyword(this.m_previewGender),this.m_subCategory]);
               inventoryItems = new Array();
               marketItems = new Array();
               for each(item in items)
               {
                  if(Global.player.avatarState.isOwned(item.itemId))
                  {
                     inventoryItems.push(item);
                  }
                  else if(Global.player.avatarState.canBuy(item.itemId,true))
                  {
                     marketItems.push(item);
                  }
               }
               this.shiftSelectedItemsToFront(inventoryItems);
               this.shiftSelectedItemsToFront(marketItems);
               allItems = this.getAllBuyableClothingItems();
               this.shiftNewItemsToFront(allItems);
               this.shiftNewItemsToFront(marketItems);
               this.m_clothingAllSlotFrame.items = allItems;
               this.m_clothingInventorySlotFrame.items = inventoryItems;
               this.m_clothingMarketSlotFrame.items = marketItems;
               if(this.ALL_CLOTHING_CATEGORY == this.m_subCategory)
               {
                  this.m_clothingAllSlotFrame.visible = true;
                  this.m_clothingInventorySlotFrame.visible = false;
                  this.m_clothingMarketSlotFrame.visible = false;
               }
               else
               {
                  this.m_clothingAllSlotFrame.visible = false;
                  this.m_clothingInventorySlotFrame.visible = true;
                  this.m_clothingMarketSlotFrame.visible = true;
               }
         }
      }
      
      private function getAllBuyableClothingItems() : Array
      {
         var category:String = null;
         var clothes:Array = null;
         var item:AvatarItem = null;
         var result:Array = new Array();
         for each(category in CLOTHING_CATEGORIES)
         {
            if(this.ALL_CLOTHING_CATEGORY != category)
            {
               clothes = Global.avatarConfigSettings.getItemsByKeywords([FarmAvatar.getGenderKeyword(this.m_previewGender),category]);
               for each(item in clothes)
               {
                  if(Global.player.avatarState.canBuy(item.itemId,true))
                  {
                     result.push(item);
                  }
               }
            }
         }
         return result;
      }
      
      private function refreshSubMenus() : void
      {
         var key:String = null;
         var featured:Boolean = false;
         var newItem:AvatarItem = null;
         var featuresSubMenuItems:Array = new Array(new MenuItem("face",ZLocUtils.t("Dialogs","face_submenu")),new MenuItem("hair",ZLocUtils.t("Dialogs","hair_submenu")),new MenuItem("eyebrows",ZLocUtils.t("Dialogs","eyebrows_submenu")),new MenuItem("eyes",ZLocUtils.t("Dialogs","eyes_submenu")),new MenuItem("ears",ZLocUtils.t("Dialogs","ears_submenu")),new MenuItem("nose",ZLocUtils.t("Dialogs","nose_submenu")),new MenuItem("mouth",ZLocUtils.t("Dialogs","mouth_submenu")),new MenuItem("skin",ZLocUtils.t("Dialogs","skin_submenu")));
         if(this.m_previewGender == SimpleNPC.GENDER_FEMALE)
         {
            featuresSubMenuItems.push(new MenuItem("makeup",ZLocUtils.t("Dialogs","makeup_submenu")));
         }
         else
         {
            featuresSubMenuItems.push(new MenuItem("facialhair",ZLocUtils.t("Dialogs","facialhair_submenu")));
         }
         this.m_featuresSubMenu.items = featuresSubMenuItems;
         var newItems:Array = Global.avatarConfigSettings.getNewAvatarItems();
         var clothingSubMenuItems:Array = new Array();
         clothingSubMenuItems.push(new MenuItem(this.ALL_CLOTHING_CATEGORY,ZLocUtils.t("Dialogs","all_submenu")));
         for each(key in CLOTHING_CATEGORIES)
         {
            featured = false;
            for each(newItem in newItems)
            {
               if(newItem.category == key)
               {
                  featured = true;
                  break;
               }
            }
            clothingSubMenuItems.push(new MenuItem(key,ZLocUtils.t("Dialogs",key + "_submenu"),featured));
         }
         this.m_clothingSubMenu.items = clothingSubMenuItems;
      }
      
      private function refreshSelectedItems() : void
      {
         var category:String = null;
         var previewItems:Array = null;
         var rawItem:Object = null;
         var item:AvatarItem = null;
         var selectedItems:Array = new Array();
         for(category in this.m_previewAvatarData)
         {
            if(this.m_previewAvatarData[category]["itemId"])
            {
               selectedItems.push(String(this.m_previewAvatarData[category]["itemId"]));
            }
         }
         this.m_selectedItems = selectedItems;
         this.m_featuresSlotFrame.selectedItems = selectedItems;
         this.m_clothingInventorySlotFrame.selectedItems = selectedItems;
         this.m_clothingMarketSlotFrame.selectedItems = selectedItems;
         this.m_clothingAllSlotFrame.selectedItems = selectedItems;
         previewItems = new Array();
         for each(rawItem in this.m_previewAvatarData)
         {
            if(rawItem != null && Boolean(rawItem["itemId"]))
            {
               if(!Global.player.avatarState.isOwned(String(rawItem["itemId"])))
               {
                  item = Global.avatarConfigSettings.getItemById(String(rawItem["itemId"]));
                  if(item != null && previewItems.indexOf(item) < 0)
                  {
                     previewItems.push(item);
                  }
               }
            }
         }
         this.m_previewFrame.items = previewItems;
      }
      
      private function refreshAvatarPreview(renderOnly:Boolean = true) : void
      {
         var item:AvatarItem = null;
         var category:String = null;
         var defaultAvatarData:Object = null;
         var previewItem:AvatarItem = null;
         this.m_previewAvatar.initAvatar(this.m_previewGender,this.AVATAR_PREVIEW_SCALE);
         var categories:Array = Global.avatarConfigSettings.getCategories();
         if(this.m_previewGender == this.m_originalGender)
         {
            for(category in this.m_originalAvatarData)
            {
               if(Global.avatarConfigSettings.isCategory(category))
               {
                  if(this.m_previewAvatarData[category] == null || Number(this.m_previewAvatarData[category]["itemId"]) < 0)
                  {
                     if(this.m_originalAvatarData[category] != null && Number(this.m_originalAvatarData[category]["itemId"]) > 0)
                     {
                        item = Global.avatarConfigSettings.getItemById(String(this.m_originalAvatarData[category]["itemId"]));
                        if(Boolean(item) && !item.isRemovable)
                        {
                           this.m_previewAvatarData[category] = this.m_originalAvatarData[category];
                           renderOnly = false;
                        }
                     }
                  }
               }
            }
         }
         var recentAvatarData:Object = Global.player.avatarState.getAllRecentlyWorn(FarmAvatar.getGenderKeyword(this.m_previewGender));
         for(category in recentAvatarData)
         {
            if(Global.avatarConfigSettings.isCategory(category))
            {
               if(this.m_previewAvatarData[category] == null || Number(this.m_previewAvatarData[category]["itemId"]) < 0)
               {
                  item = Global.avatarConfigSettings.getItemById(String(recentAvatarData[category]));
                  if(Boolean(item) && !item.isRemovable)
                  {
                     this.m_previewAvatarData[category] = item.toRawObject();
                     renderOnly = false;
                  }
               }
            }
         }
         defaultAvatarData = Global.avatarConfigSettings.getDefaultRawCustomizationData(FarmAvatar.getGenderKeyword(this.m_previewGender));
         for(category in defaultAvatarData)
         {
            if(Global.avatarConfigSettings.isCategory(category))
            {
               if(this.m_previewAvatarData[category] == null || Number(this.m_previewAvatarData[category]["itemId"]) < 0)
               {
                  this.m_previewAvatarData[category] = defaultAvatarData[category];
                  renderOnly = false;
               }
            }
         }
         if(renderOnly)
         {
            this.m_previewAvatar.renderClothes(this.m_previewAvatarData);
         }
         else
         {
            this.m_previewAvatar.loadAvatarClothes(this.m_previewAvatarData);
         }
         if(this.m_previewItemId)
         {
            previewItem = Global.avatarConfigSettings.getItemById(this.m_previewItemId);
            if(previewItem != null)
            {
               this.equipItem(previewItem);
            }
            this.m_previewItemId = "";
         }
         this.refreshSelectedItems();
      }
      
      private function resetAvatarPreview() : void
      {
         this.m_isModified = false;
         this.m_previewGender = this.m_originalGender;
         this.m_previewAvatarData = MyLifeUtils.cloneObject(this.m_originalAvatarData);
         this.refreshAvatarPreview();
      }
      
      private function equipItem(item:AvatarItem, renderOnly:Boolean = false) : void
      {
         this.m_isModified = true;
         if(renderOnly || item.assetFilename == "" && item.metaData != "")
         {
            this.m_previewAvatar.renderItem(item.toRawObject());
            this.m_previewAvatarData = this.m_previewAvatar.getCurrentAvatarClothes();
            this.refreshAvatarPreview(true);
         }
         else
         {
            this.m_avatarItemLoading = item;
            this.m_clothingLoader.loadClothing([this.m_avatarItemLoading.toRawObject()],this.onEquipItemLoaded);
         }
      }
      
      private function onEquipItemLoaded() : void
      {
         if(this.m_avatarItemLoading != null && this.m_previewAvatar != null)
         {
            this.m_previewAvatar.renderItem(this.m_avatarItemLoading.toRawObject());
            this.m_previewAvatarData = this.m_previewAvatar.getCurrentAvatarClothes();
            this.m_avatarItemLoading = null;
            this.refreshAvatarPreview();
         }
      }
      
      private function removeItem(item:AvatarItem) : void
      {
         this.m_isModified = true;
         this.m_previewAvatar.removeItem(Number(item["itemId"]));
         this.m_previewAvatarData = this.m_previewAvatar.getCurrentAvatarClothes();
         this.refreshAvatarPreview();
      }
      
      private function buyItem(item:AvatarItem, itemBoughtCallback:Function = null) : void
      {
         var renderOnly:Boolean = false;
         var inventoryItems:Array = null;
         var canBuy:Boolean = false;
         var currency:String = item.market;
         switch(currency)
         {
            case Currency.CASH:
               canBuy = Global.player.canBuyCash(item.cost,false);
               break;
            case Currency.COINS:
            default:
               canBuy = Global.player.canBuy(item.cost,false);
         }
         if(canBuy)
         {
            if(AvatarManager.buyAvatarItem(item.itemId,false,this.m_buyPerformImmediately))
            {
               this.m_hasPurchased = true;
               SoundManager.chooseAndPlaySound(["click1","click2","click3"]);
               renderOnly = itemBoughtCallback == null ? true : false;
               this.equipItem(item,renderOnly);
               if(itemBoughtCallback != null)
               {
                  itemBoughtCallback();
               }
               if(item.subtype == this.m_subCategory)
               {
                  inventoryItems = this.m_clothingInventorySlotFrame.items;
                  inventoryItems.unshift(item);
                  this.m_clothingInventorySlotFrame.items = inventoryItems;
               }
               switch(currency)
               {
                  case Currency.CASH:
                     AvatarClothingIndicator.countBuysWithCash(this.m_avatar);
                     break;
                  case Currency.COINS:
                     AvatarClothingIndicator.countBuysWithCoins(this.m_avatar);
               }
               if(this.m_buyPerformImmediately)
               {
                  this.m_buyPerformImmediately = false;
                  this.saveAvatar();
                  FreezeManager.pushPostThawCallback(AvatarManager.startPurchaseAnimationFlow);
               }
            }
         }
         else
         {
            switch(currency)
            {
               case Currency.CASH:
                  this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",item.cost,item.category);
                  break;
               case Currency.COINS:
                  this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_COINS,"impulseBuyPopup",0,item.category);
            }
            if(this.m_impulseBuyDialog)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
               enableInput = false;
            }
         }
      }
      
      private function buyItems(items:Array) : void
      {
         var cashTotal:int = 0;
         var coinTotal:int = 0;
         var item:AvatarItem = null;
         var currency:String = null;
         var message:String = null;
         var itemToBuy:AvatarItem = null;
         if(items != null)
         {
            cashTotal = 0;
            coinTotal = 0;
            for each(item in items)
            {
               currency = item.market;
               switch(currency)
               {
                  case Currency.CASH:
                     cashTotal += item.cost;
                     break;
                  case Currency.COINS:
                     coinTotal += item.cost;
               }
            }
            if(cashTotal > 0)
            {
               if(!Global.player.canBuyCash(cashTotal,false))
               {
                  this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",cashTotal,"avatar_cash_buy");
               }
            }
            else if(coinTotal > 0)
            {
               if(!Global.player.canBuy(coinTotal,false))
               {
                  this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_COINS,"impulseBuyPopup",0,"avatar_coin_buy");
               }
            }
            if(this.m_impulseBuyDialog)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
               enableInput = false;
            }
            else if(cashTotal > 0)
            {
               message = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":cashTotal});
               UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onByCashMessageClose,"BuyAvatarItemConfirmation",true);
            }
            else
            {
               for each(itemToBuy in items)
               {
                  this.buyItem(itemToBuy);
               }
               this.refresh();
               if(this.m_flagCloseWindow)
               {
                  this.m_flagCloseWindow = false;
               }
            }
         }
      }
      
      private function onByCashMessageClose(event:GenericPopupEvent) : void
      {
         var items:Array = null;
         var itemToBuy:AvatarItem = null;
         if(event.button == GenericPopup.OK)
         {
            items = this.m_previewFrame.items;
            if(items)
            {
               for each(itemToBuy in items)
               {
                  this.buyItem(itemToBuy);
               }
               this.refresh();
            }
         }
         if(this.m_flagCloseWindow)
         {
            this.m_flagCloseWindow = false;
            this.close();
         }
      }
      
      private function saveAvatar() : void
      {
         this.m_avatar.setAvatarCustomizationData(this.m_previewAvatarData,this.m_previewGender);
         this.m_originalGender = this.m_previewGender;
         this.m_originalAvatarData = MyLifeUtils.cloneObject(this.m_previewAvatarData);
         this.refreshAvatarPreview();
      }
      
      private function onSaveButtonClick(evt:MouseEvent) : void
      {
         FarmStatsManager.count("Avatar","Customize_avatar","Exit","Click_save");
         var items:Array = this.m_previewFrame.items;
         if(items.length > 0)
         {
            FarmStatsManager.count("Avatar","Customize_avatar","Exit","Exit_wait_dialog");
            this.displayWaitDialog();
         }
         else
         {
            FarmStatsManager.count("Avatar","Customize_avatar","Exit","Exit_no_dialog");
            if(this.m_isModified)
            {
               this.saveAvatar();
               if(this.m_hasPurchased)
               {
                  FreezeManager.pushPostThawCallback(AvatarManager.startPurchaseAnimationFlow);
               }
            }
            this.close();
         }
      }
      
      private function onCancelButtonClick(evt:MouseEvent) : void
      {
         FarmStatsManager.count("Avatar","Customize_avatar","Exit","Click_cancel");
         var items:Array = this.m_previewFrame.items;
         if(items.length > 0)
         {
            FarmStatsManager.count("Avatar","Customize_avatar","Exit","Exit_wait_dialog");
            this.displayWaitDialog();
         }
         else
         {
            FarmStatsManager.count("Avatar","Customize_avatar","Exit","Exit_no_dialog");
            this.close();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("Avatar","Customize_avatar","Exit","Click_x");
         var items:Array = this.m_previewFrame.items;
         if(items.length > 0)
         {
            FarmStatsManager.count("Avatar","Customize_avatar","Exit","Exit_wait_dialog");
            this.displayWaitDialog();
         }
         else
         {
            FarmStatsManager.count("Avatar","Customize_avatar","Exit","Exit_no_dialog");
            super.onClose(event);
         }
         AvatarClothingIndicator.countExit(this.m_avatar);
      }
      
      override public function close() : void
      {
         super.close();
         if(Global.player.getSeenFlag("avatarOnboard") && !Global.player.getSeenFlag("avatarOffboard"))
         {
            Global.player.setSeenFlag("avatarOffboard");
            UI.displayPopup(new AvatarOffboardDialog(),true);
         }
         Global.player.setSeenSessionFlag("avatarEditor");
      }
      
      private function displayWaitDialog() : void
      {
         var snapshot:Bitmap = null;
         try
         {
            snapshot = new Bitmap(DisplayObjectUtils.getBitmapData(this.m_previewAvatar,true));
         }
         catch(e:Error)
         {
         }
         UI.displayPopup(new AvatarEditorWaitWindow(snapshot,this.m_previewFrame.items,this.onWaitBuyNow,this.onWaitCancel),false);
         enableInput = false;
      }
      
      private function onWaitBuyNow() : void
      {
         FarmStatsManager.count("Avatar","Customize_avatar","Buy","Exit_buy");
         enableInput = true;
         this.m_flagCloseWindow = true;
         this.m_buyPerformImmediately = true;
         this.buyItems(this.m_previewFrame.items);
         if(!this.m_flagCloseWindow)
         {
            this.close();
         }
      }
      
      private function onWaitCancel() : void
      {
         enableInput = true;
         this.close();
      }
      
      override protected function release() : void
      {
         this.m_avatar = null;
         this.m_clothingLoader = null;
         this.m_previewAvatar = null;
         this.m_originalAvatarData = null;
         this.m_previewAvatarData = null;
         this.m_genderPreviewAvatarData = null;
         this.m_breadcrumbTextField = null;
         this.m_genderTab = null;
         (this.m_featuresTab.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onFeaturesTabMouseOver);
         (this.m_featuresTab.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onFeaturesTabMouseOut);
         this.m_featuresTab = null;
         (this.m_clothingTab.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onClothingTabMouseOver);
         (this.m_clothingTab.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onClothingTabMouseOut);
         this.m_clothingTab = null;
         (this.m_featuresSubMenu.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onFeaturesTabMouseOut);
         this.m_featuresSubMenu = null;
         (this.m_clothingSubMenu.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onClothingTabMouseOut);
         this.m_clothingSubMenu = null;
         (this.m_genderFemaleFrame.element as MovieClip).removeEventListener(MouseEvent.CLICK,this.onGenderFemaleClick);
         this.m_genderFemaleFrame = null;
         (this.m_genderMaleFrame.element as MovieClip).removeEventListener(MouseEvent.CLICK,this.onGenderMaleClick);
         this.m_genderMaleFrame = null;
         this.m_featuresSlotFrame = null;
         this.m_clothingInventorySlotFrame = null;
         this.m_clothingMarketSlotFrame = null;
         this.m_clothingAllSlotFrame = null;
         this.m_previewFrame = null;
         super.release();
      }
   }
}

