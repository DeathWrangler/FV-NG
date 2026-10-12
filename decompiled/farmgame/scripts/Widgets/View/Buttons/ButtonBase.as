package Widgets.View.Buttons
{
   import Engine.Utilities;
   import Widgets.Parser.XMLDialogParser;
   import Widgets.Parser.XMLExtendableData;
   import Widgets.View.Core.*;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class ButtonBase extends ElementBase
   {
      
      public static const STR_SUB_STYLE_SHADOW:String = ".shadow";
      
      public static const STR_SUB_STYLE_OUT:String = ".out";
      
      public static const STR_SUB_STYLE_OVER:String = ".over";
      
      public static const STR_SUB_STYLE_DOWN:String = ".down";
      
      public static const STR_SUB_STYLE_DISABLED:String = ".disabled";
      
      protected var m_styleName:String = null;
      
      private var m_text:TextField = null;
      
      protected var m_textContainer:Sprite = null;
      
      private var m_mcOut:Sprite = null;
      
      private var m_mcOver:Sprite = null;
      
      private var m_mcDown:Sprite = null;
      
      private var m_mcDisabled:Sprite = null;
      
      private var m_mouseOver:Boolean = false;
      
      private var m_mouseDown:Boolean = false;
      
      private var m_scaleOut:Number = 1;
      
      private var m_scaleOver:Number = 1;
      
      private var m_scaleDown:Number = 1;
      
      private var m_scaleDisabled:Number = 1;
      
      public function ButtonBase(aKeyValuePairs:Array, aKeyValuePairsShadow:Array = null, aKeyValuePairsOut:Array = null, aKeyValuePairsOver:Array = null, aKeyValuePairsDown:Array = null, aKeyValuePairsDisabled:Array = null, aTokenValues:Array = null)
      {
         super(aKeyValuePairs);
         m_originType = ElementBase.NUM_ORIGIN_TYPE_CENTER_CENTER;
         var nCornerRadius:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_CORNER_RADIUS);
         var bDrawShadow:Boolean = getAttributeValue(XMLDialogParser.BOOL_STYLE_KEY_DRAW_SHADOW);
         var sFont:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_FONT);
         var nHeight:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_HEIGHT);
         var rtMargin:Array = getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_MARGIN);
         var nMarginTop:Number = Number(rtMargin[XMLExtendableData.STR_RECT_TOP]);
         var nMarginLeft:Number = Number(rtMargin[XMLExtendableData.STR_RECT_LEFT]);
         var nMarginRight:Number = Number(rtMargin[XMLExtendableData.STR_RECT_RIGHT]);
         var nMarginBottom:Number = Number(rtMargin[XMLExtendableData.STR_RECT_BOTTOM]);
         var sName:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_NAME);
         var rtPadding:Array = getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_PADDING);
         var nPaddingTop:Number = Number(rtPadding[XMLExtendableData.STR_RECT_TOP]);
         var nPaddingLeft:Number = Number(rtPadding[XMLExtendableData.STR_RECT_LEFT]);
         var nPaddingRight:Number = Number(rtPadding[XMLExtendableData.STR_RECT_RIGHT]);
         var nPaddingBottom:Number = Number(rtPadding[XMLExtendableData.STR_RECT_BOTTOM]);
         var nScale:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_SCALE);
         var nStrokeThickness:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_STROKE_THICKNESS);
         var sText:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_TEXT);
         var uTextColor:Number = getAttributeValue(XMLDialogParser.UINT_STYLE_KEY_TEXT_COLOR);
         var ptTextNudge:Point = getAttributeValue(XMLDialogParser.PT_STYLE_KEY_TEXT_NUDGE);
         var nTextSize:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_TEXT_SIZE);
         var bVisible:Boolean = getAttributeValue(XMLDialogParser.BOOL_STYLE_KEY_VISIBLE);
         var nWidth:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_WIDTH);
         if(nScale != 1)
         {
            nTextSize *= nScale;
            ptTextNudge.x *= nScale;
            ptTextNudge.y *= nScale;
            nHeight *= nScale;
            nPaddingTop *= nScale;
            nPaddingLeft *= nScale;
            nPaddingRight *= nScale;
            nPaddingBottom *= nScale;
            nCornerRadius *= nScale;
            nStrokeThickness *= nScale;
         }
         var nBtnXPadding:Number = nPaddingLeft + nPaddingRight;
         this.createButtonText(replaceTokens(sText,aTokenValues),sFont,uTextColor,nTextSize,nBtnXPadding,ptTextNudge.y);
         this.m_mcOut = this.createButtonState(aKeyValuePairsOut,aKeyValuePairsShadow,bDrawShadow,nBtnXPadding,nWidth,nHeight,nCornerRadius,nStrokeThickness,ptTextNudge.y);
         addChild(this.m_mcOut);
         this.m_mcOut.scaleX = this.m_mcOut.scaleY = aKeyValuePairsOut[XMLDialogParser.NUM_STYLE_KEY_SCALE];
         this.m_mcOut.cacheAsBitmap = true;
         this.m_mcOut.visible = true;
         this.m_mcOver = this.createButtonState(aKeyValuePairsOver,aKeyValuePairsShadow,bDrawShadow,nBtnXPadding,nWidth,nHeight,nCornerRadius,nStrokeThickness,ptTextNudge.y);
         addChild(this.m_mcOver);
         this.m_scaleOver = aKeyValuePairsOver[XMLDialogParser.NUM_STYLE_KEY_SCALE];
         this.m_mcOver.scaleX = this.m_mcOver.scaleY = this.m_scaleOver;
         this.m_mcOver.cacheAsBitmap = true;
         this.m_mcOver.visible = false;
         this.m_mcDown = this.createButtonState(aKeyValuePairsDown,aKeyValuePairsShadow,bDrawShadow,nBtnXPadding,nWidth,nHeight,nCornerRadius,nStrokeThickness,ptTextNudge.y);
         addChild(this.m_mcDown);
         this.m_scaleDown = aKeyValuePairsDown[XMLDialogParser.NUM_STYLE_KEY_SCALE];
         this.m_mcDown.scaleX = this.m_mcDown.scaleY = this.m_scaleDown;
         this.m_mcDown.cacheAsBitmap = true;
         this.m_mcDown.visible = false;
         this.m_mcDisabled = this.createButtonState(aKeyValuePairsDisabled,aKeyValuePairsShadow,bDrawShadow,nBtnXPadding,nWidth,nHeight,nCornerRadius,nStrokeThickness,ptTextNudge.y);
         addChild(this.m_mcDisabled);
         this.m_scaleDisabled = aKeyValuePairsDisabled[XMLDialogParser.NUM_STYLE_KEY_SCALE];
         this.m_mcDisabled.scaleX = this.m_mcDisabled.scaleY = this.m_scaleDisabled;
         this.m_mcDisabled.cacheAsBitmap = true;
         this.m_mcDisabled.visible = false;
         this.m_textContainer = new Sprite();
         Utilities.toggleInputOnlySelf(this.m_textContainer,false);
         this.m_textContainer.addChild(this.m_text);
         addChild(this.m_textContainer);
         this.buttonMode = true;
         this.useHandCursor = true;
         this.addEventListeners();
         this.visible = bVisible;
         if(sName != null && sName != "")
         {
            this.m_styleName = sName;
         }
      }
      
      public function getStyleName() : String
      {
         return this.m_styleName;
      }
      
      public function setStyleName(name:String) : void
      {
         this.m_styleName = name;
      }
      
      private function addEventListeners() : void
      {
         if(!this.hasEventListener(MouseEvent.MOUSE_OVER))
         {
            this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            this.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            this.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         }
      }
      
      override public function destroy() : void
      {
         if(this.hasEventListener(MouseEvent.MOUSE_OVER))
         {
            this.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            this.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            this.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         }
         super.destroy();
      }
      
      public function onMouseOver(evt:MouseEvent) : void
      {
         dtrace("OnMouseOver: " + (evt.target as Sprite).name);
         this.m_mouseOver = true;
         this.refreshVisual();
      }
      
      public function onMouseOut(evt:MouseEvent) : void
      {
         dtrace("OnMouseOut: " + (evt.target as Sprite).name);
         this.m_mouseOver = false;
         this.m_mouseDown = false;
         this.refreshVisual();
      }
      
      public function onMouseDown(evt:MouseEvent) : void
      {
         dtrace("OnMouseDown: " + (evt.target as Sprite).name);
         this.m_mouseDown = true;
         this.refreshVisual();
      }
      
      public function onMouseUp(evt:MouseEvent) : void
      {
         dtrace("OnMouseUp: " + (evt.target as Sprite).name);
         this.m_mouseDown = false;
         this.refreshVisual();
      }
      
      public function refreshVisual() : void
      {
         this.m_mcOut.visible = false;
         this.m_mcOver.visible = false;
         this.m_mcDown.visible = false;
         this.m_mcDisabled.visible = false;
         dtrace("Down: " + this.m_mouseDown + ", Over:" + this.m_mouseOver);
         if(this.m_mouseDown)
         {
            this.m_textContainer.scaleX = this.m_textContainer.scaleY = this.m_scaleDown;
            this.m_mcDown.visible = true;
         }
         else if(this.m_mouseOver)
         {
            this.m_textContainer.scaleX = this.m_textContainer.scaleY = this.m_scaleOver;
            this.m_mcOver.visible = true;
         }
         else
         {
            this.m_textContainer.scaleX = this.m_textContainer.scaleY = this.m_scaleOut;
            this.m_mcOut.visible = true;
         }
      }
      
      public function createButtonText(sText:String, sFont:String, uTextColor:Number, nTextSize:Number, nBtnXPadding:Number = 30, nTextNudgeY:Number = 3) : void
      {
         if(this.m_text != null)
         {
            this.m_text = null;
         }
         this.m_text = new TextField();
         var textFormat:TextFormat = null;
         var bRunningStandalone:Boolean = true;
         textFormat = new TextFormat(sFont,nTextSize,uTextColor,true);
         textFormat.align = TextFormatAlign.CENTER;
         this.m_text.antiAliasType = AntiAliasType.ADVANCED;
         this.m_text.embedFonts = true;
         Utilities.toggleInputOnlySelf(this.m_text,false);
         this.m_text.multiline = false;
         this.m_text.selectable = false;
         this.m_text.textColor = 16777215;
         this.m_text.defaultTextFormat = textFormat;
         this.m_text.htmlText = sText;
         this.m_text.width = this.m_text.textWidth + nBtnXPadding;
         this.m_text.height = this.m_text.textHeight;
         this.m_text.cacheAsBitmap = true;
         this.m_text.x = -this.m_text.width * 0.5;
         this.m_text.y = -this.m_text.height * 0.5;
      }
      
      public function createButtonState(aKeyValuePairs:Array = null, aKeyValuePairsShadow:Array = null, bDrawShadow:Boolean = true, nBtnXPadding:Number = 30, nForceBtnWidth:Number = -1, nForceBtnHeight:Number = -1, nCornerRadius:Number = 0, nStrokeThickness:Number = 0, nTextNudgeY:Number = 3) : Sprite
      {
         var nShadowColor:Number = NaN;
         var nShadowStrokeColor:Number = NaN;
         var ptShadowOffset:Point = null;
         var pSprite:Sprite = new Sprite();
         Utilities.toggleInputOnlySelf(pSprite,false);
         var nBtnWidth:Number = this.m_text.width;
         var nBtnHeight:Number = this.m_text.height;
         if(nForceBtnWidth >= 0)
         {
            nBtnWidth = nForceBtnWidth;
         }
         if(nForceBtnHeight > 0)
         {
            nBtnHeight = nForceBtnHeight;
         }
         var nBtnX:Number = -nBtnWidth * 0.5;
         var nBtnY:Number = -nBtnHeight * 0.5 + nTextNudgeY;
         if(bDrawShadow)
         {
            nShadowColor = Number(aKeyValuePairsShadow[XMLDialogParser.UINT_STYLE_KEY_SHADOW_COLOR]);
            nShadowStrokeColor = Number(aKeyValuePairsShadow[XMLDialogParser.UINT_STYLE_KEY_SHADOW_STROKE_COLOR]);
            ptShadowOffset = aKeyValuePairsShadow[XMLDialogParser.PT_STYLE_KEY_SHADOW_OFFSET];
            pSprite.graphics.beginFill(nShadowColor,1);
            pSprite.graphics.lineStyle(nStrokeThickness,nShadowStrokeColor,1,true);
            pSprite.graphics.drawRoundRect(nBtnX + ptShadowOffset.x,nBtnY + ptShadowOffset.y,nBtnWidth,nBtnHeight,nCornerRadius,nCornerRadius);
            pSprite.graphics.endFill();
         }
         var nButtonColor:Number = Number(aKeyValuePairs[XMLDialogParser.UINT_STYLE_KEY_COLOR]);
         var nButtonStrokeColor:Number = Number(aKeyValuePairs[XMLDialogParser.UINT_STYLE_KEY_STROKE_COLOR]);
         pSprite.graphics.beginFill(nButtonColor,1);
         pSprite.graphics.lineStyle(nStrokeThickness,nButtonStrokeColor,1,true);
         pSprite.graphics.drawRoundRect(nBtnX,nBtnY,nBtnWidth,nBtnHeight,nCornerRadius,nCornerRadius);
         pSprite.graphics.endFill();
         return pSprite;
      }
      
      override public function getWidth() : Number
      {
         return this.m_mcOut.width;
      }
      
      override public function getHeight() : Number
      {
         return this.m_mcOut.height;
      }
   }
}

