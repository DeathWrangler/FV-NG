package Managers
{
   import Classes.Constants.Experiments;
   import Display.UI;
   import Widgets.Core.TextFields.ZwTextField;
   import com.adobe.utils.StringUtil;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.BitmapFilterType;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class TemplateUIUtility
   {
      
      public static var m_expansionUITemplatizationData:XML;
      
      public static const FARMICON:String = "FARMICON";
      
      public static const FARMICON_SMOOTHING:String = "FARMICON_SMOOTHING";
      
      public static const COUNTDOWN:String = "COUNTDOWN";
      
      public static const ESCAPADE:String = "ESCAPADE";
      
      public static const VOTING:String = "VOTING";
      
      public static const MOTD:String = "MOTD";
      
      public static const BUILDABLE:String = "BUILDABLE";
      
      public static const FARM_STAND:String = "FARM_STAND";
      
      public static const EXPANSION:String = "EXPANSION";
      
      public static const COUNTDOWN_TEMPLATE_SWF:String = "assets/dialogs/FV_templateCountdown.swf";
      
      public static const COUNTDOWN1_TEMPLATE_SWF:String = "assets/dialogs/FV_templateCountdown1.swf";
      
      public static const ESCAPADE_TEMPLATE_SWF:String = "assets/dialogs/FV_templateEscapade.swf";
      
      public static const VOTING_TEMPLATE_SWF:String = "assets/dialogs/FV_templateVote.swf";
      
      public static const VOTING_TEMPLATE_SWF_DYNAMIC_SLOTS:String = "assets/dialogs/FV_templateVote_dynamicSlots.swf";
      
      public static const MOTD_TEMPLATE_SWF:String = "assets/dialogs/FV_motd_template.swf";
      
      public static const BUILDABLE_TEMPLATE_SWF:String = "assets/dialogs/FV_buildable_template.swf";
      
      public function TemplateUIUtility()
      {
         super();
      }
      
      public static function isTemplateUIEnabled(featureType:String, location:String = "") : Boolean
      {
         var result:Boolean = false;
         switch(featureType)
         {
            case TemplateUIUtility.FARMICON:
               result = true;
               break;
            case TemplateUIUtility.FARMICON_SMOOTHING:
               result = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TEMPLATE_FARMICON_SMOOTHING) > 0;
               break;
            case TemplateUIUtility.COUNTDOWN:
               if(HolidayCountdownManager.textColor != "" && HolidayCountdownManager.dialogBackground != "")
               {
                  result = true;
               }
               break;
            case TemplateUIUtility.ESCAPADE:
               result = true;
               break;
            case TemplateUIUtility.VOTING:
               result = true;
               break;
            case TemplateUIUtility.MOTD:
               result = true;
               break;
            case TemplateUIUtility.FARM_STAND:
               result = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TEMPLATE_FARMSTAND) > 0;
               break;
            case TemplateUIUtility.BUILDABLE:
               result = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TEMPLATE_BUILDABLE) > 0;
               break;
            case TemplateUIUtility.EXPANSION:
               if(location != "")
               {
                  m_expansionUITemplatizationData = Global.farmGameSettingsManager.getUITemplatizationData(location);
               }
               else
               {
                  m_expansionUITemplatizationData = Global.farmGameSettingsManager.getUITemplatizationData(Global.worldManager.currentWorldType);
               }
               if(m_expansionUITemplatizationData)
               {
                  result = true;
               }
         }
         return result;
      }
      
      public static function applyTextScaling(zTextField:ZwTextField, featureType:String) : void
      {
         var currentCharWidth:Number = NaN;
         var currentSize:Number = NaN;
         var startingCharHeight:Number = NaN;
         var format:TextFormat = null;
         var maxCharWidth:Number = NaN;
         var maxRatio:Number = NaN;
         var maxFontSize:Number = NaN;
         var hardMaxFontSize:Number = NaN;
         var changeInHeight:Number = NaN;
         if(TemplateUIUtility.isTemplateUIEnabled(featureType) && Boolean(zTextField))
         {
            zTextField.element.scaleX = 1;
            zTextField.element.scaleY = 1;
            currentCharWidth = zTextField.element.textWidth / zTextField.element.length;
            currentSize = Number(zTextField.element.getTextFormat().size);
            startingCharHeight = Number(zTextField.element.textHeight);
            format = new TextFormat();
            format.size = currentSize + 1;
            zTextField.element.setTextFormat(format);
            maxCharWidth = zTextField.element.width / zTextField.element.length;
            maxRatio = currentCharWidth / maxCharWidth;
            maxFontSize = currentSize / maxRatio;
            maxFontSize = Math.floor(maxFontSize) - 1;
            hardMaxFontSize = 55;
            if(maxFontSize >= hardMaxFontSize)
            {
               maxFontSize = hardMaxFontSize;
            }
            format.size = maxFontSize;
            zTextField.element.setTextFormat(format);
            changeInHeight = zTextField.element.textHeight - startingCharHeight;
            zTextField.element.y -= changeInHeight / 2;
         }
      }
      
      public static function applyTextColor(zTextField:ZwTextField, featureType:String, color:String) : void
      {
         if(TemplateUIUtility.isTemplateUIEnabled(featureType) && Boolean(zTextField))
         {
            zTextField.element.textColor = Number(sanitizeTextColorString(color));
         }
      }
      
      private static function sanitizeTextColorString(color:String) : String
      {
         var errorMessage:String = null;
         var orignialColor:String = null;
         var defaultValue:String = null;
         var colorLength:int = 0;
         var colorNumber:Number = NaN;
         if(Global.flashHotParams.hasOwnProperty("FIX_FARM_99883_TEMPRT") && Global.flashHotParams["FIX_FARM_99883_TEMPRT"] == "on" && Boolean(color))
         {
            errorMessage = "";
            orignialColor = color;
            defaultValue = "0x0BEAF0";
            color = StringUtil.trim(color);
            colorLength = color.length;
            if(colorLength < 6)
            {
               color = defaultValue;
               errorMessage = "The value for textColor is too short " + orignialColor + " will be using the default instead " + color;
            }
            else
            {
               colorNumber = Number(color);
               if(isNaN(colorNumber))
               {
                  color = "0x" + color.substring(colorLength - 6,colorLength);
                  colorNumber = Number(color);
                  if(isNaN(colorNumber))
                  {
                     errorMessage = "The value for textColor is NaN and cannot be rebuilt: " + orignialColor;
                  }
                  else
                  {
                     errorMessage = "The value for textColor was NaN " + orignialColor + " but was able to be rebuilt to a proper value " + color;
                  }
               }
            }
            if(errorMessage != "")
            {
               UI.displayMessage(errorMessage);
            }
         }
         return color;
      }
      
      public static function applyDropShadowFilter(zTextField:ZwTextField, featureType:String, color:String) : void
      {
         if(Boolean(TemplateUIUtility.isTemplateUIEnabled(featureType)) && Boolean(zTextField) && Boolean(color))
         {
            TweenMax.to(zTextField.element,0,{"dropShadowFilter":{
               "color":sanitizeTextColorString(color),
               "alpha":1,
               "blurX":4,
               "blurY":4,
               "strength":10
            }});
         }
      }
      
      public static function applyExpansionTextColor(textField:TextField) : void
      {
         if(m_expansionUITemplatizationData)
         {
            textField.textColor = Number(sanitizeTextColorString(m_expansionUITemplatizationData.textColor));
         }
      }
      
      public static function applyExpansionBevelFilter(myDisplayObject:DisplayObject) : void
      {
         var index:int = 0;
         if(m_expansionUITemplatizationData)
         {
            index = int(myDisplayObject.filters.length);
            TweenMax.to(myDisplayObject,0,{"bevelFilter":{
               "index":index,
               "distance":35,
               "angle":90,
               "highlightColor":m_expansionUITemplatizationData.bevelInner.@highlightColor,
               "highlightAlpha":1,
               "shadowColor":m_expansionUITemplatizationData.bevelInner.@shadowColor,
               "shadowAlpha":1,
               "blurX":107,
               "blurY":18,
               "strength":1.5,
               "quality":BitmapFilterQuality.HIGH,
               "type":BitmapFilterType.INNER,
               "knockout":false
            }});
            index++;
            TweenMax.to(myDisplayObject,0,{"bevelFilter":{
               "index":index,
               "distance":1,
               "angle":82,
               "highlightColor":m_expansionUITemplatizationData.bevelFull.@highlightColor,
               "highlightAlpha":1,
               "shadowColor":m_expansionUITemplatizationData.bevelFull.@shadowColor,
               "shadowAlpha":1,
               "blurX":0,
               "blurY":0,
               "strength":1,
               "quality":BitmapFilterQuality.LOW,
               "type":BitmapFilterType.FULL,
               "knockout":false
            }});
         }
      }
      
      public static function applyExpansionSubTextColor(textField:TextField) : void
      {
         if(m_expansionUITemplatizationData)
         {
            textField.textColor = Number(sanitizeTextColorString(m_expansionUITemplatizationData.subTextColor));
         }
      }
      
      public static function applyExpansionGlowFilter(myDisplayObject:DisplayObject) : void
      {
         var filterList:Array = null;
         var myBevel:GlowFilter = null;
         if(m_expansionUITemplatizationData)
         {
            filterList = new Array();
            myBevel = new GlowFilter();
            myBevel.color = m_expansionUITemplatizationData.invertedTextColor;
            myBevel.blurX = 4;
            myBevel.blurY = 4;
            myBevel.quality = BitmapFilterQuality.LOW;
            myBevel.knockout = false;
            myBevel.strength = 10;
            filterList.push(myBevel);
            myDisplayObject.filters = filterList;
         }
      }
      
      public static function applyExpansionDropShadowFilter(myDisplayObject:DisplayObject) : void
      {
         var index:int = 0;
         if(m_expansionUITemplatizationData)
         {
            index = int(myDisplayObject.filters.length);
            TweenMax.to(myDisplayObject,0,{"dropShadowFilter":{
               "index":index,
               "distance":0,
               "angle":45,
               "color":16777215,
               "alpha":1,
               "blurX":5,
               "blurY":5,
               "strength":9,
               "quality":BitmapFilterQuality.LOW,
               "inner":false,
               "knockout":false,
               "hideObject":false
            }});
            index++;
            TweenMax.to(myDisplayObject,0,{"dropShadowFilter":{
               "index":index,
               "distance":3,
               "angle":90,
               "color":0,
               "alpha":1,
               "blurX":3,
               "blurY":3,
               "strength":0.7,
               "quality":BitmapFilterQuality.LOW,
               "inner":false,
               "knockout":false,
               "hideObject":false
            }});
         }
      }
      
      public static function applyBackgroundColor(element:DisplayObject, featureType:String, color:String) : void
      {
         if(Boolean(TemplateUIUtility.isTemplateUIEnabled(featureType)) && Boolean(element) && Boolean(color))
         {
            TweenMax.to(element,0,{"colorTransform":{
               "tint":sanitizeTextColorString(color),
               "tintAmount":1
            }});
         }
      }
   }
}

