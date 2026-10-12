package Classes
{
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCItemLayer;
   import Classes.UGC.UGCResourceDelegate;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.UI;
   import Engine.Events.LoaderEvent;
   import Engine.Managers.ErrorManager;
   import Widgets.Windows.UGCFishItemEditorWindow;
   import Widgets.Windows.UGCItemEditorWindow;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class UGCAnimal extends Animal implements IUGCMapResource
   {
      
      protected var m_ugcDelegate:UGCResourceDelegate;
      
      protected var m_ugcUuid:String;
      
      private const UGC_ANIMAL_CUSTOMIZE:String = "dreamHorseCustomize";
      
      private const UGC_ANIMAL_CREATE_NEW:String = "dreamHorseCreateNew";
      
      private const UGC_FISH_CUSTOMIZE:String = "dreamFishCustomize";
      
      private const UGC_FISH_CREATE_NEW:String = "dreamFishCreateNew";
      
      private const UGC_DRAGON_BREEDING:String = "dragonbreeding";
      
      private const UGC_FISH:String = "fish";
      
      protected var m_loadComplete:Dictionary;
      
      public function UGCAnimal(itemName:String, ugcUuid:String = null)
      {
         super(itemName);
         this.m_ugcUuid = ugcUuid;
         this.m_ugcDelegate = new UGCResourceDelegate(this,this.m_ugcUuid);
         this.m_loadComplete = new Dictionary();
         this.m_loadComplete[Global.farmGameSettingsManager.getFarmItemCodeByName(itemName)] = true;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data["ugcItemUUID"])
         {
            this.ugcUuid = data["ugcItemUUID"] as String;
         }
         else
         {
            ErrorManager.addError("Invalid UGCAnimal#loadObject, uuid was not found");
         }
      }
      
      override public function attach() : void
      {
         var wasAttached:Boolean = m_attachPosition != null;
         super.attach();
         if(isAttached() && !wasAttached)
         {
            this.m_ugcDelegate.refresh();
         }
      }
      
      public function get ugcDelegate() : UGCResourceDelegate
      {
         return this.m_ugcDelegate;
      }
      
      public function get ugcUuid() : String
      {
         return this.m_ugcUuid;
      }
      
      public function set ugcUuid(value:String) : void
      {
         if(this.m_ugcUuid != value)
         {
            this.m_ugcUuid = value;
            if(this.m_ugcDelegate == null)
            {
               this.m_ugcDelegate = new UGCResourceDelegate(this,this.m_ugcUuid);
            }
            else
            {
               this.m_ugcDelegate.setInitialUuid(this.m_ugcUuid);
               this.m_ugcDelegate.loadUGCItemState(this.m_ugcUuid);
            }
         }
      }
      
      override public function getInventoryCode() : String
      {
         return this.m_ugcDelegate.getInventoryCode(super.getInventoryCode());
      }
      
      override public function getCurrentImageName() : String
      {
         var result:String = null;
         if(this.m_ugcDelegate != null)
         {
            result = this.m_ugcDelegate.getCurrentImageName();
         }
         else
         {
            result = super.getCurrentImageName();
         }
         return result;
      }
      
      override public function getMetadata() : Object
      {
         return this.m_ugcUuid;
      }
      
      override public function setMetadata(value:Object) : void
      {
         this.ugcUuid = value as String;
      }
      
      override public function getMetadataKey() : String
      {
         return this.getInventoryCode();
      }
      
      override public function packStoreItemMetaData() : Object
      {
         var result:Object = null;
         if(this.m_ugcUuid)
         {
            result = {"type":this.m_ugcUuid};
         }
         return result;
      }
      
      override protected function initializeFilters() : void
      {
         super.initializeFilters();
         if(this.m_ugcDelegate != null)
         {
            this.m_ugcDelegate.initializeFilters(m_content);
         }
      }
      
      override protected function getBaseBitmapFilters() : Array
      {
         var result:Array = [];
         if(this.m_ugcDelegate != null)
         {
            result = this.m_ugcDelegate.getBaseFilters();
         }
         return result;
      }
      
      public function get isCustomizable() : Boolean
      {
         return this.m_ugcDelegate.totalCash == 0 && this.m_ugcDelegate.ugcItemState && this.m_ugcDelegate.ugcItemState.hasUUID() && this.isEmpty(this.m_ugcDelegate.ugcItemState.layers);
      }
      
      private function isEmpty(obj:Object) : Boolean
      {
         var s:Object = null;
         var flag:Boolean = true;
         var _loc4_:int = 0;
         var _loc5_:* = obj;
         for(s in _loc5_)
         {
            flag = false;
         }
         return flag;
      }
      
      override protected function generateMenuItems() : void
      {
         var createLabel:String = null;
         if(m_item.keyword == this.UGC_FISH)
         {
            if(this.isCustomizable)
            {
               m_menuItems = [];
               m_menuItems.push({
                  "label":ZLocUtils.t("Dialogs","ugcItemCustomize"),
                  "action":this.UGC_FISH_CUSTOMIZE
               });
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Move"),
                  "action":MOVE_OBJECT
               });
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Sell"),
                  "action":SELL_OBJECT
               });
            }
            else
            {
               super.generateMenuItems();
               m_menuItems.unshift({
                  "label":ZLocUtils.t("Dialogs","ugc_fish1Create"),
                  "action":this.UGC_FISH_CREATE_NEW
               });
            }
         }
         else
         {
            super.generateMenuItems();
            if(m_item.keyword != this.UGC_DRAGON_BREEDING)
            {
               if(this.isCustomizable)
               {
                  m_menuItems.unshift({
                     "label":ZLocUtils.t("Dialogs","ugcItemCustomize"),
                     "action":this.UGC_ANIMAL_CUSTOMIZE
                  });
               }
               createLabel = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",getItemName() + "Create"),new ZLocFailoverEntry("Dialogs","ugcItemCreate")]);
               m_menuItems.unshift({
                  "label":createLabel,
                  "action":this.UGC_ANIMAL_CREATE_NEW
               });
            }
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var ugcItemConstructWindow:UGCItemEditorWindow = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(m_wanderingObject != this)
            {
               generateWanderTime();
               ugcItemConstructWindow = null;
               switch(item.action)
               {
                  case this.UGC_ANIMAL_CUSTOMIZE:
                     ugcItemConstructWindow = new UGCItemEditorWindow(this.getItem() as IUGCItem,this);
                     UI.displayPopup(ugcItemConstructWindow,false);
                     break;
                  case this.UGC_ANIMAL_CREATE_NEW:
                     ugcItemConstructWindow = new UGCItemEditorWindow(this.getItem() as IUGCItem);
                     UI.displayPopup(ugcItemConstructWindow,false);
                     break;
                  case this.UGC_FISH_CUSTOMIZE:
                     UI.displayPopup(new UGCFishItemEditorWindow(this.getItem() as IUGCItem,this),false);
                     break;
                  case this.UGC_FISH_CREATE_NEW:
                     UI.displayPopup(new UGCFishItemEditorWindow(this.getItem() as IUGCItem),false);
                     break;
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
      
      public function allLayersLoaded() : Boolean
      {
         var resourceLoaded:Boolean = false;
         var result:Boolean = true;
         if(!this.m_loadComplete)
         {
            result = false;
         }
         else
         {
            for each(resourceLoaded in this.m_loadComplete)
            {
               if(!resourceLoaded)
               {
                  result = false;
               }
            }
         }
         return result;
      }
      
      override protected function replaceContentWithPlaceholder() : void
      {
         var puffAnimation:DisplayObject = new EmbeddedArt.loadingPlaceholderAnimation() as DisplayObject;
         replaceContent(puffAnimation);
      }
      
      override protected function shouldDisplayPlaceholder() : Boolean
      {
         var result:Boolean = !this.allLayersLoaded();
         return result && m_content is Bitmap;
      }
      
      override protected function onImageLoaded(event:Event) : void
      {
         event.target.removeEventListener(LoaderEvent.LOADED,this.onImageLoaded);
         conditionallyRedraw(true);
         if(m_imageLoadedCallback != null)
         {
            m_imageLoadedCallback();
            m_imageLoadedCallback = null;
         }
      }
      
      protected function trackCompletedParts(itemCode:String) : void
      {
         if(!this.m_loadComplete[itemCode])
         {
            this.m_loadComplete[itemCode] = true;
            if(this.allLayersLoaded())
            {
               this.m_ugcDelegate.refresh();
            }
         }
      }
      
      override public function addLayer(layer:MapResourceLayer) : void
      {
         if(Boolean(layer) && layer.getDisplayObject() == null)
         {
            if(!this.m_loadComplete)
            {
               this.m_loadComplete = new Dictionary();
            }
            if(layer is UGCItemLayer)
            {
               if(Boolean((layer as UGCItemLayer).ugcItemState) && Boolean((layer as UGCItemLayer).ugcItemState.item) && !(layer as UGCItemLayer).ugcItemState.item.displayLoader.getImageStatusByIndex(0))
               {
                  this.m_loadComplete[layer.getResourceItemCode()] = false;
               }
            }
            layer.setImageLoadedCallback(this.trackCompletedParts);
         }
         super.addLayer(layer);
      }
      
      override public function stop() : void
      {
         super.pause();
      }
      
      override public function onFinishPlace(result:Object = null) : void
      {
         super.onFinishPlace(result);
         if(result.uuid)
         {
            this.ugcUuid = result.uuid;
         }
      }
      
      override protected function setArrowPosition() : void
      {
         if(Boolean(m_arrow) && Boolean(m_displayObject))
         {
            m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            m_arrow.y = -37;
            m_arrow.x = 50;
         }
      }
   }
}

