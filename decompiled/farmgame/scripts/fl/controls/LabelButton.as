package fl.controls
{
   import fl.core.InvalidationType;
   import fl.core.UIComponent;
   import fl.events.ComponentEvent;
   import fl.managers.IFocusManagerComponent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   
   [Event(name="labelChange",type="fl.events.ComponentEvent")]
   [Event(name="click",type="flash.events.MouseEvent")]
   public class LabelButton extends BaseButton implements IFocusManagerComponent
   {
      
      public static var createAccessibilityImplementation:Function;
      
      private static var defaultStyles:Object = {
         "icon":null,
         "upIcon":null,
         "downIcon":null,
         "overIcon":null,
         "disabledIcon":null,
         "selectedDisabledIcon":null,
         "selectedUpIcon":null,
         "selectedDownIcon":null,
         "selectedOverIcon":null,
         "textFormat":null,
         "disabledTextFormat":null,
         "textPadding":5,
         "embedFonts":false
      };
      
      protected var _toggle:Boolean = false;
      
      public var textField:TextField;
      
      protected var mode:String = "center";
      
      protected var _labelPlacement:String = "right";
      
      protected var oldMouseState:String;
      
      protected var _label:String = "Label";
      
      protected var icon:DisplayObject;
      
      public function LabelButton()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return mergeStyles(defaultStyles,BaseButton.getStyleDefinition());
      }
      
      override protected function draw() : void
      {
         if(textField.text != _label)
         {
            label = _label;
         }
         if(isInvalid(InvalidationType.STYLES,InvalidationType.STATE))
         {
            drawBackground();
            drawIcon();
            drawTextFormat();
            invalidate(InvalidationType.SIZE,false);
         }
         if(isInvalid(InvalidationType.SIZE))
         {
            drawLayout();
         }
         if(isInvalid(InvalidationType.SIZE,InvalidationType.STYLES))
         {
            if(isFocused && focusManager.showFocusIndicator)
            {
               drawFocus(true);
            }
         }
         validate();
      }
      
      override protected function drawLayout() : void
      {
         var tmpWidth:Number = NaN;
         var tmpHeight:Number = NaN;
         var txtPad:Number = Number(getStyleValue("textPadding"));
         var placement:String = icon == null && mode == "center" ? ButtonLabelPlacement.TOP : _labelPlacement;
         textField.height = textField.textHeight + 4;
         var txtW:Number = textField.textWidth + 4;
         var txtH:Number = textField.textHeight + 4;
         var paddedIconW:Number = icon == null ? 0 : icon.width + txtPad;
         var paddedIconH:Number = icon == null ? 0 : icon.height + txtPad;
         textField.visible = label.length > 0;
         if(icon != null)
         {
            icon.x = Math.round((width - icon.width) / 2);
            icon.y = Math.round((height - icon.height) / 2);
         }
         if(textField.visible == false)
         {
            textField.width = 0;
            textField.height = 0;
         }
         else if(placement == ButtonLabelPlacement.BOTTOM || placement == ButtonLabelPlacement.TOP)
         {
            tmpWidth = Math.max(0,Math.min(txtW,width - 2 * txtPad));
            if(height - 2 > txtH)
            {
               tmpHeight = txtH;
            }
            else
            {
               tmpHeight = height - 2;
            }
            textField.width = txtW = tmpWidth;
            textField.height = txtH = tmpHeight;
            textField.x = Math.round((width - txtW) / 2);
            textField.y = Math.round((height - textField.height - paddedIconH) / 2 + (placement == ButtonLabelPlacement.BOTTOM ? paddedIconH : 0));
            if(icon != null)
            {
               icon.y = Math.round(placement == ButtonLabelPlacement.BOTTOM ? textField.y - paddedIconH : textField.y + textField.height + txtPad);
            }
         }
         else
         {
            tmpWidth = Math.max(0,Math.min(txtW,width - paddedIconW - 2 * txtPad));
            textField.width = txtW = tmpWidth;
            textField.x = Math.round((width - txtW - paddedIconW) / 2 + (placement != ButtonLabelPlacement.LEFT ? paddedIconW : 0));
            textField.y = Math.round((height - textField.height) / 2);
            if(icon != null)
            {
               icon.x = Math.round(placement != ButtonLabelPlacement.LEFT ? textField.x - paddedIconW : textField.x + txtW + txtPad);
            }
         }
         super.drawLayout();
      }
      
      protected function toggleSelected(event:MouseEvent) : void
      {
         selected = !selected;
         dispatchEvent(new Event(Event.CHANGE,true));
      }
      
      override protected function keyUpHandler(event:KeyboardEvent) : void
      {
         if(!enabled)
         {
            return;
         }
         if(event.keyCode == Keyboard.SPACE)
         {
            setMouseState(oldMouseState);
            oldMouseState = null;
            endPress();
            dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         }
      }
      
      [Inspectable(enumeration="left,right,top,bottom",defaultValue="right",name="labelPlacement")]
      public function get labelPlacement() : String
      {
         return _labelPlacement;
      }
      
      [Inspectable(defaultValue="false")]
      public function get toggle() : Boolean
      {
         return _toggle;
      }
      
      protected function setEmbedFont() : void
      {
         var embed:Object = getStyleValue("embedFonts");
         if(embed != null)
         {
            textField.embedFonts = embed;
         }
      }
      
      [Inspectable(defaultValue="false")]
      override public function get selected() : Boolean
      {
         return _toggle ? _selected : false;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         textField = new TextField();
         textField.type = TextFieldType.DYNAMIC;
         textField.selectable = false;
         addChild(textField);
      }
      
      override protected function initializeAccessibility() : void
      {
         if(LabelButton.createAccessibilityImplementation != null)
         {
            LabelButton.createAccessibilityImplementation(this);
         }
      }
      
      public function set labelPlacement(value:String) : void
      {
         _labelPlacement = value;
         invalidate(InvalidationType.SIZE);
      }
      
      protected function drawIcon() : void
      {
         var oldIcon:DisplayObject = icon;
         var styleName:String = enabled ? mouseState : "disabled";
         if(selected)
         {
            styleName = "selected" + styleName.substr(0,1).toUpperCase() + styleName.substr(1);
         }
         styleName += "Icon";
         var iconStyle:Object = getStyleValue(styleName);
         if(iconStyle == null)
         {
            iconStyle = getStyleValue("icon");
         }
         if(iconStyle != null)
         {
            icon = getDisplayObjectInstance(iconStyle);
         }
         if(icon != null)
         {
            addChildAt(icon,1);
         }
         if(oldIcon != null && oldIcon != icon)
         {
            removeChild(oldIcon);
         }
      }
      
      public function set label(value:String) : void
      {
         _label = value;
         if(textField.text != _label)
         {
            textField.text = _label;
            dispatchEvent(new ComponentEvent(ComponentEvent.LABEL_CHANGE));
         }
         invalidate(InvalidationType.SIZE);
         invalidate(InvalidationType.STYLES);
      }
      
      override protected function keyDownHandler(event:KeyboardEvent) : void
      {
         if(!enabled)
         {
            return;
         }
         if(event.keyCode == Keyboard.SPACE)
         {
            if(oldMouseState == null)
            {
               oldMouseState = mouseState;
            }
            setMouseState("down");
            startPress();
         }
      }
      
      public function set toggle(value:Boolean) : void
      {
         if(!value && super.selected)
         {
            selected = false;
         }
         _toggle = value;
         if(_toggle)
         {
            addEventListener(MouseEvent.CLICK,toggleSelected,false,0,true);
         }
         else
         {
            removeEventListener(MouseEvent.CLICK,toggleSelected);
         }
         invalidate(InvalidationType.STATE);
      }
      
      override public function set selected(value:Boolean) : void
      {
         _selected = value;
         if(_toggle)
         {
            invalidate(InvalidationType.STATE);
         }
      }
      
      protected function drawTextFormat() : void
      {
         var uiStyles:Object = UIComponent.getStyleDefinition();
         var defaultTF:TextFormat = enabled ? uiStyles.defaultTextFormat as TextFormat : uiStyles.defaultDisabledTextFormat as TextFormat;
         textField.setTextFormat(defaultTF);
         var tf:TextFormat = getStyleValue(enabled ? "textFormat" : "disabledTextFormat") as TextFormat;
         if(tf != null)
         {
            textField.setTextFormat(tf);
         }
         else
         {
            tf = defaultTF;
         }
         textField.defaultTextFormat = tf;
         setEmbedFont();
      }
      
      [Inspectable(defaultValue="Label")]
      public function get label() : String
      {
         return _label;
      }
   }
}

