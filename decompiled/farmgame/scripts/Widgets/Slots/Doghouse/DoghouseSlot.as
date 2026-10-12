package Widgets.Slots.Doghouse
{
   import Classes.DoghouseAnimal;
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.WidgetTooltip;
   import Widgets.Windows.Doghouse.DoghouseContentsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   
   public class DoghouseSlot extends ZwSlotFrame
   {
      
      private var m_farmItem:FarmItem;
      
      private var m_itemMetadataHash:String;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame;
      
      private var m_animalSprite:Sprite;
      
      private var m_parentWindow:DoghouseContentsWindow;
      
      private var m_hitWidget:ZwWidget;
      
      private var m_counter:FarmTextField;
      
      private var m_nameFrame:DoghouseSlotNameFrame;
      
      private var m_actionTooltip:WidgetTooltip;
      
      private var m_actionTooltipFrame:DoghouseSlotTooltipFrame;
      
      public function DoghouseSlot(element:DisplayObject)
      {
         super(element);
         if(m_element.hit_bt)
         {
            this.m_hitWidget = addWidget(new ZwWidget(m_element.hit_bt)) as ZwWidget;
            (this.m_hitWidget.element as SimpleButton).useHandCursor = false;
         }
         if(m_element.counter_tf)
         {
            this.m_counter = addWidget(new FarmTextField(m_element.counter_tf)) as FarmTextField;
         }
         this.m_nameFrame = addWidget(new DoghouseSlotNameFrame(m_element.sign_mc)) as DoghouseSlotNameFrame;
         this.m_actionTooltipFrame = new DoghouseSlotTooltipFrame(m_element.tooltips_mc,this) as DoghouseSlotTooltipFrame;
         this.m_actionTooltip = new WidgetTooltip(this.m_actionTooltipFrame);
         this.m_actionTooltip.fixed = true;
         this.m_actionTooltip.interactive = true;
      }
      
      override public function release() : void
      {
         this.m_farmItem = null;
         this.m_itemMetadataHash = null;
         this.m_objectPreviewFrame = null;
         this.m_parentWindow = null;
         this.m_animalSprite = null;
         this.m_hitWidget = null;
         this.m_counter = null;
         this.m_nameFrame = null;
         this.m_actionTooltip = null;
         this.m_actionTooltipFrame = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var offset:Point = null;
         super.populate(data);
         this.m_parentWindow = getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow;
         this.m_farmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         if(Boolean(data["metadata"]) && Boolean(data["metadata"]["key"]))
         {
            this.m_itemMetadataHash = data["metadata"]["key"];
         }
         if(this.m_objectPreviewFrame != null)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_farmItem.displayLoader.canUseAnimation)
         {
            this.m_farmItem.displayLoader.useAnimation = true;
         }
         if(m_element.hasOwnProperty("itemFeatured_mc"))
         {
            offset = new Point(0,40);
            if(data.hasOwnProperty("offsetX"))
            {
               offset.x = data.offsetX;
            }
            if(data.hasOwnProperty("offsetY"))
            {
               offset.y = data.offsetY;
            }
            this.m_objectPreviewFrame = addWidget(new ObjectPreviewFrame(m_element.itemFeatured_mc,this.m_farmItem,null,[3],[110],DoghouseAnimal.STATE_FRONT_SITTING,"",null,offset)) as ObjectPreviewFrame;
            (this.m_objectPreviewFrame.element as MovieClip).filters = [];
            this.m_animalSprite = this.m_objectPreviewFrame.sprite;
            if(Boolean(this.m_animalSprite) && data.quantity > 0)
            {
               this.m_animalSprite.buttonMode = true;
               this.m_animalSprite.mouseChildren = true;
               this.m_animalSprite.useHandCursor = true;
               this.m_animalSprite.addEventListener(MouseEvent.CLICK,this.onRemoveButtonClick);
            }
            if(data.quantity <= 0)
            {
               this.makeTransparent(this.m_objectPreviewFrame);
            }
         }
         if(Boolean(this.m_counter) && data.quantity > 1)
         {
            this.m_counter.text = ZLocUtils.t("Dialogs","GiftAmount",{"quantity":data.quantity});
            this.m_counter.visible = true;
         }
         this.m_nameFrame.populate(data);
         this.m_nameFrame.visible = true;
         if(this.m_hitWidget)
         {
            this.m_hitWidget.visible = true;
         }
         this.m_actionTooltipFrame.populate(data);
         if(data.isNextExpansion)
         {
            if(tooltip == this.m_actionTooltip)
            {
               detachTooltip();
            }
            this.m_actionTooltipFrame.visible = true;
         }
         else if(tooltip != this.m_actionTooltip)
         {
            attachTooltip(this.m_actionTooltip);
         }
      }
      
      private function makeTransparent(previewFrame:ObjectPreviewFrame) : void
      {
         var alphaFilter:ColorMatrixFilter = new ColorMatrixFilter([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.6,0]);
         (previewFrame.element as MovieClip).filters = [alphaFilter];
      }
      
      public function get mapResource() : MapResource
      {
         return this.m_objectPreviewFrame ? this.m_objectPreviewFrame.mapResource : null;
      }
      
      public function onBuyButtonClick(event:MouseEvent) : void
      {
         this.m_parentWindow.building.expand.beginCompleteExpansionFlow(FeatureBuilding.ACTION_SOURCE_LOOK_INSIDE_UI);
         this.m_parentWindow.close();
      }
      
      public function onFeatureButtonClick(event:MouseEvent) : void
      {
         this.m_parentWindow.building.setFeaturedItem(0,this.m_farmItem.code,this.m_itemMetadataHash,true,true);
         this.m_parentWindow.refresh();
      }
      
      public function onRemoveButtonClick(event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog",this.m_parentWindow.building.getItemName(),"remove",this.m_farmItem.name);
         if(this.m_animalSprite)
         {
            this.m_animalSprite.removeEventListener(MouseEvent.CLICK,this.onRemoveButtonClick);
            this.m_animalSprite = null;
         }
         var extraData:Object = new Object();
         extraData.isGift = false;
         extraData.repopGift = false;
         extraData.itemMetadata = this.m_parentWindow.building.getStorageMetaDataForHash(this.m_itemMetadataHash);
         this.m_farmItem.onUse(this.m_parentWindow.building.getId(),extraData);
         this.m_parentWindow.close();
      }
   }
}

