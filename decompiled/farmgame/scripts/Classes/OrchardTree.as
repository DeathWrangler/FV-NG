package Classes
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class OrchardTree extends MapResource
   {
      
      protected static const STATE_BARE:String = "bare";
      
      protected static const STATE_RIPE:String = "ripe";
      
      private static const TREE_Y_OFFSET:Number = 18;
      
      private var m_orchard:OrchardBuilding;
      
      private var m_displayObjectWrapper:Sprite;
      
      public function OrchardTree(itemName:String, orchard:OrchardBuilding)
      {
         super(itemName);
         this.m_displayObjectWrapper = new Sprite();
         this.m_orchard = orchard;
         setState(this.m_orchard.getTreeGrowState());
      }
      
      public function get treeDisplayWrapper() : Sprite
      {
         return this.m_displayObjectWrapper;
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
         var imageName:String = null;
         switch(state)
         {
            case STATE_BARE:
               imageName = "bare";
               break;
            case STATE_RIPE:
               imageName = "mature";
         }
         return imageName;
      }
      
      private function calculateScale() : Number
      {
         var boxWidth:Number = NaN;
         var contentWidth:Number = NaN;
         var imageScaleFactor:Number = NaN;
         var orchardScale:Number = NaN;
         var result:Number = 1;
         if(Boolean(m_itemImage) && Boolean(m_content) && Boolean(this.m_orchard))
         {
            boxWidth = m_itemImage.boxWidth;
            contentWidth = m_content.width;
            imageScaleFactor = getImageScaleFactor();
            orchardScale = this.m_orchard.getDisplayObject().scaleX;
            if(contentWidth > 0 && orchardScale > 0)
            {
               result = boxWidth / contentWidth * (imageScaleFactor / orchardScale);
            }
         }
         return result;
      }
      
      override public function updateDisplayObjectTransform() : void
      {
         var contentScale:Number = NaN;
         var xOffset:int = 0;
         var yOffset:int = 0;
         if(m_content)
         {
            contentScale = this.calculateScale();
            xOffset = -m_content.width * contentScale;
            yOffset = -m_content.height * contentScale;
            this.m_displayObjectWrapper.scaleX = this.m_displayObjectWrapper.scaleY = contentScale;
            this.m_displayObjectWrapper.x = xOffset / 2;
            this.m_displayObjectWrapper.y = yOffset + TREE_Y_OFFSET;
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
         return this.m_orchard.isWithinViewport();
      }
   }
}

