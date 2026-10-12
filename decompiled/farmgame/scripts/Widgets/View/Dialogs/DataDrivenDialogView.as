package Widgets.View.Dialogs
{
   import Widgets.Parser.XMLDialogParser;
   import Widgets.View.Core.ElementBase;
   import flash.display.MovieClip;
   
   public class DataDrivenDialogView extends ElementBase
   {
      
      public static const STR_XBUTTON_NAME:String = "xbutton";
      
      public static const STR_TITLE_NAME:String = "title";
      
      private var m_xmlDialogParser:XMLDialogParser = null;
      
      private var m_allElements:Array = null;
      
      private var m_allButtonEvents:Array = new Array();
      
      private var m_namedElements:Array = null;
      
      public var m_mcLayerBG:MovieClip = null;
      
      public var m_mcLayerContentBG:MovieClip = null;
      
      public var m_mcLayerFG:MovieClip = null;
      
      public var m_mcLayerTop:MovieClip = null;
      
      public function DataDrivenDialogView(xml:XML, sPathToAssets:String, aTokenValues:Array)
      {
         super(null);
         this.m_xmlDialogParser = new XMLDialogParser(this,xml,sPathToAssets,aTokenValues);
      }
      
      public function prepForInit() : void
      {
         this.destroy();
         this.m_allElements = new Array();
         this.m_namedElements = new Array();
         this.m_mcLayerBG = new MovieClip();
         this.m_mcLayerContentBG = new MovieClip();
         this.m_mcLayerFG = new MovieClip();
         this.m_mcLayerTop = new MovieClip();
         this.addChild(this.m_mcLayerBG);
         this.addChild(this.m_mcLayerContentBG);
         this.addChild(this.m_mcLayerFG);
         this.addChild(this.m_mcLayerTop);
      }
      
      override public function destroy() : void
      {
         var el:ElementBase = null;
         this.removeAllButtonEventListeners();
         if(this.m_allElements != null)
         {
            for each(el in this.m_allElements)
            {
               if(el != null)
               {
                  el.destroy();
               }
            }
         }
         super.destroy();
      }
      
      public function addButtonEventListener(sButtonName:String, callback:Function, bUseCapture:Boolean = false, nPriority:int = 0, bUseWeakReference:Boolean = true) : void
      {
         var sFullButtonEventName:String = XMLDialogParser.STR_BUTTON_CLICK_EVENT_PREFIX + sButtonName;
         this.addEventListener(sFullButtonEventName,callback,bUseCapture,nPriority,bUseWeakReference);
         this.m_allButtonEvents[sFullButtonEventName] = callback;
      }
      
      public function removeAllButtonEventListeners() : void
      {
         var sFullButtonEventName:String = null;
         if(this.m_allButtonEvents.length > 0)
         {
            for(sFullButtonEventName in this.m_allButtonEvents)
            {
               this.removeEventListener(sFullButtonEventName,this.m_allButtonEvents[sFullButtonEventName]);
            }
            this.m_allButtonEvents = new Array();
         }
      }
      
      override public function traceUnusedAttributes() : void
      {
         var el:ElementBase = null;
         if(this.m_allElements != null)
         {
            for each(el in this.m_allElements)
            {
               if(el != null)
               {
                  el.traceUnusedAttributes();
               }
            }
         }
         super.traceUnusedAttributes();
      }
      
      override public function drawDebugRects() : void
      {
      }
      
      public function getElementByName(sName:String) : ElementBase
      {
         if(this.m_namedElements.hasOwnProperty(sName))
         {
            return this.m_namedElements[sName];
         }
         return null;
      }
      
      public function storeElement(pElement:ElementBase, sName:String) : void
      {
         if(sName != null && sName != "")
         {
            this.m_namedElements[sName] = pElement;
         }
         this.m_allElements.push(pElement);
      }
   }
}

