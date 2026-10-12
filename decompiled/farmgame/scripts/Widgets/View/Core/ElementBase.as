package Widgets.View.Core
{
   import Widgets.View.Tooltips.*;
   import flash.display.MovieClip;
   import flash.utils.getQualifiedClassName;
   
   public class ElementBase extends MovieClip
   {
      
      public static const BOOL_DEBUG_DRAW:Boolean = false;
      
      public static const BOOL_TRACE_UNUSED_ATTRIBUTES:Boolean = false;
      
      public static const NUM_ORIGIN_TYPE_TOP_LEFT:Number = 1;
      
      public static const NUM_ORIGIN_TYPE_TOP_CENTER:Number = 2;
      
      public static const NUM_ORIGIN_TYPE_CENTER_CENTER:Number = 3;
      
      public var BOOL_DEBUG_TRACE:Boolean = false;
      
      private var m_attributes:Array = null;
      
      private var m_attributesUsed:Array = new Array();
      
      protected var m_widthNoShadow:Number = 0;
      
      protected var m_heightNoShadow:Number = 0;
      
      public var m_originType:Number = 1;
      
      public function ElementBase(aKeyValuePairAttributes:Array = null)
      {
         super();
         this.m_attributes = aKeyValuePairAttributes;
      }
      
      public static function replaceTokens(sText:String, aTokenValues:Array) : String
      {
         var key:int = 0;
         var times:Number = NaN;
         var stringResult:String = sText;
         if(stringResult.indexOf("{") >= 0)
         {
            if(aTokenValues)
            {
               for(key = 0; key < aTokenValues.length; key++)
               {
                  times = 0;
                  if(stringResult)
                  {
                     while(stringResult.indexOf("{" + key + "}") >= 0 && times < 10)
                     {
                        times++;
                        stringResult = stringResult.replace("{" + key + "}",aTokenValues[key]);
                     }
                  }
               }
            }
         }
         return stringResult;
      }
      
      public function getAttributeValue(sKey:String) : *
      {
         if(this.m_attributes != null)
         {
            this.m_attributesUsed[sKey] = true;
            return this.m_attributes[sKey];
         }
         return null;
      }
      
      public function traceUnusedAttributes() : void
      {
         var sKey:String = null;
         if(BOOL_TRACE_UNUSED_ATTRIBUTES && this.m_attributes != null)
         {
            for(sKey in this.m_attributes)
            {
               if(this.m_attributesUsed[sKey] != true)
               {
                  this.dtrace("WARNING: XML Dialog attribute NOT USED: " + sKey + "=" + this.m_attributes[sKey] + "\t\tin class: " + getQualifiedClassName(this));
               }
            }
         }
      }
      
      public function drawDebugRects() : void
      {
         if(BOOL_DEBUG_DRAW)
         {
            switch(this.m_originType)
            {
               case NUM_ORIGIN_TYPE_TOP_LEFT:
                  this.graphics.beginFill(65280,0.1);
                  this.graphics.lineStyle(1,65280,1);
                  this.graphics.drawRect(0,0,this.getWidth(),this.getHeight());
                  this.graphics.endFill();
                  break;
               case NUM_ORIGIN_TYPE_TOP_CENTER:
                  this.graphics.beginFill(65280,0.1);
                  this.graphics.lineStyle(1,65280,1);
                  this.graphics.drawRect(-this.getWidth() * 0.5,0,this.getWidth(),this.getHeight());
                  this.graphics.endFill();
                  break;
               case NUM_ORIGIN_TYPE_CENTER_CENTER:
                  this.graphics.beginFill(65280,0.1);
                  this.graphics.lineStyle(1,65280,1);
                  this.graphics.drawRect(-this.getWidth() * 0.5,-this.getHeight() * 0.5,this.getWidth(),this.getHeight());
                  this.graphics.endFill();
            }
         }
      }
      
      public function destroy() : void
      {
      }
      
      public function dtrace(s:String) : void
      {
         if(this.BOOL_DEBUG_TRACE)
         {
         }
      }
      
      public function getWidth() : Number
      {
         return this.m_widthNoShadow;
      }
      
      public function setWidth(width:Number) : void
      {
         this.m_widthNoShadow = width;
      }
      
      public function getHeight() : Number
      {
         return this.m_heightNoShadow;
      }
      
      public function setHeight(height:Number) : void
      {
         this.m_heightNoShadow = height;
      }
      
      public function addHeight(n:Number) : void
      {
         this.m_heightNoShadow += n;
      }
      
      public function addToolTip(sTipText:String) : void
      {
         var tip:ToolTipManager = ToolTipManager.getInstance();
         tip.addToolTip(this,sTipText);
      }
   }
}

