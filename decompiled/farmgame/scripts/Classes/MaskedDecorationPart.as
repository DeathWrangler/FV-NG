package Classes
{
   import Classes.util.DisplayObjectUtils;
   import Engine.Classes.PositionedObject;
   import Engine.Helpers.Vector3;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   
   public class MaskedDecorationPart extends RotateableDecoration
   {
      
      protected static const EXPLODE_PARTS:Boolean = false;
      
      protected var m_maskedMain:MaskedDecoration;
      
      protected var m_transparencyMask:DisplayObject;
      
      private var m_partNumber:int;
      
      private var m_backPart:Boolean;
      
      private var m_positionDelta:Vector3;
      
      private var m_depthPosition:Vector3;
      
      private var m_alternateImageSuffix:String = null;
      
      public function MaskedDecorationPart(itemName:String = null, partNumber:int = 1, lastPart:Boolean = false)
      {
         super(itemName);
         this.m_partNumber = partNumber;
         this.m_positionDelta = m_item.getPartDisplacement(this.m_partNumber);
         m_size = m_item.getPartSize(this.m_partNumber);
         this.m_backPart = lastPart;
         this.m_depthPosition = new Vector3();
      }
      
      public function setImageSuffix(imageSuffix:String) : void
      {
         this.m_alternateImageSuffix = imageSuffix;
      }
      
      override protected function updateToolTipText() : void
      {
         if(this.m_backPart)
         {
            super.updateToolTipText();
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         switch(state)
         {
            case STATE_HORIZONTAL:
               imageName = "horizontal";
               break;
            case STATE_VERTICAL:
               imageName = "vertical";
               break;
            default:
               imageName = super.getCurrentImageName();
         }
         return imageName;
      }
      
      override public function postProcessImageName(name:String) : String
      {
         var imageName:String = super.postProcessImageName(name);
         if(this.m_alternateImageSuffix != null && imageName != null)
         {
            imageName += this.m_alternateImageSuffix;
         }
         return imageName;
      }
      
      override public function isCollidable() : Boolean
      {
         return false;
      }
      
      public function setMain(main:MaskedDecoration) : void
      {
         this.m_maskedMain = main;
         m_position = this.m_maskedMain.getPosition().clone();
      }
      
      override public function isPickable() : Boolean
      {
         return this.alpha != 0;
      }
      
      override public function getReference() : PositionedObject
      {
         return this.m_maskedMain;
      }
      
      override public function setSize(newSizeX:Number, newSizeY:Number, newSizeZ:Number = 0) : void
      {
         m_transformDirty = true;
      }
      
      override public function getDepthPosition() : Vector3
      {
         var position:Vector3 = this.m_maskedMain.getDepthPosition();
         position.x += this.m_positionDelta.x;
         position.y += this.m_positionDelta.y;
         position.z += this.m_positionDelta.z;
         return position;
      }
      
      override public function getDepthPositionNoClone() : Vector3
      {
         var position:Vector3 = this.m_maskedMain.getDepthPositionNoClone();
         this.m_depthPosition.x = position.x + this.m_positionDelta.x;
         this.m_depthPosition.y = position.y + this.m_positionDelta.y;
         this.m_depthPosition.z = position.z + this.m_positionDelta.z;
         return this.m_depthPosition;
      }
      
      override protected function calculateDepthIndex() : void
      {
         var realPos:Vector3 = getNearestTilePosition();
         var endPos:Vector3 = getFurthestTilePosition();
         var midX:Number = (realPos.x + endPos.x) / 2;
         m_depthIndex = (midX + (realPos.y + endPos.y) / 2) * 1000 + midX;
      }
      
      override public function getEndPosition() : Vector3
      {
         return m_position.add(m_size).add(this.m_positionDelta);
      }
      
      override public function setState(value:String) : void
      {
         var tempPos:Vector3 = null;
         var tempSize:Vector3 = null;
         this.m_transparencyMask = null;
         switch(value)
         {
            case STATE_VERTICAL:
               tempPos = m_item.getPartDisplacement(this.m_partNumber);
               tempSize = m_item.getPartSize(this.m_partNumber);
               this.m_positionDelta.x = tempPos.y;
               this.m_positionDelta.y = tempPos.x;
               m_size.x = tempSize.y;
               m_size.y = tempSize.x;
               value = STATE_VERTICAL;
               break;
            case STATE_HORIZONTAL:
            default:
               this.m_positionDelta = m_item.getPartDisplacement(this.m_partNumber);
               m_size = m_item.getPartSize(this.m_partNumber);
               value = STATE_HORIZONTAL;
         }
         super.setState(value);
      }
      
      override protected function replaceContentWithPlaceholder() : void
      {
         if(this.m_backPart)
         {
            super.replaceContentWithPlaceholder();
         }
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         var maskedContent:DisplayObject = this.getMaskedDisplayObject(newContent);
         if(maskedContent != null)
         {
            newContent = maskedContent;
         }
         super.replaceContent(newContent,shouldRedrawMask);
         if(EXPLODE_PARTS && Config.DEBUG_MODE)
         {
            m_content.y += this.m_partNumber * 200;
         }
      }
      
      override public function conditionallyReattach(force:Boolean = false) : void
      {
         if(isAttached() || force)
         {
            super.conditionallyReattach(force);
         }
      }
      
      protected function getMaskedDisplayObject(newContent:DisplayObject) : DisplayObject
      {
         var maskedImageName:String = null;
         var result:DisplayObject = null;
         var imageName:String = null;
         var newObject:Object = null;
         switch(state)
         {
            case STATE_VERTICAL:
               maskedImageName = "vertical_masked_image_" + String(this.m_partNumber + 1);
               break;
            case STATE_HORIZONTAL:
            default:
               maskedImageName = "horizontal_masked_image_" + String(this.m_partNumber + 1);
         }
         var itemImage:ItemImage = m_item.getCachedImage(maskedImageName);
         if(itemImage != null)
         {
            result = itemImage.image as DisplayObject;
         }
         if(result == null)
         {
            if(!this.m_backPart && this.m_transparencyMask == null && m_image != null)
            {
               switch(state)
               {
                  case STATE_VERTICAL:
                     imageName = "vertical_mask_part_" + String(this.m_partNumber + 1);
                     break;
                  case STATE_HORIZONTAL:
                  default:
                     imageName = "horizontal_mask_part_" + String(this.m_partNumber + 1);
               }
               itemImage = m_item.getCachedImage(imageName);
               if(itemImage != null)
               {
                  this.m_transparencyMask = itemImage.image as DisplayObject;
               }
            }
            if(this.m_transparencyMask != null && !(this.m_transparencyMask is Loader))
            {
               result = DisplayObjectUtils.generateMaskedBitmap(newContent,this.m_transparencyMask);
               if(result is Bitmap)
               {
                  newObject = new Object();
                  newObject.name = maskedImageName;
                  newObject.url = null;
                  newObject.bitmapData = (result as Bitmap).bitmapData;
                  newObject.lowResBitmapData = null;
                  newObject.loader = null;
                  newObject.loaded = true;
                  newObject.loadClass = null;
                  newObject.boxWidth = m_itemImage.boxWidth;
                  m_item.addImageToCache(newObject);
               }
            }
         }
         return result;
      }
   }
}

