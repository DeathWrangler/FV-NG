package Classes
{
   import Engine.Classes.World;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class MaskedDecoration extends RotateableDecoration
   {
      
      protected var m_maskedParts:Array;
      
      protected var m_transparencyMask:DisplayObject;
      
      protected var m_maskedPartsInitialized:Boolean = false;
      
      public function MaskedDecoration(itemName:String = null)
      {
         super(itemName);
         m_depthPriority = -100;
         this.initializeParts(itemName);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(!this.m_maskedPartsInitialized && Boolean(m_item))
         {
            this.initializeParts(m_item.name);
         }
      }
      
      protected function initializeParts(itemName:String = null) : void
      {
         var index:int = 0;
         var lastPart:Boolean = false;
         if(m_displayObject)
         {
            m_displayObject.alpha = 0;
         }
         if(itemName)
         {
            this.m_maskedParts = new Array(m_item.getNumberOfParts());
            lastPart = false;
            for(index = 0; index < this.m_maskedParts.length; index++)
            {
               if(index == this.m_maskedParts.length - 1)
               {
                  lastPart = true;
               }
               this.m_maskedParts[index] = new MaskedDecorationPart(itemName,index,lastPart);
               (this.m_maskedParts[index] as MaskedDecorationPart).setMain(this);
               (this.m_maskedParts[index] as MaskedDecorationPart).setState(state);
            }
            this.m_maskedPartsInitialized = true;
            if(this.m_outer)
            {
               for(index = 0; index < this.m_maskedParts.length; index++)
               {
                  (this.m_maskedParts[index] as MaskedDecorationPart).setOuter(this.m_outer);
                  (this.m_maskedParts[index] as MaskedDecorationPart).conditionallyReattach(true);
               }
            }
         }
      }
      
      override public function drawDisplayObject() : void
      {
         var spr:Sprite = m_displayObject as Sprite;
         if(spr == null)
         {
            createDisplayObject();
         }
         else
         {
            drawActionBar();
         }
      }
      
      override protected function calculateDepthIndex() : void
      {
         super.calculateDepthIndex();
         m_depthIndex += 1000000000;
      }
      
      protected function getBackPart() : MaskedDecorationPart
      {
         var result:MaskedDecorationPart = null;
         if(this.m_maskedParts.length > 0 && this.m_maskedPartsInitialized)
         {
            result = this.m_maskedParts[this.m_maskedParts.length - 1] as MaskedDecorationPart;
         }
         return result;
      }
      
      override public function setHighlighted(highlighted:Boolean, color:uint = 16755200) : void
      {
         var backPart:MaskedDecorationPart = this.getBackPart();
         if(null != backPart)
         {
            backPart.setHighlighted(highlighted);
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         var backPart:MaskedDecorationPart = this.getBackPart();
         if(null != backPart)
         {
            backPart.onMouseOver(event);
         }
      }
      
      override public function setOverrideToolTip(toolTip:String) : void
      {
         var backPart:MaskedDecorationPart = this.getBackPart();
         if(null != backPart)
         {
            backPart.setOverrideToolTip(toolTip);
         }
      }
      
      override public function onMouseOut() : void
      {
         var backPart:MaskedDecorationPart = this.getBackPart();
         if(null != backPart)
         {
            backPart.onMouseOut();
         }
      }
      
      override public function setToolTip(toolTip:String) : void
      {
         var backPart:MaskedDecorationPart = this.getBackPart();
         if(null != backPart)
         {
            backPart.setToolTip(toolTip);
         }
      }
      
      override public function onUpdate(delta:Number) : void
      {
         var index:int = 0;
         super.onUpdate(delta);
         if(!this.m_maskedPartsInitialized && Boolean(m_item))
         {
            this.initializeParts(m_item.name);
         }
      }
      
      override public function isPickable() : Boolean
      {
         return false;
      }
      
      override public function setPosition(newX:Number, newY:Number, newZ:Number = 0) : void
      {
         var index:int = 0;
         super.setPosition(newX,newY,newZ);
         if(this.m_maskedPartsInitialized)
         {
            for(index = 0; index < this.m_maskedParts.length; index++)
            {
               (this.m_maskedParts[index] as MaskedDecorationPart).setPosition(newX,newY,newZ);
            }
         }
      }
      
      override public function setAlpha(alpha:Number) : void
      {
         var index:int = 0;
         super.setAlpha(alpha);
         if(this.m_maskedPartsInitialized)
         {
            for(index = 0; index < this.m_maskedParts.length; index++)
            {
               (this.m_maskedParts[index] as MaskedDecorationPart).setAlpha(alpha);
            }
         }
      }
      
      override public function setOuter(outer:World) : void
      {
         var index:int = 0;
         super.setOuter(outer);
         if(this.m_maskedPartsInitialized)
         {
            for(index = 0; index < this.m_maskedParts.length; index++)
            {
               (this.m_maskedParts[index] as MaskedDecorationPart).setOuter(outer);
            }
         }
      }
      
      override public function setState(value:String) : void
      {
         var index:int = 0;
         super.setState(value);
         if(this.m_maskedPartsInitialized)
         {
            for(index = 0; index < this.m_maskedParts.length; index++)
            {
               (this.m_maskedParts[index] as MaskedDecorationPart).setState(value);
            }
         }
      }
      
      override public function conditionallyReattach(force:Boolean = false) : void
      {
         var index:int = 0;
         var needsRedraw:Boolean = force || m_transformDirty || m_displayObjectDirty || m_attachPosition == null;
         super.conditionallyReattach(force);
         if(this.m_maskedPartsInitialized && needsRedraw)
         {
            for(index = 0; index < this.m_maskedParts.length; index++)
            {
               (this.m_maskedParts[index] as MaskedDecorationPart).conditionallyReattach(true);
            }
         }
      }
      
      override public function attach() : void
      {
         var index:int = 0;
         super.attach();
         if(this.m_maskedPartsInitialized)
         {
            for(index = 0; index < this.m_maskedParts.length; index++)
            {
               (this.m_maskedParts[index] as MaskedDecorationPart).attach();
            }
         }
      }
      
      override public function detach() : void
      {
         var index:int = 0;
         super.detach();
         if(this.m_maskedPartsInitialized)
         {
            for(index = 0; index < this.m_maskedParts.length; index++)
            {
               (this.m_maskedParts[index] as MaskedDecorationPart).detach();
            }
         }
      }
      
      override public function preDisableMove(oldState:String) : void
      {
         var index:int = 0;
         super.preDisableMove(oldState);
         if(this.m_maskedPartsInitialized)
         {
            for(index = 0; index < this.m_maskedParts.length; index++)
            {
               (this.m_maskedParts[index] as MaskedDecorationPart).preDisableMove(oldState);
            }
         }
      }
   }
}

