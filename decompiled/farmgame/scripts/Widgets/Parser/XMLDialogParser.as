package Widgets.Parser
{
   import Widgets.View.*;
   import Widgets.View.Buttons.*;
   import Widgets.View.Core.*;
   import Widgets.View.Dialogs.DataDrivenDialogView;
   import Widgets.View.Frames.*;
   import Widgets.View.Icons.*;
   import Widgets.View.TextFields.*;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormatAlign;
   import flash.utils.getDefinitionByName;
   
   public class XMLDialogParser
   {
      
      private static const DECLARE_KNOWN_TYPES:Array = [ButtonBase,ButtonGroup,DialogContentBoxBase,DialogBGBase,DialogBGFarm,DialogTitleBarBase,DialogTitleBarFarm,DialogXButtonBase,ElementBase,IconImageBase,IconSwfAssetBase,TextFieldBase];
      
      public static const STR_XMLTAG_DIALOG:String = "dialog";
      
      public static const STR_XMLTAG_TITLEBAR:String = "titlebar";
      
      public static const STR_XMLTAG_CONTENT:String = "content";
      
      public static const STR_XMLTAG_BUTTONS:String = "buttons";
      
      public static const STR_XMLTAG_BUTTON:String = "button";
      
      public static const STR_XMLTAG_TEXT:String = "text";
      
      public static const STR_XMLTAG_IMAGE:String = "image";
      
      public static const STR_XMLTAG_SWF:String = "swf";
      
      public static const STR_XMLTAG_SPACER:String = "spacer";
      
      public static const STR_BUTTON_CLICK_EVENT_PREFIX:String = "click_";
      
      public static const BOOL_STYLE_KEY_ABS_URL:String = "bAbsoluteUrl";
      
      public static const STR_STYLE_KEY_ALIGN:String = "sAlign";
      
      public static const STR_ALIGN_VAL_CENTER:String = "center";
      
      public static const STR_ALIGN_VAL_LEFT:String = "left";
      
      public static const STR_ALIGN_VAL_RIGHT:String = "right";
      
      public static const STR_ALIGN_VAL_JUSTIFY:String = "justify";
      
      public static const STR_ALIGN_VAL_JUSTIFIED:String = "justified";
      
      public static const UINT_STYLE_KEY_COLOR:String = "uColor";
      
      public static const NUM_STYLE_KEY_CORNER_RADIUS:String = "nCornerRadius";
      
      public static const STR_SYTLE_KEY_DRAW_CLASS_NAME:String = "sDrawClassName";
      
      public static const BOOL_STYLE_KEY_DRAW_SHADOW:String = "bDrawShadow";
      
      public static const STR_STYLE_KEY_FONT:String = "sFont";
      
      public static const BOOL_STYLE_KEY_HAS_DEADFRAME:String = "bHasDeadFrame";
      
      public static const NUM_STYLE_KEY_HEIGHT:String = "nHeight";
      
      public static const STR_STYLE_KEY_LAYER_DEPTH:String = "sLayer";
      
      public static const STR_LAYER_DEPTH_VAL_TOP:String = "top";
      
      public static const STR_LAYER_DEPTH_VAL_FOREGROUND:String = "fg";
      
      public static const STR_LAYER_DEPTH_VAL_BACKGROUND:String = "bg";
      
      public static const STR_LAYER_DEPTH_VAL_CONTENT:String = "content";
      
      public static const STR_STYLE_KEY_LINKAGE:String = "sLinkage";
      
      public static const RECT_STYLE_KEY_MARGIN:String = "rtMargin";
      
      public static const NUM_STYLE_KEY_MAX_WIDTH:String = "nMaxWidth";
      
      public static const STR_STYLE_KEY_NAME:String = "sName";
      
      public static const RECT_STYLE_KEY_PADDING:String = "rtPadding";
      
      public static const NUM_STYLE_KEY_PIXEL_AMOUNT:String = "nPixels";
      
      public static const NUM_STYLE_KEY_PLAYRATE:String = "nPlayrate";
      
      public static const NUM_STYLE_KEY_SCALE:String = "nScale";
      
      public static const UINT_STYLE_KEY_SHADOW_COLOR:String = "uShadowColor";
      
      public static const PT_STYLE_KEY_SHADOW_OFFSET:String = "ptShadowOffset";
      
      public static const UINT_STYLE_KEY_SHADOW_STROKE_COLOR:String = "uShadowStrokeColor";
      
      public static const BOOL_STYLE_KEY_SHOW_DEADFRAME:String = "bShowDeadFrame";
      
      public static const UINT_STYLE_KEY_STROKE_COLOR:String = "uStrokeColor";
      
      public static const NUM_STYLE_KEY_STROKE_THICKNESS:String = "nStrokeThickness";
      
      public static const STR_STYLE_KEY_STYLE:String = "sStyle";
      
      public static const STR_STYLE_VAL_BUTTON_CONFIRM:String = "confirm";
      
      public static const STR_STYLE_VAL_BUTTON_CANCEL:String = "cancel";
      
      public static const STR_STYLE_VAL_BUTTON_OPTIONAL:String = "optional";
      
      public static const STR_STYLE_VAL_HEADER1:String = "h1";
      
      public static const STR_STYLE_VAL_HEADER2:String = "h2";
      
      public static const STR_STYLE_VAL_SMALL:String = "small";
      
      public static const STR_STYLE_VAL_BODY:String = "body";
      
      public static const STR_STYLE_KEY_TEXT:String = "sText";
      
      public static const UINT_STYLE_KEY_TEXT_COLOR:String = "uTextColor";
      
      public static const PT_STYLE_KEY_TEXT_NUDGE:String = "ptTextNudge";
      
      public static const NUM_STYLE_KEY_TEXT_SIZE:String = "nTextSize";
      
      public static const STR_STYLE_KEY_TOOLTIP_TEXT:String = "sTip";
      
      public static const STR_STYLE_KEY_TITLE:String = "sTitle";
      
      public static const STR_STYLE_KEY_LAYER_TYPE:String = "sType";
      
      public static const STR_LAYER_TYPE_VAL_INLINE:String = "inline";
      
      public static const STR_LAYER_TYPE_VAL_FLOAT:String = "float";
      
      public static const STR_STYLE_KEY_REL_URL:String = "sUrl";
      
      public static const BOOL_STYLE_KEY_VISIBLE:String = "bVisible";
      
      public static const NUM_STYLE_KEY_WIDTH:String = "nWidth";
      
      public static const BOOL_STYLE_KEY_XBUTTON:String = "bXButton";
      
      public static const NUM_STYLE_KEY_POS_X:String = "x";
      
      public static const NUM_STYLE_KEY_SCALE_X:String = "xScale";
      
      public static const NUM_STYLE_KEY_POS_Y:String = "y";
      
      public static const NUM_STYLE_KEY_SCALE_Y:String = "yScale";
      
      private var m_sPathToAssets:String = null;
      
      private var m_pDDDialog:DataDrivenDialogView;
      
      public function XMLDialogParser(pDDDialog:DataDrivenDialogView, xml:XML, sPathToAssets:String, aTokenValues:Array)
      {
         super();
         this.m_pDDDialog = pDDDialog;
         this.m_sPathToAssets = sPathToAssets;
         this.parseXMLTag(xml,this.m_pDDDialog,aTokenValues);
         this.onPostCreation();
      }
      
      public static function getSupportedAttributeNameAndTypeCB(sTagName:String) : Array
      {
         var aSupportedAttributeNames:Array = new Array();
         aSupportedAttributeNames[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME] = XMLExtendableData.getStringFromNode;
         aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_NAME] = XMLExtendableData.getStringFromNode;
         aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_STYLE] = XMLExtendableData.getStringFromNode;
         aSupportedAttributeNames[XMLDialogParser.BOOL_STYLE_KEY_VISIBLE] = XMLExtendableData.getBooleanFromNode;
         if(sTagName != null && sTagName != "")
         {
            switch(sTagName)
            {
               case STR_XMLTAG_DIALOG:
                  aSupportedAttributeNames[XMLDialogParser.RECT_STYLE_KEY_PADDING] = XMLExtendableData.getRectFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_WIDTH] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.BOOL_STYLE_KEY_XBUTTON] = XMLExtendableData.getBooleanFromNode;
                  break;
               case STR_XMLTAG_CONTENT:
                  aSupportedAttributeNames[XMLDialogParser.UINT_STYLE_KEY_COLOR] = XMLExtendableData.getColorFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_CORNER_RADIUS] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.BOOL_STYLE_KEY_DRAW_SHADOW] = XMLExtendableData.getBooleanFromNode;
                  aSupportedAttributeNames[XMLDialogParser.RECT_STYLE_KEY_MARGIN] = XMLExtendableData.getRectFromNode;
                  aSupportedAttributeNames[XMLDialogParser.RECT_STYLE_KEY_PADDING] = XMLExtendableData.getRectFromNode;
                  aSupportedAttributeNames[XMLDialogParser.UINT_STYLE_KEY_STROKE_COLOR] = XMLExtendableData.getColorFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_STROKE_THICKNESS] = XMLExtendableData.getNumberFromNode;
                  break;
               case STR_XMLTAG_BUTTONS:
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_HEIGHT] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.RECT_STYLE_KEY_MARGIN] = XMLExtendableData.getRectFromNode;
                  aSupportedAttributeNames[XMLDialogParser.RECT_STYLE_KEY_PADDING] = XMLExtendableData.getRectFromNode;
                  break;
               case STR_XMLTAG_BUTTON:
                  aSupportedAttributeNames[XMLDialogParser.UINT_STYLE_KEY_COLOR] = XMLExtendableData.getColorFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_CORNER_RADIUS] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.BOOL_STYLE_KEY_DRAW_SHADOW] = XMLExtendableData.getBooleanFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_FONT] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_HEIGHT] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.RECT_STYLE_KEY_MARGIN] = XMLExtendableData.getRectFromNode;
                  aSupportedAttributeNames[XMLDialogParser.RECT_STYLE_KEY_PADDING] = XMLExtendableData.getRectFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_PIXEL_AMOUNT] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_SCALE] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.UINT_STYLE_KEY_SHADOW_COLOR] = XMLExtendableData.getColorFromNode;
                  aSupportedAttributeNames[XMLDialogParser.PT_STYLE_KEY_SHADOW_OFFSET] = XMLExtendableData.getPointFromNode;
                  aSupportedAttributeNames[XMLDialogParser.UINT_STYLE_KEY_SHADOW_STROKE_COLOR] = XMLExtendableData.getColorFromNode;
                  aSupportedAttributeNames[XMLDialogParser.UINT_STYLE_KEY_STROKE_COLOR] = XMLExtendableData.getColorFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_STROKE_THICKNESS] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_TEXT] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.UINT_STYLE_KEY_TEXT_COLOR] = XMLExtendableData.getColorFromNode;
                  aSupportedAttributeNames[XMLDialogParser.PT_STYLE_KEY_TEXT_NUDGE] = XMLExtendableData.getPointFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_TEXT_SIZE] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_WIDTH] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_POS_X] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_POS_Y] = XMLExtendableData.getNumberFromNode;
                  break;
               case STR_XMLTAG_TEXT:
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_ALIGN] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_HEIGHT] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_LAYER_DEPTH] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.UINT_STYLE_KEY_TEXT_COLOR] = XMLExtendableData.getColorFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_TEXT_SIZE] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_LAYER_TYPE] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_WIDTH] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_POS_X] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_POS_Y] = XMLExtendableData.getNumberFromNode;
                  break;
               case STR_XMLTAG_TITLEBAR:
                  aSupportedAttributeNames[XMLDialogParser.BOOL_STYLE_KEY_DRAW_SHADOW] = XMLExtendableData.getBooleanFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_HEIGHT] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.RECT_STYLE_KEY_MARGIN] = XMLExtendableData.getRectFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_MAX_WIDTH] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.RECT_STYLE_KEY_PADDING] = XMLExtendableData.getRectFromNode;
                  aSupportedAttributeNames[XMLDialogParser.UINT_STYLE_KEY_TEXT_COLOR] = XMLExtendableData.getColorFromNode;
                  aSupportedAttributeNames[XMLDialogParser.PT_STYLE_KEY_TEXT_NUDGE] = XMLExtendableData.getPointFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_TEXT_SIZE] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_TITLE] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_WIDTH] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_POS_Y] = XMLExtendableData.getNumberFromNode;
                  break;
               case STR_XMLTAG_IMAGE:
                  aSupportedAttributeNames[XMLDialogParser.BOOL_STYLE_KEY_ABS_URL] = XMLExtendableData.getBooleanFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_HEIGHT] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_LAYER_DEPTH] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_TOOLTIP_TEXT] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_LAYER_TYPE] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_REL_URL] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_WIDTH] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_POS_X] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_SCALE_X] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_POS_Y] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_SCALE_Y] = XMLExtendableData.getNumberFromNode;
                  break;
               case STR_XMLTAG_SWF:
                  aSupportedAttributeNames[XMLDialogParser.BOOL_STYLE_KEY_ABS_URL] = XMLExtendableData.getBooleanFromNode;
                  aSupportedAttributeNames[XMLDialogParser.BOOL_STYLE_KEY_HAS_DEADFRAME] = XMLExtendableData.getBooleanFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_HEIGHT] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_LAYER_DEPTH] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_LINKAGE] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_PLAYRATE] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.BOOL_STYLE_KEY_SHOW_DEADFRAME] = XMLExtendableData.getBooleanFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_TOOLTIP_TEXT] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_LAYER_TYPE] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.STR_STYLE_KEY_REL_URL] = XMLExtendableData.getStringFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_WIDTH] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_POS_X] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_SCALE_X] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_POS_Y] = XMLExtendableData.getNumberFromNode;
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_SCALE_Y] = XMLExtendableData.getNumberFromNode;
                  break;
               case STR_XMLTAG_SPACER:
                  aSupportedAttributeNames[XMLDialogParser.NUM_STYLE_KEY_PIXEL_AMOUNT] = XMLExtendableData.getNumberFromNode;
            }
         }
         return aSupportedAttributeNames;
      }
      
      public static function getKeyValuePairsFromXMLNode(xml:XML, xmlStyleNode:XML, aTokenValues:Array, aAttributeNamesAndTypeCB:Array) : Array
      {
         var k:String = null;
         var aKeyValuePairs:Array = new Array();
         for(k in aAttributeNamesAndTypeCB)
         {
            aKeyValuePairs[k] = aAttributeNamesAndTypeCB[k](xml,xmlStyleNode,aTokenValues,k);
         }
         return aKeyValuePairs;
      }
      
      public static function getStyleDataNameFromXMLNode(xml:XML, aTokenValues:Array = null) : String
      {
         var sTagName:String = null;
         var sDefaultTagStyle:String = null;
         var sResult:String = null;
         var sStyle:String = xml.attribute(STR_STYLE_KEY_STYLE).toString();
         if(sStyle != null && sStyle != "" && aTokenValues != null && aTokenValues.length > 0)
         {
            sStyle = XMLExtendableData.ReplaceTokens(sStyle,aTokenValues);
         }
         if(sStyle != null && sStyle != "" && sStyle.charAt(0) != XMLExtendableData.STR_NAMESPACE_SEPARATOR)
         {
            sResult = sStyle;
         }
         else
         {
            sTagName = xml.name().localName.toLowerCase();
            sDefaultTagStyle = Global.dynamicDialogs.getTagDefaultStyleName(sTagName);
            if(sStyle != null && sStyle != "" && sStyle.charAt(0) == XMLExtendableData.STR_NAMESPACE_SEPARATOR)
            {
               sResult = sDefaultTagStyle + sStyle;
            }
            else
            {
               sResult = sDefaultTagStyle;
            }
         }
         if(sResult == null || sResult == "")
         {
         }
         return sResult;
      }
      
      public static function createXMLButton(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, aTokenValues:Array) : ButtonBase
      {
         var sStyleDataName:String = getStyleDataNameFromXMLNode(xml);
         var aKeyValuePairsShadow:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_SHADOW,xml,aTokenValues);
         var aKeyValuePairsOut:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_OUT,xml,aTokenValues);
         var aKeyValuePairsOver:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_OVER,xml,aTokenValues);
         var aKeyValuePairsDown:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_DOWN,xml,aTokenValues);
         var aKeyValuePairsDisabled:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_DISABLED,xml,aTokenValues);
         var sDrawClassNameButton:String = aKeyValuePairs[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME];
         var ButtonClass:Class = getDefinitionByName(sDrawClassNameButton) as Class;
         if(ButtonClass == null)
         {
            ButtonClass = getDefinitionByName("ButtonBase") as Class;
         }
         return new ButtonClass(aKeyValuePairs,aKeyValuePairsShadow,aKeyValuePairsOut,aKeyValuePairsOver,aKeyValuePairsDown,aKeyValuePairsDisabled,aTokenValues);
      }
      
      private static function getTagSubStyleKeyValuePairs(sTagName:String, sStyleDataName:String, sSubStyleName:String, xml:XML, aTokenValues:Array) : Array
      {
         var xmlSubStyleNode:XML = Global.dynamicDialogs.getStyleNodeByName(sStyleDataName + sSubStyleName);
         if(xmlSubStyleNode == null)
         {
         }
         return getKeyValuePairsFromXMLNode(xml,xmlSubStyleNode,aTokenValues,getSupportedAttributeNameAndTypeCB(sTagName));
      }
      
      public static function convertAlignValueToTextFormatAlign(sTextAlign:String) : String
      {
         if(sTextAlign != null && sTextAlign != "")
         {
            switch(sTextAlign.toLowerCase())
            {
               case STR_ALIGN_VAL_CENTER:
                  sTextAlign = TextFormatAlign.CENTER;
                  break;
               case STR_ALIGN_VAL_LEFT:
                  sTextAlign = TextFormatAlign.LEFT;
                  break;
               case STR_ALIGN_VAL_RIGHT:
                  sTextAlign = TextFormatAlign.RIGHT;
                  break;
               case STR_ALIGN_VAL_JUSTIFY:
               case STR_ALIGN_VAL_JUSTIFIED:
                  sTextAlign = TextFormatAlign.JUSTIFY;
            }
         }
         else
         {
            sTextAlign = TextFormatAlign.CENTER;
         }
         return sTextAlign;
      }
      
      public static function convertLayerTypeToFinalConst(aKeyValuePairs:Array) : String
      {
         var sType:String = aKeyValuePairs[STR_STYLE_KEY_LAYER_TYPE];
         var sExeLayerType:String = STR_LAYER_TYPE_VAL_INLINE;
         if(sType != null && sType != "")
         {
            sType = sType.toLowerCase();
            switch(sType)
            {
               case STR_LAYER_TYPE_VAL_FLOAT:
               case STR_LAYER_TYPE_VAL_INLINE:
                  sExeLayerType = sType;
            }
         }
         return sExeLayerType;
      }
      
      public static function getNameValueParamsFromNode(node:XML) : Object
      {
         var param:XML = null;
         var name:String = null;
         var value:String = null;
         var paramsObject:Object = {};
         var params:XMLList = node.param;
         if(params is XMLList)
         {
            for each(param in params)
            {
               name = param.@name;
               value = param.@value;
               paramsObject[name] = value;
            }
         }
         return paramsObject;
      }
      
      private function onPostCreation() : void
      {
         this.m_pDDDialog.traceUnusedAttributes();
         this.m_pDDDialog.drawDebugRects();
      }
      
      private function parseXMLTag(xml:XML, curElement:ElementBase, aTokenValues:Array) : void
      {
         var sName:String = null;
         if(xml == null)
         {
            return;
         }
         var element:ElementBase = null;
         this.m_pDDDialog.dtrace("parseXMLTag: " + xml.name().localName);
         var sTagName:String = xml.name().localName.toLowerCase();
         var sStyleDataName:String = getStyleDataNameFromXMLNode(xml,aTokenValues);
         var xmlStyleNode:XML = Global.dynamicDialogs.getStyleNodeByName(sStyleDataName);
         if(xmlStyleNode == null)
         {
         }
         var aKeyValuePairs:Array = getKeyValuePairsFromXMLNode(xml,xmlStyleNode,aTokenValues,getSupportedAttributeNameAndTypeCB(sTagName));
         var bIsVisible:Boolean = Boolean(aKeyValuePairs[XMLDialogParser.BOOL_STYLE_KEY_VISIBLE]);
         if(bIsVisible)
         {
            switch(sTagName)
            {
               case STR_XMLTAG_DIALOG:
                  element = this.parseXMLTagDialog(aKeyValuePairs,xml,xmlStyleNode,curElement,aTokenValues);
                  break;
               case STR_XMLTAG_TITLEBAR:
                  element = this.parseXMLTagTitleBar(aKeyValuePairs,xml,xmlStyleNode,curElement,aTokenValues);
                  break;
               case STR_XMLTAG_CONTENT:
                  element = this.parseXMLTagContent(aKeyValuePairs,xml,xmlStyleNode,curElement,aTokenValues);
                  break;
               case STR_XMLTAG_BUTTONS:
                  element = this.parseXMLTagButtons(aKeyValuePairs,xml,xmlStyleNode,curElement,aTokenValues);
                  break;
               case STR_XMLTAG_BUTTON:
                  element = this.parseXMLTagButton(aKeyValuePairs,xml,xmlStyleNode,curElement,aTokenValues);
                  break;
               case STR_XMLTAG_TEXT:
                  element = this.parseXMLTagText(aKeyValuePairs,xml,xmlStyleNode,curElement,aTokenValues);
                  break;
               case STR_XMLTAG_IMAGE:
                  element = this.parseXMLTagImage(aKeyValuePairs,xml,xmlStyleNode,curElement,aTokenValues);
                  break;
               case STR_XMLTAG_SWF:
                  element = this.parseXMLTagSwf(aKeyValuePairs,xml,xmlStyleNode,curElement,aTokenValues);
                  break;
               case STR_XMLTAG_SPACER:
                  element = this.parseXMLTagSpacer(aKeyValuePairs,xml,xmlStyleNode,curElement,aTokenValues);
            }
            if(aKeyValuePairs != null)
            {
               sName = aKeyValuePairs[STR_STYLE_KEY_NAME];
               this.m_pDDDialog.storeElement(element,sName);
            }
         }
      }
      
      private function parseAllXMLChildren(xml:XML, curElement:ElementBase, aTokenValues:Array) : void
      {
         var children:XMLList = xml.children();
         var nTotalChildren:Number = children.length();
         for(var i:Number = 0; i < nTotalChildren; i++)
         {
            this.parseXMLTag(children[i],curElement,aTokenValues);
         }
      }
      
      private function parseXMLTagDialog(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, curElement:ElementBase, aTokenValues:Array) : ElementBase
      {
         var mcXButton:ButtonBase = null;
         var rtPadding:Array = aKeyValuePairs[XMLDialogParser.RECT_STYLE_KEY_PADDING];
         var nPaddingTop:Number = Number(rtPadding[XMLExtendableData.STR_RECT_TOP]);
         var nPaddingLeft:Number = Number(rtPadding[XMLExtendableData.STR_RECT_LEFT]);
         var nPaddingRight:Number = Number(rtPadding[XMLExtendableData.STR_RECT_RIGHT]);
         var nPaddingBottom:Number = Number(rtPadding[XMLExtendableData.STR_RECT_BOTTOM]);
         this.m_pDDDialog.prepForInit();
         var nWidth:Number = Number(aKeyValuePairs[XMLDialogParser.NUM_STYLE_KEY_WIDTH]);
         this.m_pDDDialog.setWidth(nWidth);
         curElement.addHeight(nPaddingTop);
         this.parseAllXMLChildren(xml,curElement,aTokenValues);
         curElement.addHeight(nPaddingBottom);
         var sDrawClassNameBG:String = aKeyValuePairs[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME];
         var DialogBGClass:Class = getDefinitionByName(sDrawClassNameBG) as Class;
         if(DialogBGClass == null)
         {
            DialogBGClass = getDefinitionByName("DialogBGBase") as Class;
         }
         var pBG:DialogBGBase = new DialogBGClass(aKeyValuePairs,this.m_pDDDialog.getWidth(),this.m_pDDDialog.getHeight());
         this.m_pDDDialog.m_mcLayerBG.addChild(pBG);
         var bXButton:Boolean = Boolean(aKeyValuePairs[XMLDialogParser.BOOL_STYLE_KEY_XBUTTON]);
         if(bXButton == true)
         {
            mcXButton = this.CreateXButton(xml,aTokenValues);
         }
         return null;
      }
      
      private function parseXMLTagTitleBar(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, curElement:ElementBase, aTokenValues:Array) : ElementBase
      {
         var sDrawClassNameTitleBar:String = null;
         var DialogTitleBarClass:Class = null;
         var mcTitle:DialogTitleBarBase = null;
         var sTitle:String = aKeyValuePairs[STR_STYLE_KEY_TITLE];
         if(sTitle != null && sTitle != "")
         {
            sDrawClassNameTitleBar = aKeyValuePairs[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME];
            DialogTitleBarClass = getDefinitionByName(sDrawClassNameTitleBar) as Class;
            if(DialogTitleBarClass == null)
            {
               DialogTitleBarClass = getDefinitionByName("DialogTitleBarBase") as Class;
            }
            mcTitle = new DialogTitleBarClass(aKeyValuePairs,aTokenValues);
            mcTitle.x = this.m_pDDDialog.getWidth() * 0.5;
            mcTitle.y = curElement.getHeight();
            this.m_pDDDialog.m_mcLayerTop.addChild(mcTitle);
            this.m_pDDDialog.storeElement(mcTitle,DataDrivenDialogView.STR_TITLE_NAME);
            curElement.addHeight(mcTitle.height);
         }
         return mcTitle;
      }
      
      private function CreateXButton(xml:XML, aTokenValues:Array) : ButtonBase
      {
         var sStyleDataName:String = Global.dynamicDialogs.getTagDefaultStyleName(DataDrivenDialogView.STR_XBUTTON_NAME);
         var aKeyValuePairs:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,"",null,aTokenValues);
         var sDrawClassNameXButton:String = aKeyValuePairs[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME];
         var DialogXButtonClass:Class = getDefinitionByName(sDrawClassNameXButton) as Class;
         if(DialogXButtonClass == null)
         {
            DialogXButtonClass = getDefinitionByName("DialogXButtonBase") as Class;
         }
         var aKeyValuePairsShadow:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_SHADOW,null,aTokenValues);
         var aKeyValuePairsOut:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_OUT,null,aTokenValues);
         var aKeyValuePairsOver:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_OVER,null,aTokenValues);
         var aKeyValuePairsDown:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_DOWN,null,aTokenValues);
         var aKeyValuePairsDisabled:Array = getTagSubStyleKeyValuePairs(STR_XMLTAG_BUTTON,sStyleDataName,ButtonBase.STR_SUB_STYLE_DISABLED,null,aTokenValues);
         var mcXButton:ButtonBase = new DialogXButtonClass(aKeyValuePairs,aKeyValuePairsShadow,aKeyValuePairsOut,aKeyValuePairsOver,aKeyValuePairsDown,aKeyValuePairsDisabled,aTokenValues);
         var nXOffset:Number = Number(aKeyValuePairs[XMLDialogParser.NUM_STYLE_KEY_POS_X]);
         var nYOffset:Number = Number(aKeyValuePairs[XMLDialogParser.NUM_STYLE_KEY_POS_Y]);
         mcXButton.x = this.m_pDDDialog.getWidth() + nXOffset;
         mcXButton.y = nYOffset;
         this.m_pDDDialog.m_mcLayerFG.addChild(mcXButton);
         this.m_pDDDialog.storeElement(mcXButton,DataDrivenDialogView.STR_XBUTTON_NAME);
         mcXButton.setStyleName(DataDrivenDialogView.STR_XBUTTON_NAME);
         mcXButton.addEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp);
         return mcXButton;
      }
      
      private function parseXMLTagContent(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, curElement:ElementBase, aTokenValues:Array) : ElementBase
      {
         var rtMargin:Array = aKeyValuePairs[XMLDialogParser.RECT_STYLE_KEY_MARGIN];
         var nMarginTop:Number = Number(rtMargin[XMLExtendableData.STR_RECT_TOP]);
         var nMarginLeft:Number = Number(rtMargin[XMLExtendableData.STR_RECT_LEFT]);
         var nMarginRight:Number = Number(rtMargin[XMLExtendableData.STR_RECT_RIGHT]);
         var nMarginBottom:Number = Number(rtMargin[XMLExtendableData.STR_RECT_BOTTOM]);
         var rtPadding:Array = aKeyValuePairs[XMLDialogParser.RECT_STYLE_KEY_PADDING];
         var nPaddingTop:Number = Number(rtPadding[XMLExtendableData.STR_RECT_TOP]);
         var nPaddingLeft:Number = Number(rtPadding[XMLExtendableData.STR_RECT_LEFT]);
         var nPaddingRight:Number = Number(rtPadding[XMLExtendableData.STR_RECT_RIGHT]);
         var nPaddingBottom:Number = Number(rtPadding[XMLExtendableData.STR_RECT_BOTTOM]);
         var pTmp:ElementBase = new ElementBase(aKeyValuePairs);
         pTmp.setWidth(curElement.getWidth() - (nMarginLeft + nMarginRight + nPaddingLeft + nPaddingRight));
         curElement.addHeight(nMarginTop);
         pTmp.addHeight(nPaddingTop);
         pTmp.x = nMarginLeft;
         pTmp.y = curElement.getHeight();
         this.parseAllXMLChildren(xml,pTmp,aTokenValues);
         var nBoxX:Number = nMarginLeft;
         var nBoxY:Number = curElement.getHeight();
         var nBoxW:Number = curElement.getWidth() - (nMarginLeft + nMarginRight);
         var nBoxH:Number = pTmp.getHeight() + nPaddingBottom;
         aKeyValuePairs[XMLDialogParser.NUM_STYLE_KEY_HEIGHT] = nBoxH;
         aKeyValuePairs[XMLDialogParser.NUM_STYLE_KEY_WIDTH] = nBoxW;
         var aTwo:Array = aKeyValuePairs;
         var sDrawClassNameContentBox:String = aKeyValuePairs[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME];
         var ContentBoxClass:Class = getDefinitionByName(sDrawClassNameContentBox) as Class;
         if(ContentBoxClass == null)
         {
            ContentBoxClass = getDefinitionByName("DialogContentBoxBase") as Class;
         }
         var mcBox:ElementBase = new ContentBoxClass(aKeyValuePairs,aTokenValues);
         mcBox.getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_MARGIN);
         mcBox.getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_PADDING);
         mcBox.x = nBoxX;
         mcBox.y = nBoxY;
         curElement.addHeight(mcBox.getHeight() + nMarginBottom);
         this.m_pDDDialog.m_mcLayerContentBG.addChild(mcBox);
         return mcBox;
      }
      
      private function parseXMLTagButtons(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, curElement:ElementBase, aTokenValues:Array) : ElementBase
      {
         var rtMargin:Array = aKeyValuePairs[XMLDialogParser.RECT_STYLE_KEY_MARGIN];
         var nMarginTop:Number = Number(rtMargin[XMLExtendableData.STR_RECT_TOP]);
         var nMarginLeft:Number = Number(rtMargin[XMLExtendableData.STR_RECT_LEFT]);
         var nMarginRight:Number = Number(rtMargin[XMLExtendableData.STR_RECT_RIGHT]);
         var nMarginBottom:Number = Number(rtMargin[XMLExtendableData.STR_RECT_BOTTOM]);
         var rtPadding:Array = aKeyValuePairs[XMLDialogParser.RECT_STYLE_KEY_PADDING];
         var nPaddingTop:Number = Number(rtPadding[XMLExtendableData.STR_RECT_TOP]);
         var nPaddingLeft:Number = Number(rtPadding[XMLExtendableData.STR_RECT_LEFT]);
         var nPaddingRight:Number = Number(rtPadding[XMLExtendableData.STR_RECT_RIGHT]);
         var nPaddingBottom:Number = Number(rtPadding[XMLExtendableData.STR_RECT_BOTTOM]);
         nMarginTop += nPaddingTop;
         nMarginLeft += nPaddingLeft;
         nMarginRight += nPaddingRight;
         nMarginRight += nPaddingBottom;
         var sDrawClassNameButtons:String = aKeyValuePairs[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME];
         var ButtonGroupClass:Class = getDefinitionByName(sDrawClassNameButtons) as Class;
         if(ButtonGroupClass == null)
         {
            ButtonGroupClass = getDefinitionByName("ButtonGroup") as Class;
         }
         var btnGroup:ButtonGroup = new ButtonGroupClass(aKeyValuePairs);
         btnGroup.getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_MARGIN);
         btnGroup.getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_PADDING);
         var nBtnHeight:Number = btnGroup.getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_HEIGHT);
         btnGroup.x = curElement.getWidth() * 0.5 + nMarginLeft;
         btnGroup.y = curElement.getHeight() + nBtnHeight * 0.5 + nMarginTop;
         curElement.addHeight(nMarginTop);
         this.parseAllXMLChildren(xml,btnGroup,aTokenValues);
         btnGroup.refreshVisual();
         curElement.addHeight(btnGroup.getHeight() + nMarginBottom);
         this.m_pDDDialog.m_mcLayerFG.addChild(btnGroup);
         return btnGroup;
      }
      
      private function parseXMLTagButton(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, curElement:ElementBase, aTokenValues:Array) : ElementBase
      {
         var pBtn:ButtonBase = createXMLButton(aKeyValuePairs,xml,xmlStyleNode,aTokenValues);
         if(curElement is ButtonGroup)
         {
            (curElement as ButtonGroup).addButton(pBtn);
         }
         var sName:String = pBtn.getStyleName();
         if(sName != null && sName != "")
         {
            pBtn.addEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp);
         }
         return pBtn;
      }
      
      private function onButtonMouseUp(evt:MouseEvent) : void
      {
         var pBtn:ButtonBase = evt.target as ButtonBase;
         if(pBtn)
         {
            this.m_pDDDialog.dispatchEvent(new Event(STR_BUTTON_CLICK_EVENT_PREFIX + pBtn.getStyleName()));
         }
      }
      
      public function convertLayerDepthToFinalPointer(aKeyValuePairs:Array) : MovieClip
      {
         var sLayer:String = aKeyValuePairs[STR_STYLE_KEY_LAYER_DEPTH];
         var mcLayer:MovieClip = this.m_pDDDialog.m_mcLayerFG;
         if(sLayer != null && sLayer != "")
         {
            switch(sLayer)
            {
               case STR_LAYER_DEPTH_VAL_TOP:
                  mcLayer = this.m_pDDDialog.m_mcLayerTop;
                  break;
               case STR_LAYER_DEPTH_VAL_FOREGROUND:
                  mcLayer = this.m_pDDDialog.m_mcLayerFG;
                  break;
               case STR_LAYER_DEPTH_VAL_BACKGROUND:
                  mcLayer = this.m_pDDDialog.m_mcLayerBG;
                  break;
               case STR_LAYER_DEPTH_VAL_CONTENT:
                  mcLayer = this.m_pDDDialog.m_mcLayerContentBG;
                  break;
               default:
                  mcLayer = this.m_pDDDialog.m_mcLayerFG;
            }
         }
         return mcLayer;
      }
      
      private function parseXMLTagText(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, curElement:ElementBase, aTokenValues:Array) : ElementBase
      {
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_WIDTH]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_WIDTH] = curElement.getWidth();
         }
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_HEIGHT]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_HEIGHT] = 0;
         }
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_POS_X]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_POS_X] = this.m_pDDDialog.getWidth() * 0.5;
         }
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_POS_Y]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_POS_Y] = curElement.y + curElement.getHeight();
         }
         var mcLayer:MovieClip = this.convertLayerDepthToFinalPointer(aKeyValuePairs);
         var sDrawClassNameText:String = aKeyValuePairs[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME];
         var TextClass:Class = getDefinitionByName(sDrawClassNameText) as Class;
         if(TextClass == null)
         {
            TextClass = getDefinitionByName("TextFieldBase") as Class;
         }
         var pText:TextFieldBase = new TextClass(aKeyValuePairs,xml.toString(),aTokenValues);
         pText.x = aKeyValuePairs[NUM_STYLE_KEY_POS_X];
         pText.y = aKeyValuePairs[NUM_STYLE_KEY_POS_Y];
         var sExeLayerType:String = convertLayerTypeToFinalConst(aKeyValuePairs);
         switch(sExeLayerType)
         {
            case STR_LAYER_TYPE_VAL_FLOAT:
               break;
            default:
               curElement.addHeight(pText.getHeight());
         }
         mcLayer.addChild(pText);
         return pText;
      }
      
      private function parseXMLTagSpacer(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, curElement:ElementBase, aTokenValues:Array) : ElementBase
      {
         var nPixels:Number = Number(aKeyValuePairs[XMLDialogParser.NUM_STYLE_KEY_PIXEL_AMOUNT]);
         curElement.addHeight(nPixels);
         return null;
      }
      
      private function ensureImageAttributesHaveDefaults(aKeyValuePairs:Array, curElement:ElementBase) : void
      {
         if(!aKeyValuePairs[BOOL_STYLE_KEY_ABS_URL])
         {
            aKeyValuePairs[STR_STYLE_KEY_REL_URL] = Global.getAssetURL(aKeyValuePairs[STR_STYLE_KEY_REL_URL]);
         }
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_WIDTH]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_WIDTH] = 0;
         }
         var nW:Number = Number(aKeyValuePairs[NUM_STYLE_KEY_WIDTH]);
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_HEIGHT]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_HEIGHT] = 0;
         }
         var nH:Number = Number(aKeyValuePairs[NUM_STYLE_KEY_HEIGHT]);
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_POS_X]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_POS_X] = this.m_pDDDialog.getWidth() * 0.5 - nW * 0.5;
         }
         var nX:Number = Number(aKeyValuePairs[NUM_STYLE_KEY_POS_X]);
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_POS_Y]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_POS_Y] = curElement.y + curElement.getHeight();
         }
         var nY:Number = Number(aKeyValuePairs[NUM_STYLE_KEY_POS_Y]);
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_SCALE_X]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_SCALE_X] = 1;
         }
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_SCALE_Y]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_SCALE_Y] = 1;
         }
      }
      
      private function parseXMLTagImage(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, curElement:ElementBase, aTokenValues:Array) : ElementBase
      {
         this.ensureImageAttributesHaveDefaults(aKeyValuePairs,curElement);
         var mcLayer:MovieClip = this.convertLayerDepthToFinalPointer(aKeyValuePairs);
         var sDrawClassNameImage:String = aKeyValuePairs[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME];
         var ImageClass:Class = getDefinitionByName(sDrawClassNameImage) as Class;
         if(ImageClass == null)
         {
            ImageClass = getDefinitionByName("IconImageBase") as Class;
         }
         var image:IconImageBase = new ImageClass(aKeyValuePairs,aTokenValues);
         image.x = aKeyValuePairs[NUM_STYLE_KEY_POS_X];
         image.y = aKeyValuePairs[NUM_STYLE_KEY_POS_Y];
         mcLayer.addChild(image);
         var sExeLayerType:String = convertLayerTypeToFinalConst(aKeyValuePairs);
         switch(sExeLayerType)
         {
            case STR_LAYER_TYPE_VAL_FLOAT:
               break;
            default:
               curElement.addHeight(image.getHeight());
         }
         return image;
      }
      
      private function parseXMLTagSwf(aKeyValuePairs:Array, xml:XML, xmlStyleNode:XML, curElement:ElementBase, aTokenValues:Array) : ElementBase
      {
         this.ensureImageAttributesHaveDefaults(aKeyValuePairs,curElement);
         var mcLayer:MovieClip = this.convertLayerDepthToFinalPointer(aKeyValuePairs);
         if(isNaN(aKeyValuePairs[NUM_STYLE_KEY_PLAYRATE]))
         {
            aKeyValuePairs[NUM_STYLE_KEY_PLAYRATE] = 1;
         }
         var sDrawClassNameSwf:String = aKeyValuePairs[XMLDialogParser.STR_SYTLE_KEY_DRAW_CLASS_NAME];
         var SwfClass:Class = getDefinitionByName(sDrawClassNameSwf) as Class;
         if(SwfClass == null)
         {
            SwfClass = getDefinitionByName("IconSwfAssetBase") as Class;
         }
         var swf:IconSwfAssetBase = new SwfClass(aKeyValuePairs,aTokenValues);
         swf.x = aKeyValuePairs[NUM_STYLE_KEY_POS_X];
         swf.y = aKeyValuePairs[NUM_STYLE_KEY_POS_Y];
         mcLayer.addChild(swf);
         var sExeLayerType:String = convertLayerTypeToFinalConst(aKeyValuePairs);
         switch(sExeLayerType)
         {
            case STR_LAYER_TYPE_VAL_FLOAT:
               break;
            default:
               curElement.addHeight(swf.getHeight());
         }
         return swf;
      }
   }
}

