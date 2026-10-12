package fl.controls
{
   import fl.core.InvalidationType;
   import fl.core.UIComponent;
   import fl.managers.IFocusManagerComponent;
   import flash.display.DisplayObject;
   
   public class Button extends LabelButton implements IFocusManagerComponent
   {
      
      public static var createAccessibilityImplementation:Function;
      
      private static var defaultStyles:Object = {
         "emphasizedSkin":"Button_emphasizedSkin",
         "emphasizedPadding":2
      };
      
      protected var _emphasized:Boolean = false;
      
      protected var emphasizedBorder:DisplayObject;
      
      public function Button()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return UIComponent.mergeStyles(LabelButton.getStyleDefinition(),defaultStyles);
      }
      
      public function set emphasized(value:Boolean) : void
      {
         _emphasized = value;
         invalidate(InvalidationType.STYLES);
      }
      
      override protected function initializeAccessibility() : void
      {
         if(Button.createAccessibilityImplementation != null)
         {
            Button.createAccessibilityImplementation(this);
         }
      }
      
      protected function drawEmphasized() : void
      {
         var padding:Number = NaN;
         if(emphasizedBorder != null)
         {
            removeChild(emphasizedBorder);
         }
         emphasizedBorder = null;
         if(!_emphasized)
         {
            return;
         }
         var emphasizedStyle:Object = getStyleValue("emphasizedSkin");
         if(emphasizedStyle != null)
         {
            emphasizedBorder = getDisplayObjectInstance(emphasizedStyle);
         }
         if(emphasizedBorder != null)
         {
            addChildAt(emphasizedBorder,0);
            padding = Number(getStyleValue("emphasizedPadding"));
            emphasizedBorder.x = emphasizedBorder.y = -padding;
            emphasizedBorder.width = width + padding * 2;
            emphasizedBorder.height = height + padding * 2;
         }
      }
      
      [Inspectable(defaultValue="false")]
      public function get emphasized() : Boolean
      {
         return _emphasized;
      }
      
      override protected function draw() : void
      {
         if(isInvalid(InvalidationType.STYLES) || isInvalid(InvalidationType.SIZE))
         {
            drawEmphasized();
         }
         super.draw();
         if(emphasizedBorder != null)
         {
            setChildIndex(emphasizedBorder,numChildren - 1);
         }
      }
      
      override public function drawFocus(focused:Boolean) : void
      {
         var emphasizedPadding:Number = NaN;
         var focusPadding:* = undefined;
         super.drawFocus(focused);
         if(focused)
         {
            emphasizedPadding = Number(getStyleValue("emphasizedPadding"));
            if(emphasizedPadding < 0 || !_emphasized)
            {
               emphasizedPadding = 0;
            }
            focusPadding = getStyleValue("focusRectPadding");
            focusPadding = focusPadding == null ? 2 : focusPadding;
            focusPadding += emphasizedPadding;
            uiFocusRect.x = -focusPadding;
            uiFocusRect.y = -focusPadding;
            uiFocusRect.width = width + focusPadding * 2;
            uiFocusRect.height = height + focusPadding * 2;
         }
      }
   }
}

