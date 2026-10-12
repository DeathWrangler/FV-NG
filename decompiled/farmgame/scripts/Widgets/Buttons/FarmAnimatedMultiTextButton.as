package Widgets.Buttons
{
   import Engine.Utilities;
   import Widgets.Constants.FarmAnimatedInteractiveState;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Interfaces.IZwToggle;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   
   public class FarmAnimatedMultiTextButton extends FarmAnimatedButton implements IZwToggle
   {
      
      protected var m_textFields:Array = null;
      
      private var m_isSelected:Boolean = false;
      
      private var m_toggleMode:String = null;
      
      public function FarmAnimatedMultiTextButton(element:MovieClip, textArray:Array, callback:Function = null, autoSize:Boolean = false, htmlText:Boolean = false)
      {
         var key:String = null;
         var text:String = null;
         super(element,callback,autoSize);
         this.m_textFields = new Array();
         for(key in textArray)
         {
            if(element.hasOwnProperty(key))
            {
               text = textArray[key];
               this.m_textFields[key] = new AnimatedTextField(element[key],text,autoSize,htmlText);
               Utilities.toggleInputOnlySelf(element[key],false);
            }
         }
         Utilities.toggleInputOnlyChildren(m_element as DisplayObjectContainer,false);
      }
      
      override public function release() : void
      {
         var key:String = null;
         for(key in this.m_textFields)
         {
            this.m_textFields[key].release();
         }
         this.m_textFields = null;
         this.m_toggleMode = null;
         super.release();
      }
      
      public function getText(fieldName:String) : String
      {
         var buttonText:String = "";
         if(this.m_textFields.hasOwnProperty(fieldName))
         {
            buttonText = this.m_textFields[fieldName].text;
         }
         return buttonText;
      }
      
      public function setText(fieldName:String, value:String) : void
      {
         if(this.m_textFields.hasOwnProperty(fieldName))
         {
            this.m_textFields[fieldName].text = value;
         }
      }
      
      public function getTextFormat(fieldName:String) : TextFormat
      {
         var format:TextFormat = null;
         if(this.m_textFields.hasOwnProperty(fieldName))
         {
            format = this.m_textFields[fieldName].getTextFormat();
         }
         return format;
      }
      
      public function setTextFormat(fieldName:String, value:TextFormat) : void
      {
         if(this.m_textFields.hasOwnProperty(fieldName))
         {
            this.m_textFields[fieldName].setTextFormat(value);
         }
      }
      
      override protected function playOverAnim(event:MouseEvent) : void
      {
         super.playOverAnim(event);
         this.scaleTextOverSize();
      }
      
      override protected function playDownAnim(event:MouseEvent) : void
      {
         animateInteractiveState(FarmAnimatedInteractiveState.SELECTED);
         this.scaleTextDownSize();
      }
      
      override protected function playOutAnim(event:MouseEvent) : void
      {
         super.playOutAnim(event);
         this.scaleTextNormalSize();
         if(this.m_isSelected)
         {
            animateInteractiveState(FarmAnimatedInteractiveState.SELECTED);
         }
         else
         {
            animateInteractiveState(FarmAnimatedInteractiveState.NORMAL);
         }
      }
      
      public function startListenForToggle(callback:Function) : void
      {
         registerEventListener(MouseEvent.CLICK,callback);
      }
      
      public function stopListenForToggle(callback:Function) : void
      {
         unregisterEventListener(MouseEvent.CLICK,callback);
      }
      
      public function setToggleState(toggleState:String) : void
      {
         if(toggleState == ZwToggleState.DISABLED)
         {
            this.enabled = false;
         }
         else
         {
            this.enabled = true;
            if(this.m_toggleMode == ZwToggleMode.SINGLE_SELECT)
            {
               this.handleSingleSelectToggleAnimation(toggleState);
            }
            else if(this.m_toggleMode == ZwToggleMode.MULTI_SELECT)
            {
               this.handleMultiSelectToggleAnimation(toggleState);
            }
         }
      }
      
      override public function set enabled(newEnabled:Boolean) : void
      {
         super.enabled = newEnabled;
         if(this.m_element)
         {
            this.m_element.buttonMode = newEnabled;
         }
      }
      
      public function setToggleMode(toggleMode:String) : void
      {
         this.m_toggleMode = toggleMode;
      }
      
      protected function handleSingleSelectToggleAnimation(toggleState:String) : void
      {
         if(toggleState == ZwToggleState.SELECTED)
         {
            this.m_isSelected = true;
            animateInteractiveState(FarmAnimatedInteractiveState.SELECTED);
            unregisterAnimationEventListeners();
         }
         else if(toggleState == ZwToggleState.DESELECTED)
         {
            this.m_isSelected = false;
            animateInteractiveState(FarmAnimatedInteractiveState.NORMAL);
            this.scaleTextNormalSize();
            registerAnimationEventListeners();
         }
      }
      
      protected function handleMultiSelectToggleAnimation(toggleState:String) : void
      {
         if(toggleState == ZwToggleState.SELECTED)
         {
            this.m_isSelected = true;
            animateInteractiveState(FarmAnimatedInteractiveState.SELECTED);
         }
         else if(toggleState == ZwToggleState.DESELECTED)
         {
            this.m_isSelected = false;
            animateInteractiveState(FarmAnimatedInteractiveState.NORMAL);
         }
      }
      
      protected function scaleTextOverSize() : void
      {
         var key:String = null;
         for(key in this.m_textFields)
         {
            this.m_textFields[key].scaleTextOverSize();
         }
      }
      
      protected function scaleTextDownSize() : void
      {
         var key:String = null;
         for(key in this.m_textFields)
         {
            this.m_textFields[key].scaleTextDownSize();
         }
      }
      
      protected function scaleTextNormalSize() : void
      {
         var key:String = null;
         for(key in this.m_textFields)
         {
            this.m_textFields[key].scaleTextNormalSize();
         }
      }
   }
}

import Widgets.Core.TextFields.ZwTextField;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;

class AnimatedTextField
{
   
   protected static const TEXT_FIELD_OVER_SCALE_VALUE:Number = 1.14;
   
   protected static const TEXT_FIELD_DOWN_SCALE_VALUE:Number = 1.14;
   
   protected var m_textField:ZwTextField = null;
   
   protected var m_autoSize:Boolean = false;
   
   protected var m_normalSizeMatrix:Matrix = null;
   
   protected var m_overSizeMatrix:Matrix = null;
   
   protected var m_downSizeMatrix:Matrix = null;
   
   public function AnimatedTextField(element:TextField, text:String, autoSize:Boolean = false, htmlText:Boolean = false)
   {
      super();
      this.m_textField = new ZwTextField(element,text,htmlText);
      this.m_autoSize = autoSize;
      this.m_normalSizeMatrix = this.m_textField.transform.matrix.clone();
      this.m_overSizeMatrix = this.calcTextFieldOverMatrix();
      this.m_downSizeMatrix = this.calcTextFieldDownMatrix();
   }
   
   public function release() : void
   {
      if(null != this.m_textField)
      {
         this.m_textField.release();
         this.m_textField = null;
      }
      this.m_normalSizeMatrix = null;
      this.m_overSizeMatrix = null;
      this.m_downSizeMatrix = null;
   }
   
   public function get text() : String
   {
      var buttonText:String = "";
      if(this.m_textField)
      {
         buttonText = this.m_textField.text;
      }
      return buttonText;
   }
   
   public function set text(value:String) : void
   {
      if(this.m_textField)
      {
         this.m_textField.text = value;
      }
   }
   
   public function get textFormat() : TextFormat
   {
      var format:TextFormat = null;
      if(this.m_textField)
      {
         format = this.m_textField.getTextFormat();
      }
      return format;
   }
   
   public function set textFormat(value:TextFormat) : void
   {
      if(this.m_textField)
      {
         this.m_textField.setTextFormat(value);
      }
   }
   
   public function scaleTextOverSize() : void
   {
      if(this.m_textField)
      {
         this.m_textField.transform.matrix = this.m_overSizeMatrix.clone();
      }
   }
   
   public function scaleTextDownSize() : void
   {
      if(this.m_textField)
      {
         this.m_textField.transform.matrix = this.m_downSizeMatrix.clone();
      }
   }
   
   public function scaleTextNormalSize() : void
   {
      if(this.m_textField)
      {
         this.m_textField.transform.matrix = this.m_normalSizeMatrix.clone();
      }
   }
   
   public function calcTextFieldOverMatrix() : Matrix
   {
      var xTranslate:Number = NaN;
      var yTranslate:Number = NaN;
      var scaledMatrix:Matrix = this.m_normalSizeMatrix.clone();
      if(!this.m_autoSize)
      {
         xTranslate = this.m_textField.x + this.m_textField.width / 2;
         yTranslate = this.m_textField.y + this.m_textField.height / 2;
         scaledMatrix.translate(-xTranslate,-yTranslate);
         scaledMatrix.scale(TEXT_FIELD_OVER_SCALE_VALUE,TEXT_FIELD_OVER_SCALE_VALUE);
         scaledMatrix.translate(xTranslate,yTranslate);
      }
      return scaledMatrix;
   }
   
   public function calcTextFieldDownMatrix() : Matrix
   {
      return this.m_normalSizeMatrix.clone();
   }
}
