package Classes
{
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCResourceDelegate;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Engine.Managers.ErrorManager;
   import Managers.UGCDecoManager;
   import flash.events.MouseEvent;
   
   public class UGCDecoration extends Decoration implements IUGCMapResource
   {
      
      private static const OPEN_UI:String = "OPEN_UI";
      
      private const SHARE_FEED_ICON_SCALE:Number = 0.7;
      
      private var m_ugcDelegate:UGCResourceDelegate;
      
      private var m_ugcUuid:String;
      
      public function UGCDecoration(itemName:String, ugcUuid:String = null)
      {
         super(itemName);
         this.m_ugcUuid = ugcUuid;
         this.m_ugcDelegate = new UGCResourceDelegate(this,this.m_ugcUuid);
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
            ErrorManager.addError("Invalid UGCDecoration#loadObject, uuid was not found");
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
         return this.m_ugcDelegate.totalCash == 0 && this.m_ugcDelegate.ugcItemState.hasUUID();
      }
      
      override protected function getMenuItems() : Array
      {
         var items:Array = super.getMenuItems();
         items.unshift({
            "label":ZLocUtils.t("Dialogs","UGCDeco_Context_Open"),
            "action":OPEN_UI
         });
         return items;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var farmItem:FarmItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(item.action == OPEN_UI)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(m_itemName);
               UGCDecoManager.instance.showUGCDecoDialog(farmItem.gameSettingsFeatureName,farmItem as IUGCItem);
            }
            else
            {
               super.onMenuClick(event);
            }
         }
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         var image:ItemImage = null;
         var currentImageName:String = this.getCurrentImageName();
         if(currentImageName != null && Boolean(m_item))
         {
            currentImageName = postProcessImageName(currentImageName);
            image = m_item.getCachedImage(currentImageName,true);
         }
         else
         {
            image = getCurrentImageFromState();
         }
         return image;
      }
   }
}

