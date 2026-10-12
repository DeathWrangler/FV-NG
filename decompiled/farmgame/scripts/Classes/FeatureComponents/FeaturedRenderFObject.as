package Classes.FeatureComponents
{
   import Classes.CompositeMapResource;
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.MapResourceLayer;
   import Classes.Terrain.TerrainUtil;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class FeaturedRenderFObject extends CompositeMapResource
   {
      
      protected static const ITEM_Y_OFFSET:Number = 18;
      
      protected var m_itemImageName:String = "";
      
      protected var m_itemScale:Number = 1;
      
      protected var m_building:FeatureBuilding = null;
      
      protected var m_displayObjectWrapper:Sprite = null;
      
      public function FeaturedRenderFObject(itemName:String, building:FeatureBuilding, metadata:String = "")
      {
         super(itemName);
         this.m_displayObjectWrapper = new Sprite();
         this.m_building = building;
      }
      
      public function set itemSwf(value:String) : void
      {
         this.m_itemImageName = value;
      }
      
      public function set itemScale(value:Number) : void
      {
         this.m_itemScale = value;
      }
      
      public function get itemDisplayWrapper() : Sprite
      {
         return this.m_displayObjectWrapper;
      }
      
      override protected function findTerrainName() : String
      {
         var result:String = null;
         if(this.getOuter() != null && this.m_building != null)
         {
            result = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(TerrainUtil.getTerrainCodesForItemInstance(this.m_building));
         }
         return result;
      }
      
      override public function createDisplayObject() : DisplayObject
      {
         super.createDisplayObject();
         this.m_displayObjectWrapper.x = 0;
         this.m_displayObjectWrapper.y = 0;
         this.m_displayObjectWrapper.addChild(this.getDisplayObject());
         this.updateDisplayObjectTransform();
         return m_displayObject;
      }
      
      override public function getCurrentImageName() : String
      {
         var objClass:Class = null;
         var itemInstance:MapResource = null;
         var result:String = null;
         if(this.m_itemImageName != "" && Boolean(m_item))
         {
            if(!m_item.displayLoader.hasImageNameDefined(this.m_itemImageName))
            {
               objClass = m_item.getMapResourceClass();
               itemInstance = new objClass(m_item.name);
               this.m_itemImageName = itemInstance.getCurrentImageName();
            }
            result = this.m_itemImageName;
         }
         return result;
      }
      
      private function calculateScale() : Number
      {
         var boxWidth:Number = NaN;
         var contentWidth:Number = NaN;
         var imageScaleFactor:Number = NaN;
         var itemScale:Number = NaN;
         var result:Number = 1;
         if(Boolean(m_itemImage) && Boolean(m_content) && Boolean(this.m_building))
         {
            boxWidth = m_itemImage.boxWidth;
            contentWidth = m_content.width;
            imageScaleFactor = getImageScaleFactor();
            itemScale = this.m_building.getDisplayObject().scaleX;
            if(contentWidth > 0 && itemScale > 0)
            {
               result = boxWidth / contentWidth * (imageScaleFactor / itemScale);
            }
         }
         return result * this.m_itemScale;
      }
      
      override public function updateDisplayObjectTransform() : void
      {
         var contentScale:Number = NaN;
         var xOffset:int = 0;
         var yOffset:int = 0;
         var layer:MapResourceLayer = null;
         if(m_content)
         {
            contentScale = this.calculateScale();
            xOffset = -m_content.width * contentScale;
            yOffset = -m_content.height * contentScale;
            this.m_displayObjectWrapper.scaleX = this.m_displayObjectWrapper.scaleY = contentScale;
            this.m_displayObjectWrapper.x = xOffset / 2;
            this.m_displayObjectWrapper.y = yOffset + ITEM_Y_OFFSET;
            for each(layer in m_layers)
            {
               layer.updateDisplayObjectTransform();
            }
         }
      }
      
      private function drawBoundingBox(content:DisplayObject) : void
      {
         if(content)
         {
            this.m_displayObjectWrapper.graphics.clear();
            this.m_displayObjectWrapper.graphics.lineStyle(2);
            this.m_displayObjectWrapper.graphics.drawRect(0,0,content.width,content.height);
         }
      }
      
      override public function isWithinViewport() : Boolean
      {
         return this.m_building.isWithinViewport();
      }
   }
}

