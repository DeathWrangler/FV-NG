package Widgets.Windows.DuckPond
{
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.FeaturedRenderFManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.GenericExpandSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DuckPondWindow extends FarmWindow
   {
      
      public static const VIEW_FEATURE:int = 0;
      
      public static const VIEW_EXPAND:int = 1;
      
      private static var m_state:int = 0;
      
      private var m_building:FeatureBuilding = null;
      
      private var m_featureFrame:ZwFrame = null;
      
      private var m_featureViewButton:FarmAnimatedTextButton = null;
      
      private var m_expandFrame:ZwFrame = null;
      
      private var m_expansionViewButton:FarmAnimatedTextButton = null;
      
      private var m_toggleManager:ZwToggleManager = null;
      
      private var m_infoFrame:ZwFrame = null;
      
      private var m_featuredFrame:ZwFrame = null;
      
      private var m_ducksFrame:ZwFrame = null;
      
      private var m_rolloverFrame:ZwFrame = null;
      
      private var m_featureButton:FarmAnimatedTextButton = null;
      
      private var m_askButton:FarmAnimatedTextButton = null;
      
      private var m_meter:MovieClip = null;
      
      private var m_ducks:MovieClip = null;
      
      private var m_objectPreviewFrames:Array = [];
      
      private var m_objectCodes:Array = [];
      
      private var m_itemPreviewFrames:Array = [];
      
      private var m_itemCodes:Array = ["","","","",""];
      
      private var m_items:Array = [];
      
      private var m_overDuck:Boolean = false;
      
      private var m_duckIndex:String;
      
      private var m_featureIndex:int;
      
      private var m_hideIndex:String;
      
      private var m_featureCode:String;
      
      private var m_defaultViewToggle:ZwVisibilityToggle = null;
      
      private var m_expandViewToggle:ZwVisibilityToggle = null;
      
      public function DuckPondWindow(building:FeatureBuilding)
      {
         this.m_building = building;
         super("assets/dialogs/FV_DuckPond_Complete.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.initializeView();
         var inventoryBtnLabel:String = ZLocUtils.t("Dialogs","MyDucksButtonLabel");
         this.m_featureViewButton = new FarmAnimatedTextButton(m_window.inventory_bt,inventoryBtnLabel,this.onFeatureViewClick);
         addWidget(this.m_featureViewButton);
         var expandBtnLabel:String = ZLocUtils.t("Dialogs","PigpenBuildingExpandBuildingButton");
         this.m_expansionViewButton = new FarmAnimatedTextButton(m_window.expand_bt,expandBtnLabel,this.onExpandViewClick);
         if(this.m_building.hasReachedMaxExpansionLevel())
         {
            this.m_expansionViewButton.enabled = false;
         }
         addWidget(this.m_expansionViewButton);
         var expandStateActive:Boolean = DuckPondWindow.m_state == DuckPondWindow.VIEW_EXPAND;
         this.m_toggleManager = new ZwToggleManager();
         this.m_defaultViewToggle = new ZwVisibilityToggle(this.m_featureViewButton,this.m_featuredFrame);
         this.m_toggleManager.addToggle(this.m_defaultViewToggle,!expandStateActive);
         if(!this.m_building.hasReachedMaxExpansionLevel())
         {
            this.m_expandViewToggle = new ZwVisibilityToggle(this.m_expansionViewButton,this.m_expandFrame);
            this.m_toggleManager.addToggle(this.m_expandViewToggle,expandStateActive);
         }
         else
         {
            this.m_expansionViewButton.visible = false;
            this.m_featureViewButton.visible = false;
         }
         if(m_state == DuckPondWindow.VIEW_EXPAND && this.m_expandViewToggle != null)
         {
            this.m_toggleManager.performToggle(this.m_expandViewToggle);
            this.onClickExpand();
         }
         else
         {
            this.m_toggleManager.performToggle(this.m_defaultViewToggle);
            if(this.m_expandFrame != null)
            {
               this.m_expandFrame.visible = false;
            }
         }
         this.update();
      }
      
      private function onFeatureViewClick(e:Event) : void
      {
         DuckPondWindow.m_state = DuckPondWindow.VIEW_FEATURE;
         this.m_rolloverFrame.element.visible = false;
         this.update();
      }
      
      private function onExpandViewClick(e:Event) : void
      {
         DuckPondWindow.m_state = DuckPondWindow.VIEW_EXPAND;
         this.onClickExpand();
      }
      
      private function onClickExpand() : void
      {
         var message:String = null;
         var dialog:GenericIconPopup = null;
         var seenFlag:String = "expand" + this.m_building.bldgName + this.m_building.storageLevel;
         if(!Global.player.getSeenFlag(seenFlag))
         {
            message = ZLocUtils.t("Dialogs",this.m_building.bldgName + "ExpandMessage");
            dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onShareExpansion,this.m_building.getItem().icon);
            UI.displayPopup(dialog,false);
            Global.player.setSeenFlag(seenFlag);
            FarmStatsManager.count("duckpond","duck_pond_expansion","expansion_started","time_" + this.m_building.storageLevel);
         }
      }
      
      private function onShareExpansion(event:GenericPopupEvent) : void
      {
         var rewardLink:String = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            rewardLink = "gifts.php?giftRecipient=" + Global.player.snUser.uid;
            bundleData = {
               "reward_link":rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}gifts.php?giftRecipient=" + Global.player.snUser.uid,
                  "src":this.m_building.getItem().icon
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("DuckPondExpandAsk",bundleData,[],false);
         }
      }
      
      public function setExpansionViewActive() : void
      {
         DuckPondWindow.m_state = DuckPondWindow.VIEW_EXPAND;
      }
      
      private function initializeView() : void
      {
         this.initFeatureWidgets();
         this.initExpansionWidgets();
      }
      
      private function initFeatureWidgets() : void
      {
         var i:int = 0;
         var item:ZwFrame = null;
         this.m_featureFrame = new ZwFrame(m_window.frame_inventory_mc);
         addWidget(this.m_featureFrame);
         this.m_featureFrame.addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","DuckPond_CompletedTitle")));
         this.m_featureFrame.addWidget(new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t("Dialogs","DuckPond_CompletedHowDoesThisWork"),this.howDoesThisWorkCallback));
         this.m_infoFrame = new ZwFrame(m_window.frame_inventory_mc.infoPanel_mc);
         this.m_featureFrame.addWidget(this.m_infoFrame);
         this.m_infoFrame.addWidget(new ZwTextField(m_window.frame_inventory_mc.infoPanel_mc.generic_tf,ZLocUtils.t("Dialogs","DuckPond_CompletedCapacity")));
         this.m_infoFrame.addWidget(new ZwTextField(m_window.frame_inventory_mc.infoPanel_mc.counter_tf,this.m_building.count + "/" + this.m_building.capacity));
         this.m_askButton = new FarmAnimatedTextButton(m_window.frame_inventory_mc.infoPanel_mc.ask_bt,ZLocUtils.t("Dialogs","DuckPond_CompletedAskForMoreButton"),this.askForMoreCallback);
         this.m_infoFrame.addWidget(this.m_askButton);
         this.m_meter = m_window.frame_inventory_mc.infoPanel_mc.bar_mc;
         this.m_infoFrame.addWidget(new ZwWidget(this.m_meter));
         this.m_meter.scaleX = this.m_building.count / this.m_building.capacity;
         if(GlobalEngine.serverTime - Global.player.getFeatureLastShown("wishlist_duck") * FarmGameUtil.NUM_MSECS_IN_SECOND < 1000 * Global.farmGameSettingsManager.getInt("WishlistLimitTimeSeconds"))
         {
            this.m_askButton.enabled = false;
            this.m_askButton.applyGrayOut = true;
         }
         else if(this.m_building.count < this.m_building.capacity)
         {
            this.m_askButton.enabled = true;
         }
         else
         {
            this.m_askButton.enabled = false;
         }
         this.m_featuredFrame = new ZwFrame(m_window.frame_inventory_mc.featured_mc);
         this.m_featureFrame.addWidget(this.m_featuredFrame);
         this.m_featuredFrame.addWidget(new ZwTextField(m_window.frame_inventory_mc.featured_mc.header_tf,ZLocUtils.t("Dialogs","Duckpond_CompletedHeader")));
         this.m_featuredFrame.addWidget(new ZwTextField(m_window.frame_inventory_mc.featured_mc.subtext_tf,ZLocUtils.t("Dialogs","Duckpond_CompletedSubText")));
         for(i = 0; i < 5; i++)
         {
            this.m_items[i] = item = new ZwFrame(m_window.frame_inventory_mc.featured_mc["item" + i + "_mc"]);
            this.m_featuredFrame.addWidget(item);
            item.addWidget(new ZwTextField(item.element.generic_tf));
            item.registerEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler);
            item.registerEventListener(MouseEvent.CLICK,this.hideCallback);
            (item.getWidget(item.element.generic_tf) as ZwTextField).registerEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler);
            (item.getWidget(item.element.generic_tf) as ZwTextField).registerEventListener(MouseEvent.CLICK,this.hideCallback);
            item.element.remove_bt.visible = false;
         }
         this.m_ducks = this.m_building.capacity == 20 ? m_window.frame_inventory_mc.items20_mc : m_window.frame_inventory_mc.items40_mc;
         this.m_ducksFrame = new ZwFrame(this.m_ducks);
         this.m_featureFrame.addWidget(this.m_ducksFrame);
         this.m_rolloverFrame = new ZwFrame(m_window.frame_inventory_mc.rollover_mc);
         this.m_rolloverFrame.element.x = -this.m_rolloverFrame.element.width / 4;
         this.m_rolloverFrame.element.y = -this.m_rolloverFrame.element.height / 4;
         this.m_rolloverFrame.addWidget(new ZwTextField(m_window.frame_inventory_mc.rollover_mc.title_tf));
         this.m_rolloverFrame.addWidget(new FarmButton(m_window.frame_inventory_mc.rollover_mc.close_bt,this.closeRolloverCallback));
         this.m_featureButton = new FarmAnimatedTextButton(m_window.frame_inventory_mc.rollover_mc.feature_bt,ZLocUtils.t("Dialogs","DuckPond_CompletedShow"),this.showCallback);
         this.m_rolloverFrame.addWidget(this.m_featureButton);
         this.m_rolloverFrame.addWidget(new FarmAnimatedTextButton(m_window.frame_inventory_mc.rollover_mc.remove_bt,ZLocUtils.t("Dialogs","DuckPond_CompletedRemove"),this.removeCallback));
         this.m_featureFrame.x += 8;
      }
      
      private function initExpansionWidgets() : void
      {
         var expansionItems:Array = this.m_building.expand.getExpandSlotData();
         if(expansionItems)
         {
            this.m_expandFrame = new GenericExpandSlotFrame(m_window.frame_expand_mc,expansionItems,this,this.m_building,this.m_building.expand);
            addWidget(this.m_expandFrame);
            this.m_expandFrame.x += 8;
         }
      }
      
      override protected function release() : void
      {
         var objectPreviewFrame:ObjectPreviewFrame = null;
         super.release();
         this.m_building = null;
         this.m_featureFrame = null;
         this.m_infoFrame = null;
         this.m_featuredFrame = null;
         this.m_ducksFrame = null;
         this.m_rolloverFrame = null;
         this.m_featureButton = null;
         this.m_expandFrame = null;
         this.m_toggleManager = null;
         this.m_askButton = null;
         m_state = 0;
         this.m_defaultViewToggle = null;
         this.m_expandViewToggle = null;
         this.m_expansionViewButton = null;
         this.m_featureViewButton = null;
         while(this.m_objectPreviewFrames.length > 0)
         {
            objectPreviewFrame = this.m_objectPreviewFrames.shift();
            objectPreviewFrame = null;
         }
         while(this.m_itemPreviewFrames.length > 0)
         {
            objectPreviewFrame = this.m_itemPreviewFrames.shift();
            objectPreviewFrame = null;
         }
      }
      
      private function update() : void
      {
         if(DuckPondWindow.m_state == DuckPondWindow.VIEW_FEATURE)
         {
            this.updateDucks();
         }
      }
      
      private function updateDucks() : void
      {
         var i:int = 0;
         var objectPreviewFrame:ObjectPreviewFrame = null;
         var holder:MovieClip = null;
         var duck:Sprite = null;
         var count:int = 0;
         var farmItem:FarmItem = null;
         var key:String = null;
         var item:ZwFrame = null;
         var itemCode:String = null;
         while(this.m_objectPreviewFrames.length > 0)
         {
            objectPreviewFrame = this.m_objectPreviewFrames.shift();
            if(objectPreviewFrame)
            {
               duck = objectPreviewFrame.sprite;
               if(duck)
               {
                  duck.removeEventListener(MouseEvent.CLICK,this.duckMouseClickHandler);
               }
               this.m_ducksFrame.removeWidget(objectPreviewFrame);
               objectPreviewFrame = null;
            }
         }
         var j:int = 0;
         i = 1;
         for(key in this.m_building.contents)
         {
            count = this.m_building.contents[key] - this.countFeatureSlotItemsByCode(key);
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(key);
            for(j = 0; j < count; j++)
            {
               this.m_objectCodes[i] = key;
               holder = this.m_ducks["holder" + i + "_mc"];
               objectPreviewFrame = new ObjectPreviewFrame(holder,farmItem,null,[2],null,"swim_idle");
               this.m_objectPreviewFrames[i] = objectPreviewFrame;
               this.m_ducksFrame.addWidget(objectPreviewFrame);
               duck = objectPreviewFrame.sprite;
               if(duck)
               {
                  duck.buttonMode = true;
                  duck.mouseChildren = true;
                  duck.useHandCursor = true;
                  duck.addEventListener(MouseEvent.CLICK,this.duckMouseClickHandler);
               }
               i++;
            }
         }
         for(i = 0; i < 5; i++)
         {
            item = this.m_items[i];
            (item.getWidget(item.element.generic_tf) as ZwTextField).text = "";
            this.m_itemCodes[i] = "";
            objectPreviewFrame = this.m_itemPreviewFrames[i];
            if(objectPreviewFrame)
            {
               duck = objectPreviewFrame.sprite;
               if(duck)
               {
                  duck.removeEventListener(MouseEvent.CLICK,this.hideCallback);
               }
               item.removeWidget(objectPreviewFrame);
               objectPreviewFrame = null;
            }
            this.m_itemPreviewFrames[i] = null;
         }
         var items:Object = this.m_building.getFeaturedItems();
         for(key in items)
         {
            itemCode = items[key].itemCode;
            if(itemCode != null)
            {
               this.m_itemCodes[key] = itemCode;
               item = this.m_items[key];
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               objectPreviewFrame = new ObjectPreviewFrame(item.element.icon_mc,farmItem,null,[2]);
               duck = objectPreviewFrame.sprite;
               if(duck)
               {
                  duck.buttonMode = true;
                  duck.mouseChildren = true;
                  duck.useHandCursor = true;
                  duck.addEventListener(MouseEvent.CLICK,this.hideCallback);
               }
               this.m_itemPreviewFrames[key] = objectPreviewFrame;
               item.addWidget(objectPreviewFrame);
               (item.getWidget(item.element.generic_tf) as ZwTextField).text = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
            }
         }
      }
      
      private function howDoesThisWorkCallback(event:MouseEvent) : void
      {
         var msg:String = ZLocUtils.t("Dialogs","DuckPond_CompletedHowDoesThisWorkBody");
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false,"Okay",null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(dialog,false);
      }
      
      private function askForMoreCallback(event:MouseEvent) : void
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r1FlowCalled","duckpond_widhlist");
         Global.farmSocialNetwork.farmRedirect("gifts.php?template=wishlist&ref=duck",null);
      }
      
      private function hideCallback(event:MouseEvent) : void
      {
         event.stopPropagation();
         if(this.m_itemCodes[this.m_hideIndex] != "")
         {
            this.m_building.setFeaturedItem(Number(this.m_hideIndex),this.m_itemCodes[this.m_hideIndex],"",false,true);
            this.update();
         }
      }
      
      private function showCallback(event:MouseEvent) : void
      {
         var item:Object = event.target;
         event.stopPropagation();
         item.parent.parent.removeChild(this.m_rolloverFrame.element);
         this.m_rolloverFrame.element.visible = false;
         this.m_building.setFeaturedItem(this.m_featureIndex,this.m_featureCode,"",true,true);
         this.update();
      }
      
      private function removeCallback(event:MouseEvent) : void
      {
         var item:Object = event.target;
         event.stopPropagation();
         item.parent.parent.removeChild(this.m_rolloverFrame.element);
         this.m_rolloverFrame.element.visible = false;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_featureCode);
         var extraData:Object = new Object();
         extraData.isGift = false;
         extraData.repopGift = false;
         var realItemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_featureCode);
         if(realItemName != farmItem.name)
         {
            extraData.realItemName = realItemName;
         }
         farmItem.onUse(this.m_building.getId(),extraData);
         close();
      }
      
      private function itemMouseOverHandler(event:MouseEvent) : void
      {
         var item:Object = event.target;
         var mc:MovieClip = item as MovieClip;
         while(Boolean(mc) && mc.name.search("item") == -1)
         {
            mc = MovieClip(mc.parent);
         }
         if(Boolean(mc) && mc.name.search("item") != -1)
         {
            this.m_hideIndex = mc.name.replace("_mc","");
            this.m_hideIndex = this.m_hideIndex.replace("item","");
         }
      }
      
      private function countFeatureSlotItemsByCode(itemCode:String) : int
      {
         var count:int = 0;
         var featuredItems:Object = this.m_building.getFeaturedItems();
         for(var i:int = 0; i < 5; i++)
         {
            if(featuredItems.hasOwnProperty(i.toString()) && featuredItems[i.toString()] != null && featuredItems[i.toString()].itemCode == itemCode)
            {
               count++;
            }
         }
         return count;
      }
      
      private function duckMouseClickHandler(event:MouseEvent) : void
      {
         var objectPreviewFrame:ObjectPreviewFrame = null;
         var item:Object = event.target;
         if(item.parent.name.search("holder") != -1)
         {
            this.m_duckIndex = item.parent.name.replace("_mc","");
            this.m_duckIndex = this.m_duckIndex.replace("holder","");
            this.m_featureCode = this.m_objectCodes[this.m_duckIndex];
            this.m_ducks.setChildIndex(item.parent,this.m_ducks.numChildren - 1);
            this.m_rolloverFrame.element.scaleX = 1 / item.scaleX;
            this.m_rolloverFrame.element.scaleY = 1 / item.scaleY;
            this.m_featureIndex = 0;
            if(this.m_building.renderer is FeaturedRenderFManager)
            {
               this.m_featureIndex = (this.m_building.renderer as FeaturedRenderFManager).findEmptyFeatureSlot();
            }
            if(this.m_featureIndex == -1)
            {
               this.m_featureButton.enabled = false;
            }
            else
            {
               this.m_featureButton.enabled = true;
            }
            objectPreviewFrame = this.m_objectPreviewFrames[this.m_duckIndex];
            (this.m_rolloverFrame.getWidget(m_window.frame_inventory_mc.rollover_mc.title_tf) as ZwTextField).text = ZLocUtils.tk_pk_asTitle(objectPreviewFrame.farmItem.friendlyName);
            item.addChild(this.m_rolloverFrame.element);
            this.m_rolloverFrame.element.visible = true;
         }
      }
      
      private function closeRolloverCallback(event:MouseEvent) : void
      {
         event.stopPropagation();
         this.m_rolloverFrame.element.parent.removeChild(this.m_rolloverFrame.element);
         this.m_rolloverFrame.element.visible = false;
      }
   }
}

