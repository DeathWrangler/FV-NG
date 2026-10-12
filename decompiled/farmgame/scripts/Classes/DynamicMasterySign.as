package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Managers.FarmGameSettingsManager;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   
   public class DynamicMasterySign extends Decoration
   {
      
      public static const ITEM_NAME_PREFIX:String = "master";
      
      public static const ITEM_IMAGE_KEY:String = "masteredItem";
      
      public static const IMAGE_INSTANCE_KEY:String = "static";
      
      public static const HOLDER_KEY:String = "holder_mc";
      
      public static const SKEW_ANGLE_Y:Number = -0.47123889803846897;
      
      public static const ITEM_STROKE_COLOR:Number = 10654327;
      
      public static const ITEM_STROKE_BLUR:Number = 4;
      
      public static const ITEM_STROKE_STRENGTH:Number = 16;
      
      private var m_skewedBitmap:Bitmap;
      
      private var m_addImageToSignOnLoad:Boolean = false;
      
      public function DynamicMasterySign(itemName:String = null)
      {
         super(itemName);
         var signImageUrl:String = this.m_item.getImageByName(ITEM_IMAGE_KEY);
         if(signImageUrl == null && Global.farmGameSettingsManager.itemsXMLParsingComplete)
         {
            ErrorManager.addError("DynamicMasterySign missing mastered item for:" + itemName);
         }
         LoadingManager.load(signImageUrl,this.onIconLoadComplete);
      }
      
      public static function getDefaultTooltip(item:FarmItem) : String
      {
         var locKey:String = item.friendlyName;
         var tooltip:String = ZLocUtils.tk_pk_asTitle(locKey);
         var masteryPrefix:String = "Items:" + ITEM_NAME_PREFIX;
         if(tooltip == "")
         {
            tooltip = ZLocUtils.tk_pk_asTitlePlural("Items:" + item.className + "_friendlyName");
         }
         var notes:String = DynamicMasterySign.tooltipNotes(item);
         if(Boolean(notes) && notes != "")
         {
            tooltip += "\n" + notes;
         }
         return tooltip;
      }
      
      public static function tooltipNotes(item:FarmItem) : String
      {
         var masteredItemCode:String = null;
         var parentItem:FarmItem = null;
         var parentItemName:String = null;
         var notes:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            masteredItemCode = item.getStringFromDataSource("masteredItemCode");
         }
         else if(Boolean(item.xml) && item.xml.hasOwnProperty("masteredItemCode"))
         {
            masteredItemCode = item.xml.masteredItemCode;
         }
         if(ZLocUtils.hasString("Items",item.name + "_notes"))
         {
            notes = ZLocUtils.t("Items",item.name + "_notes");
         }
         else if(Boolean(masteredItemCode) && Global.farmGameSettingsManager.getFarmItemByCode(masteredItemCode) != null)
         {
            parentItem = Global.farmGameSettingsManager.getFarmItemByCode(masteredItemCode);
            notes = ZLocUtils.tk_pk_asTitlePlural(parentItem.friendlyName);
         }
         else if(item.name.indexOf(DynamicMasterySign.ITEM_NAME_PREFIX) > -1)
         {
            parentItemName = item.name.substring(ITEM_NAME_PREFIX.length,item.name.length);
            notes = ZLocUtils.tk_pk_asTitlePlural("Items:" + parentItemName + "_friendlyName");
         }
         return notes;
      }
      
      private function onIconLoadComplete(event:Event) : void
      {
         var displayObject:DisplayObject = event.target.content as DisplayObject;
         this.m_skewedBitmap = FarmGameUtil.getSkewedBitmap(displayObject,0,SKEW_ANGLE_Y);
         this.m_skewedBitmap.x = this.m_skewedBitmap.width * -0.5;
         this.m_skewedBitmap.y = this.m_skewedBitmap.height * -0.5;
         this.m_skewedBitmap.filters = [new GlowFilter(ITEM_STROKE_COLOR,1,ITEM_STROKE_BLUR,ITEM_STROKE_BLUR,ITEM_STROKE_STRENGTH)];
         this.addToSign();
      }
      
      override public function getCurrentImageName() : String
      {
         return IMAGE_INSTANCE_KEY;
      }
      
      override protected function replaceContentWithBitmap(shouldRedrawMask:Boolean = false) : void
      {
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
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,true);
         if(null != this.m_skewedBitmap)
         {
            this.addToSign();
         }
      }
      
      private function addToSign() : void
      {
         var holder_mc:MovieClip = null;
         if(this.m_content.hasOwnProperty(HOLDER_KEY))
         {
            holder_mc = this.m_content[HOLDER_KEY];
            if(null != holder_mc)
            {
               holder_mc.addChild(this.m_skewedBitmap);
            }
         }
      }
      
      override public function getItemFriendlyName() : String
      {
         var friendlyName:String = m_item.friendlyName;
         if(!ZLocUtils.hasString(friendlyName))
         {
            friendlyName = "Items:" + m_item.className + "_friendlyName";
         }
         return friendlyName;
      }
      
      override protected function get defaultTooltip() : String
      {
         return DynamicMasterySign.getDefaultTooltip(this.m_item);
      }
   }
}

